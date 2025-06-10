import 'package:an_open_soul_app/screens/tests/depression_result_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BeckDepressionScreen extends StatefulWidget {
  const BeckDepressionScreen({super.key});

  @override
  State<BeckDepressionScreen> createState() => _BeckDepressionScreenState();
}


class _BeckDepressionScreenState extends State<BeckDepressionScreen> {


  final List<Map<String, dynamic>> _questions = [
    {
      'question': '1. Sadness',
      'answers': [
        'I do not feel sad.',
        'I feel sad much of the time.',
        'I am sad all the time.',
        'I am so sad or unhappy that I can’t stand it.'
      ],
    },
    {
      'question': '2. Pessimism',
      'answers': [
        'I am not discouraged about my future.',
        'I feel more discouraged about my future than I used to be.',
        'I do not expect things to work out for me.',
        'I feel my future is hopeless and will only get worse.'
      ],
    },
    {
      'question': '3. Past Failure',
      'answers': [
        'I do not feel like a failure.',
        'I have failed more than I should have.',
        'As I look back, I see a lot of failures.',
        'I feel I am a total failure as a person.'
      ],
    },
    {
      'question': '4. Loss of Pleasure',
      'answers': [
        'I get as much pleasure as I ever did from the things I enjoy.',
        'I don’t enjoy things as much as I used to.',
        'I get very little pleasure from the things I used to enjoy.',
        'I can’t get any pleasure from the things I used to enjoy.'
      ],
    },
    {
      'question': '5. Guilty Feelings',
      'answers': [
        'I don’t feel particularly guilty.',
        'I feel guilty over many things I have done or should have done.',
        'I feel quite guilty most of the time.',
        'I feel guilty all of the time.'
      ],
    },
    {
      'question': '6. Punishment Feelings',
      'answers': [
        'I don’t feel I am being punished.',
        'I feel I may be punished.',
        'I expect to be punished.',
        'I feel I am being punished.'
      ],
    },
    {
      'question': '7. Self-Dislike',
      'answers': [
        'I feel the same about myself as ever.',
        'I have lost confidence in myself.',
        'I am disappointed in myself.',
        'I dislike myself.'
      ],
    },
    {
      'question': '8. Self-Criticalness',
      'answers': [
        'I don’t criticize or blame myself more than usual.',
        'I am more critical of myself than I used to be.',
        'I criticize myself for all of my faults.',
        'I blame myself for everything bad that happens.'
      ],
    },
    {
      'question': '9. Suicidal Thoughts or Wishes',
      'answers': [
        'I don’t have any thoughts of killing myself.',
        'I have thoughts of killing myself, but I would not carry them out.',
        'I would like to kill myself.',
        'I would kill myself if I had the chance.'
      ],
    },
    {
      'question': '10. Crying',
      'answers': [
        'I don’t cry any more than I used to.',
        'I cry more than I used to.',
        'I cry over every little thing.',
        'I feel like crying, but I can’t.'
      ],
    },
    {
      'question': '11. Agitation',
      'answers': [
        'I am no more restless or wound up than usual.',
        'I feel more restless or wound up than usual.',
        'I am so restless or agitated that it’s hard to stay still.',
        'I am so restless or agitated that I have to keep moving or doing something.'
      ],
    },
    {
      'question': '12. Loss of Interest',
      'answers': [
        'I have not lost interest in other people or activities.',
        'I am less interested in other people or things than before.',
        'I have lost most of my interest in other people or things.',
        'It’s hard to get interested in anything.'
      ],
    },
    {
      'question': '13. Indecisiveness',
      'answers': [
        'I make decisions about as well as ever.',
        'I find it more difficult to make decisions than usual.',
        'I have much greater difficulty in making decisions than I used to.',
        'I have trouble making any decisions.'
      ],
    },
    {
      'question': '14. Worthlessness',
      'answers': [
        'I do not feel I am worthless.',
        'I don’t consider myself as worthwhile and useful as I used to.',
        'I feel more worthless as compared to others.',
        'I feel utterly worthless.'
      ],
    },
    {
      'question': '15. Loss of Energy',
      'answers': [
        'I have as much energy as ever.',
        'I have less energy than I used to have.',
        'I don’t have enough energy to do very much.',
        'I don’t have enough energy to do anything.'
      ],
    },
    {
      'question': '16. Changes in Sleeping Pattern',
      'answers': [
        'I have not experienced any change in my sleeping pattern.',
        'I sleep somewhat more/less than usual.',
        'I sleep a lot more/less than usual.',
        'I sleep most of the day or wake up 1–2 hours early and can’t get back to sleep.'
      ],
    },
    {
      'question': '17. Irritability',
      'answers': [
        'I am no more irritable than usual.',
        'I am more irritable than usual.',
        'I am much more irritable than usual.',
        'I am irritable all the time.'
      ],
    },
    {
      'question': '18. Changes in Appetite',
      'answers': [
        'I have not experienced any change in my appetite.',
        'My appetite is somewhat less/more than usual.',
        'My appetite is much less/more than before.',
        'I have no appetite at all or crave food all the time.'
      ],
    },
    {
      'question': '19. Concentration Difficulty',
      'answers': [
        'I can concentrate as well as ever.',
        'I can’t concentrate as well as usual.',
        'It’s hard to keep my mind on anything for very long.',
        'I find I can’t concentrate on anything.'
      ],
    },
    {
      'question': '20. Tiredness or Fatigue',
      'answers': [
        'I am no more tired or fatigued than usual.',
        'I get tired or fatigued more easily than usual.',
        'I am too tired or fatigued to do a lot of the things I used to do.',
        'I am too tired or fatigued to do most of the things I used to do.'
      ],
    },
    {
      'question': '21. Loss of Interest in Sex',
      'answers': [
        'I have not noticed any recent change in my interest in sex.',
        'I am less interested in sex than I used to be.',
        'I am much less interested in sex now.',
        'I have lost interest in sex completely.'
      ],
    },
  ];

  int _currentIndex = 0;
  final List<int> _answers = [];

  void _selectAnswer(int score) {
    setState(() {
      _answers.add(score);
      if (_currentIndex < _questions.length - 1) {
        _currentIndex++;
      } else {
        _showResult();
      }
    });
  }

void _showResult() {
  int total = _answers.reduce((a, b) => a + b);

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => DepressionResultScreen(score: total),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final question = _questions[_currentIndex];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Question ${_currentIndex + 1} of ${_questions.length}',
                style: GoogleFonts.poppins(fontSize: 18, color: Colors.purple.shade200),
              ),
              const SizedBox(height: 20),
              Text(
                question['question'],
                style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 30),
              ...List.generate(
                question['answers'].length,
                (index) => GestureDetector(
                  onTap: () => _selectAnswer(index),
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A40),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.purple.shade300.withAlpha((0.4 * 255).toInt())),
                    ),
                    child: Text(
                      question['answers'][index],
                      style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Center(
                child: Text(
                  'Tap an answer to continue',
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.white54),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
