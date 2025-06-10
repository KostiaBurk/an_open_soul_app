import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'diary_screen.dart';
import 'edit_profile_story_section.dart';
import 'package:an_open_soul_app/widgets/guest_access_dialog.dart';
import 'package:an_open_soul_app/utils/guest_utils.dart';

class EditProfileScreen extends StatefulWidget {
  final String initialUsername;
  final String initialBio;

  const EditProfileScreen({
    super.key,
    required this.initialUsername,
    required this.initialBio,
  });

  @override
  EditProfileScreenState createState() => EditProfileScreenState();
}

class EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController usernameController;
  late TextEditingController bioController;
  File? _profileImage;
  String? _profileImageUrl;
  bool _isSaving = false;
  final TextEditingController storyController = TextEditingController();

  bool showMyStory = false;

  @override
  void initState() {
    super.initState();
    debugPrint('isGuest = ${GuestUtils.isGuest}');
    usernameController = TextEditingController();
    bioController = TextEditingController();

    _loadUserProfile(); // ← вот новая функция
    _loadProfileImage();
  }

  Future<void> _loadUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final data = doc.data();
      if (data != null) {
        setState(() {
          usernameController.text = data['username'] ?? '';
          bioController.text = data['bio'] ?? '';
          storyController.text = data['story'] ?? '';
          showMyStory = data['showStory'] ?? false;
        });
      }
    }
  }

  /// Loads the current profile image URL from Firestore
  Future<void> _loadProfileImage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        _profileImageUrl = doc.data()?['profileImageUrl'];
      });
    }
  }

  /// Picks an image from the specified source and crops it
  Future<void> _pickImage(ImageSource source) async {
    if (GuestUtils.isGuest) {
      showGuestAccessDialog(context);
      return;
    }

    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      _cropImage(File(pickedFile.path));
    }
  }

  /// Crops the selected image to a circle
  Future<void> _cropImage(File imageFile) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 90,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Colors.purple,
          toolbarWidgetColor: Colors.white,
          statusBarColor: Colors.purple,
          backgroundColor: Colors.black,
          activeControlsWidgetColor: Colors.purpleAccent,
          cropFrameColor: Colors.white,
          dimmedLayerColor: Colors.black54,
          hideBottomControls: false,
          showCropGrid: false,
        ),
        IOSUiSettings(
          title: 'Crop Image',
          aspectRatioLockEnabled: true,
          aspectRatioPickerButtonHidden: true,
          resetAspectRatioEnabled: false,
          doneButtonTitle: 'Done',
          cancelButtonTitle: 'Cancel',
        ),
      ],
    );

    if (croppedFile != null) {
      setState(() {
        _profileImage = File(croppedFile.path);
      });
    }
  }

  /// Uploads the profile image to Firebase Storage and returns the URL
  Future<String?> _uploadProfileImage(File imageFile) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint("❌ User is not authenticated.");
        return null;
      }
      debugPrint("User UID: ${user.uid}");

      // Unique file name
      final fileName = 'profile_images/${user.uid}.jpg';
      debugPrint("Uploading file to: $fileName");

      // Upload image to Firebase Storage
      final storageRef = FirebaseStorage.instance.ref().child(fileName);
      final uploadTask = await storageRef.putFile(imageFile);

      // Get the URL of the uploaded image
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      debugPrint("File uploaded successfully. URL: $downloadUrl");
      return downloadUrl;
    } catch (e) {
      debugPrint("❌ Error uploading profile image: $e");
      return null;
    }
  }

  void _showAnimatedSuccessMessage(String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height * 0.45,
        left: MediaQuery.of(context).size.width * 0.15,
        right: MediaQuery.of(context).size.width * 0.15,
        child: Material(
          color: Colors.transparent,
          child: AnimatedOpacity(
            opacity: 1.0,
            duration: const Duration(milliseconds: 300),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.greenAccent.shade100.withAlpha((0.95 * 255).toInt()),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_outline, color: Colors.green, size: 26),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      message,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  /// Shows options for picking an image
  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Shows an alert for guest users

  /// Saves the user's profile to Firestore
  Future<void> _saveProfile() async {
    FocusScope.of(context).unfocus();

    setState(() {
      _isSaving = true; // включаем индикатор загрузки
    });

    String updatedUsername = usernameController.text.trim();
    final updatedBio = bioController.text.trim();
    final updatedStory = storyController.text.trim();

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not found. Please log in again.")),
      );
      return;
    }

    // Если поле пустое, оставляем старое имя
    if (updatedUsername.isEmpty) {
      updatedUsername = widget.initialUsername;
    }

    String? profileImageUrl;

    if (_profileImage != null) {
      profileImageUrl = await _uploadProfileImage(_profileImage!);
      if (profileImageUrl == null) {
        if (!mounted) return;
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to upload profile image.")),
        );
        return;
      }
    }

    try {
      final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final dataToUpdate = {
        'username': updatedUsername,
        'bio': updatedBio,
        'story': updatedStory,
        'showStory': showMyStory,
      };

      if (profileImageUrl != null) {
        dataToUpdate['profileImageUrl'] = profileImageUrl;
        setState(() {
          _profileImageUrl = profileImageUrl;
        });
      }

      if (!(await docRef.get()).exists) {
        await docRef.set(dataToUpdate);
      } else {
        await docRef.update(dataToUpdate);
      }

      if (!mounted) return;

      _showAnimatedSuccessMessage("Profile successfully updated.");
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update profile: $e")),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false; // отключаем индикатор после завершения
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
    appBar: PreferredSize(
  preferredSize: const Size.fromHeight(60),
  child: Container(
    padding: EdgeInsets.only(
      top: MediaQuery.of(context).padding.top,
      bottom: 10,
      left: 8,
      right: 8,
    ),
    decoration: BoxDecoration(
      color: isDark ? Colors.black : const Color(0xFF8E24AA),
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
    ),
    child: Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            "Edit Profile",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: const [
                Shadow(offset: Offset(1, 1), blurRadius: 2, color: Colors.black54),
              ],
            ),
          ),
        ),
        const SizedBox(width: 48),
      ],
    ),
  ),
),

      body: Container(
        decoration: BoxDecoration(
  gradient: isDark
      ? const LinearGradient(
          colors: [Color(0xFF1D1F21), Color(0xFF2C2C54), Color(0xFF1D1F21)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        )
      : const LinearGradient(
          colors: [Color(0xFF8E24AA), Color(0xFFF3D9FF), Color(0xFF80DEEA)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
),

        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      _buildProfileImage(),
                      const SizedBox(height: 20),
                                            _buildButton("My Diary", () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DiaryScreen(isGuest: GuestUtils.isGuest),
                          ),
                        );
                      }),
                      const SizedBox(height: 20),
                      _buildLabel("Username"),
                      _buildTextField(usernameController, "Enter your username"),

                      const SizedBox(height: 20),
                      _buildLabel("Bio"),
                      const SizedBox(height: 1),
                      _buildTextField(bioController, "Tell us about yourself", maxLines: 4),
                      StorySection(
                        controller: storyController,
                        showToOthers: showMyStory,
                        isGuest: GuestUtils.isGuest,
                        onSwitchChanged: (value) {
                          setState(() {
                            showMyStory = value;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                     
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: _buildSaveButton("Save", () {
                GuestUtils.isGuest ? showGuestAccessDialog(context) : _saveProfile();
              }),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a label for the text fields
  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Colors.white,
          shadows: const [
            Shadow(offset: Offset(1, 1), blurRadius: 2, color: Colors.black26),
          ],
        ),
      ),
    );
  }

  /// Builds a text field for user input
  Widget _buildTextField(TextEditingController controller, String label, {int maxLines = 1}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;


    return TextField(
      controller: controller, // Используем контроллер для отображения текста
      maxLines: maxLines,
      onTap: () {
        if (GuestUtils.isGuest) {
          showGuestAccessDialog(context);
        }
      },
      readOnly: GuestUtils.isGuest,
      decoration: InputDecoration(
  hintText: label,
  filled: true,
  fillColor: isDark
      ? const Color.fromARGB(180, 40, 40, 50)
      : const Color.fromRGBO(255, 255, 255, 0.8),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(15),
    borderSide: BorderSide.none,
  ),
  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
  hintStyle: TextStyle(
    color: isDark ? Colors.white70 : const Color.fromRGBO(0, 0, 0, 0.6),
  ),
),
style: TextStyle(
  color: isDark ? Colors.white : Colors.black87,
),

    );
  }

  Widget _buildSaveButton(String text, VoidCallback onPressed) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return Center(
    child: SizedBox(
      width: 160,
      height: 48,
      child: ElevatedButton(
        onPressed: _isSaving ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark
              ? const Color(0xFF610159) // 🌑 глубокий фиолет для тёмной темы
              : const Color(0xFFA190A8), // 🌕 мягкий фиолет для светлой
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
          shadowColor: Colors.black54,
          elevation: 5,
        ),
        child: _isSaving
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                text,
                style: GoogleFonts.poppins(
                  fontSize: 18, // 🔽 уменьшили размер шрифта
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: const [
                    Shadow(offset: Offset(2, 2), blurRadius: 3, color: Colors.black),
                  ],
                ),
              ),
      ),
    ),
  );
}


  /// Builds a button with the specified text and action
Widget _buildButton(String text, VoidCallback onPressed) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return Center(
    child: SizedBox(
      width: 160,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          backgroundColor: isDark
              ? const Color(0xFF610159) // для тёмной темы
              : const Color(0xFFA190A8), // для светлой темы
          elevation: 5,
          shadowColor: Colors.black54,
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: const [
              Shadow(offset: Offset(2, 2), blurRadius: 3, color: Colors.black),
            ],
          ),
        ),
      ),
    ),
  );
}




  /// Builds the profile image widget
  Widget _buildProfileImage() {
    return GestureDetector(
      onTap: () {
        GuestUtils.isGuest ? showGuestAccessDialog(context) : _showImagePickerOptions();
      },
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(2, 4),
            ),
          ],
        ),
        child: CircleAvatar(
          radius: 80,
          backgroundColor: Colors.white,
          backgroundImage: _profileImage != null
              ? FileImage(_profileImage!)
              : (_profileImageUrl != null ? NetworkImage(_profileImageUrl!) : null),
          child: _profileImage == null && _profileImageUrl == null
              ? const Icon(Icons.add_a_photo, size: 50, color: Colors.grey)
              : null,
        ),
      ),
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    bioController.dispose();
    storyController.dispose();
    super.dispose();
  }
}
