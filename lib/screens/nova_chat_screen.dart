import 'package:an_open_soul_app/screens/subscription_screen.dart';
import 'package:an_open_soul_app/services/subscription_checker.dart';
import 'package:an_open_soul_app/services/subscription_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:an_open_soul_app/widgets/custom_drawer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:an_open_soul_app/widgets/stars_background.dart';
import 'package:an_open_soul_app/services/openai_service.dart';
import 'dart:developer';
import 'package:an_open_soul_app/models/user_plan.dart';
import 'package:an_open_soul_app/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:an_open_soul_app/services/trial_service.dart';

class NovaChatScreen extends StatefulWidget {
  const NovaChatScreen({super.key});

  @override
  NovaChatScreenState createState() => NovaChatScreenState();
}

class NovaChatScreenState extends State<NovaChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final OpenAIService _openAIService = OpenAIService();
  String _selectedModel = 'gpt-3.0';
  int _gpt4oMessagesUsed = 0;
  UserPlan _userPlan = UserPlan.echo;
  bool _showModelOptions = false;
  bool _isLoading = false;
  String _animatedMessage = '';
  bool _showCursor = true;
  bool _isTrial = false;
  List<Map<String, String>> _chatHistory = [
    {
      "role": "system",
      "content":
          "You are Nova — a warm, honest and emotionally aware AI who speaks like a real person. Do not use robotic or repetitive phrases like 'I'm here to support you' unless the user asks directly. Instead, respond naturally, like a close friend. Be gentle, sincere, and speak with empathy — but always sound human, not like a chatbot. Never say you're ChatGPT. You're Nova. Keep things short and real."
    }
  ];

  @override
  void initState() {
    super.initState();
    _startCursorBlink();
    _loadUserPlan();
    _loadGpt4oUsage();
    
    _checkTrialPeriod();
     _initializeChatSettings();
      _loadNovaMessages(); // ✅ вызываем при старте
 }
 void _checkTrialPeriod() async {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final isTrial = await TrialService.isUserInTrial(uid);

  setState(() {
    _isTrial = isTrial;
  });

  if (_isTrial) {
    await TrialService.checkTrialStatus(uid); // проверка истечения
  }
}

Future<void> _loadNovaMessages() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  try {
    // 👇 Добавляем проверку: если выбрана gpt-3.0 — не загружаем историю
    if (_selectedModel == 'gpt-3.0') {
      setState(() {
        _chatHistory.clear(); // очистить, если вдруг что-то есть
      });
      return;
    }

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('novaMessages')
        .where('model', isEqualTo: _selectedModel) // ⬅️ только текущая модель
        .orderBy('timestamp')
        .get();

    final messages = snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        "role": data['role'] ?? '',
        "content": data['content'] ?? '',
      };
    }).toList();

    setState(() {
  _chatHistory = messages.map((e) => {
    "role": e["role"] as String,
    "content": e["content"] as String,
  }).toList();
});


    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  } catch (e) {
    log('⚠️ Ошибка при загрузке novaMessages: $e');
  }
}



 

  void _loadUserPlan() async {
    final plan = await UserService().getUserPlan();
    setState(() {
      _userPlan = plan;
    });
  }

  void _loadGpt4oUsage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _gpt4oMessagesUsed = prefs.getInt('gpt4oUsed') ?? 0;
    });
  }

  void _startCursorBlink() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 500));
      if (!_isLoading) return false;
      setState(() => _showCursor = !_showCursor);
      return true;
    });
  }

 void _sendMessage() async {
  log('📩 _sendMessage called'); // ← добавь это
  final userMessage = _messageController.text.trim();
  if (userMessage.isEmpty || _isLoading) return;

  final modelKey = _selectedModel == 'gpt-3.0'
      ? 'gpt3'
      : _selectedModel == 'gpt-3.5'
          ? 'gpt35'
          : 'gpt4';

  final uid = FirebaseAuth.instance.currentUser!.uid;
  final checker = SubscriptionChecker();

  await checker.resetDailyCountersIfNeeded(uid);

  final isTrial = await checker.isTrialActive(uid);
  final allowed = await checker.canSendMessage(uid, modelKey, isTrial: isTrial);

  log('🧪 isTrial: $isTrial, userPlan: $_userPlan');

  final shouldSave = (_userPlan == UserPlan.pulse || _userPlan == UserPlan.novaLink) || isTrial;

  if (!allowed) {
    if (isTrial) {
      if (!mounted) return;
      _showUpgradeDialog("You've reached your trial limit for today.");
    } else {
      if (!mounted) return;
      _showUpgradeDialog("You've reached the daily message limit for this model.");
    }
    return;
  }

  // Удаляем старый system, если он есть
  _chatHistory.removeWhere((msg) => msg["role"] == "system");

  // Добавляем новый system с указанием точной модели
  _chatHistory.insert(0, {
    "role": "system",
    "content": _getSystemMessageForModel(_selectedModel),
  });

  setState(() {
    _chatHistory.add({"role": "user", "content": userMessage});
    _isLoading = true;
    _animatedMessage = '';
  });

  _messageController.clear();
  _scrollToBottom();

  try {
    log('💬 Saving user message: shouldSave=$shouldSave, userPlan=$_userPlan, isTrial=$isTrial');

    if (shouldSave) {
      await _saveNovaMessage(
        role: 'user',
        content: userMessage,
        model: _selectedModel,
      );
    }

    final aiResponse = await _openAIService.sendChat(_chatHistory, model: _selectedModel);
    log('🤖 Ответ от Nova: $aiResponse');

    if (shouldSave) {
      await _saveNovaMessage(
        role: 'assistant',
        content: aiResponse,
        model: _selectedModel,
      );
    }

    for (int i = 0; i < aiResponse.length; i++) {
      await Future.delayed(const Duration(milliseconds: 25));
      setState(() {
        _animatedMessage = aiResponse.substring(0, i + 1);
      });
      _scrollToBottom();
    }

    setState(() {
      _chatHistory.add({"role": "assistant", "content": _animatedMessage});
      _animatedMessage = '';
      _isLoading = false;
    });

    _scrollToBottom();

    if (_userPlan == UserPlan.echo && !isTrial) {
      await checker.incrementMessageCount(uid, modelKey);
    }
  } catch (e, stack) {
    log('❌ Ошибка при вызове ИИ: $e', stackTrace: stack);
    setState(() {
      _chatHistory.add({
        "role": "assistant",
        "content": "Sorry, something went wrong. Please try again later."
      });
      _isLoading = false;
    });
  }
}



void _scrollToBottom() {
  if (_scrollController.hasClients) {
    _scrollController.jumpTo(
      _scrollController.position.maxScrollExtent,
    );
  }
}




  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        endDrawer: const CustomDrawer(),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(59),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.black : const Color(0xFF8E24AA),
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(20)),
                ),
              ),
              if (isDark)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(20)),
                    child: const AnimatedStarField(starCount: 40),
                  ),
                ),
              Container(
                padding:
                    EdgeInsets.only(top: MediaQuery.of(context).padding.top + 2),
             child: Row(
  children: [
    IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.white),
      onPressed: () => Navigator.pop(context),
    ),
    const SizedBox(width: 8),
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Chat with Nova",
            style: GoogleFonts.pacifico(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: const [
                Shadow(offset: Offset(1, 1), blurRadius: 2, color: Colors.black54),
              ],
            ),
          ),
          const SizedBox(height: 6),
          
        ],
      ),
    ),
    const SizedBox(width: 8),
  ],
),

              ),
            ],
          ),
        ),
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: isDark
                    ? const LinearGradient(
                        colors: [
                          Color(0xFF1D1F21),
                          Color(0xFF2C2C54),
                          Color(0xFF1D1F21)
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      )
                    : const LinearGradient(
                        colors: [
                          Color(0xFF8E24AA),
                          Color(0xFFF3D9FF),
                          Color(0xFF80DEEA)
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top - 40,
              bottom: _isLoading ? 130 : 100,
              left: 10,
              right: 10,
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _chatHistory.length - 1 + (_animatedMessage.isNotEmpty ? 1 : 0),
                itemBuilder: (context, index) {
                  bool isLastAnimated = _animatedMessage.isNotEmpty && index == _chatHistory.length - 1;
                  final message = isLastAnimated
                      ? {"role": "assistant", "content": _animatedMessage + (_showCursor ? "|" : "")}
                      : _chatHistory[index + 1];

                  final isNova = message["role"] == "assistant";

                  return GestureDetector(
                    onLongPress: () {
                      Clipboard.setData(ClipboardData(text: message["content"]!));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Message copied!"),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Align(
                      alignment: isNova ? Alignment.centerLeft : Alignment.centerRight,
                      child: Row(
                        mainAxisAlignment: isNova ? MainAxisAlignment.start : MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isNova) ...[
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0, top: 8),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.asset(
                                  'assets/images/nova_avatar.png',
                                  height: 28,
                                  width: 28,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ],
                          Flexible(
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                              decoration: BoxDecoration(
                                color: isNova
                                    ? Colors.blue[100]?.withAlpha((0.15 * 255).toInt())
                                    : Colors.purple[100]?.withAlpha((0.2 * 255).toInt()),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                message["content"]!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      offset: Offset(1, 1),
                                      blurRadius: 3,
                                      color: Colors.black26,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_isLoading)
              const Positioned(
                bottom: 100,
                left: 0,
                right: 0,
                child: Center(child: CircularProgressIndicator()),
              ),
           Positioned(
  bottom: 50,
  left: 20,
  right: 20,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _showModelOptions
            ? Container(
                key: const ValueKey('options'),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
               decoration: BoxDecoration(
  color: isDark ? Colors.black.withAlpha((0.7 * 255).toInt()) : Colors.white.withAlpha((0.95 * 255).toInt()),
  borderRadius: BorderRadius.circular(10),
  border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withAlpha((0.2 * 255).toInt()),
      blurRadius: 6,
    ),
  ],
),

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildModelButton('gpt-3.0', '3.0'),
                    _buildModelButton('gpt-3.5', '3.5+'),
                    _buildModelButton('gpt-4o', '4o'),
                  ],
                ),
              )
            : const SizedBox.shrink(),
      ),
      const SizedBox(height: 6),
      Row(
        children: [
          GestureDetector(
            onTap: () => setState(() => _showModelOptions = !_showModelOptions),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? Colors.purple[800] : Colors.purple[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _selectedModel == 'gpt-3.0'
                    ? '3.0'
                    : _selectedModel == 'gpt-3.5'
                        ? '3.5+'
                        : '4o',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.white.withAlpha(230),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: _messageController,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  hintText: "Type your message...",
                  hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: _isLoading ? null : _sendMessage,
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? Colors.purple[700] : Colors.purple,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              "Send",
              style: TextStyle(color: isDark ? Colors.white : Colors.white),
            ),
          ),
        ],
      ),
    ],
  ),
)

          ],
        ),
      ),
    );
  }
 Widget _buildModelButton(String value, String label) {
  final isSelected = _selectedModel == value;
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4),
    child: ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: isSelected ? Colors.white : Colors.grey[300],
        ),
      ),
      selected: isSelected,
      backgroundColor: Colors.black,
      selectedColor: Colors.purple,
      side: BorderSide(color: Colors.white24, width: 1),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onSelected: (selected) {
        if (selected) _onModelSelected(value);
      },
    ),
  );
}

void _onModelSelected(String model) {
  final hasNovaLink = _userPlan == UserPlan.novaLink;
  final isEcho = _userPlan == UserPlan.echo;

  if (model == 'gpt-4o') {
    if (!_isTrial && !hasNovaLink) {
      if (_gpt4oMessagesUsed >= 5) {
        _showUpgradeDialog("You've used all 5 GPT-4o trial messages.");
        return;
      } else {
        _showUpgradeDialog("GPT-4o is available only with NovaLink plan.");
        return;
      }
    }
  } else if (model == 'gpt-3.5') {
    if (!_isTrial && isEcho) {
      _showUpgradeDialog("GPT-3.5+ is available on Pulse or NovaLink plans.");
      return;
    }
  }

  setState(() => _selectedModel = model);
}


void _showUpgradeDialog(String message) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Upgrade Required'),
      content: Text(message),
      actions: [
        TextButton(
          child: const Text('Later'),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
          child: const Text('Upgrade'),
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
            );
          },
        ),
      ],
    ),
  );
}
String _getSystemMessageForModel(String model) {
  switch (model) {
    case 'gpt-3.0':
      return "You are Nova, based on GPT-3.0, a lighter and faster model with basic reasoning skills.";
    case 'gpt-3.5':
      return "You are Nova, based on GPT-3.5-turbo, accurate as of October 2023.";
    case 'gpt-4o':
      return "You are Nova, based on GPT-4o, the most advanced model by OpenAI as of May 2024.";
    default:
      return "You are Nova — a warm, honest and emotionally aware AI. Answer as yourself.";
  }
}

Future<void> _saveNovaMessage({
  required String role,
  required String content,
  required String model,
}) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  // ❌ Не сохраняем сообщения для gpt-3.0 (Echo)
  if (model == 'gpt-3.0') return;

  // ✅ Сохраняем для gpt-3.5 и gpt-4o
  await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('novaMessages')
      .add({
    'role': role,
    'content': content,
    'timestamp': Timestamp.now(),
    'model': model,
  });
}

Future<void> _initializeChatSettings() async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return;

  final checker = SubscriptionChecker();
  final isTrial = await checker.isTrialActive(uid);
  final plan = await SubscriptionService().getUserPlan(uid);

  setState(() {
    _isTrial = isTrial;
    _userPlan = plan;
  });

  log('🔍 [NovaChat] Plan: $_userPlan | Trial: $_isTrial');
}



}
