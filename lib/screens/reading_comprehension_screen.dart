// lib/screens/reading_comprehension_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math'; // Necessary for Random
import 'package:playmobil_app/currency_manager.dart'; // Ensure path is correct
import 'package:playmobil_app/achievements.dart'; // Ensure path is correct
import 'package:flutter/foundation.dart'; // IMPORTANT for debugPrint!

class ReadingComprehensionScreen extends StatefulWidget {
  final String usuario;

  const ReadingComprehensionScreen({super.key, required this.usuario});

  @override
  State<ReadingComprehensionScreen> createState() =>
      _ReadingComprehensionScreenState();
}

class _ReadingComprehensionScreenState
    extends State<ReadingComprehensionScreen> {
  // Universal game identifier for Reading Comprehension
  static const String _gameNameIdentifier = 'comprension_lectora'; // Added for clarity

  final String storyTitle = "The crazy fashion show";
  final String storyText = """
It’s a sunny afternoon, and the children are getting ready for the school fashion show. Everyone is excited!

Tom is wearing a funny hat and a green jacket.
Lily is putting on a pink dress and shiny shoes.
Ben is not wearing socks—he is wearing slippers!
Emma is laughing. She is wearing sunglasses and a big yellow scarf.

“Look at me!” says Max. “I am wearing my dad’s trousers!”
“Wow!” says everyone. “You look so silly!”

The music is playing. The children are walking on the stage.
They are smiling, dancing, and having fun.
The teachers are clapping and taking pictures.

What a crazy fashion show!
""";

  // Here we will define the questions
  final List<Map<String, String>> readingQuestions = [
    {
      "question": "What is Tom wearing?",
      "answer": "A funny hat and a green jacket.",
    },
    {
      "question": "Is Ben wearing socks? What is he wearing?",
      "answer": "He is wearing slippers.",
    },
    {
      "question": "Why is Emma laughing?",
      "answer": "Because she is wearing sunglasses and a big yellow scarf.",
    },
    {
      "question": "What are the children doing on the stage?",
      "answer": "Walking, smiling, dancing and having fun.",
    },
    {
      "question": "What are the children getting ready for?",
      "answer": "For the school fashion show.",
    },
  ];
  final List<Map<String, dynamic>> multipleChoiceQuestions = [
    {
      "question": "What is Lily putting on?",
      "options": ["A red dress.", "A pink dress.", "A blue skirt."],
      "correctAnswer": "b",
    },
    {
      "question": "What is Emma wearing?",
      "options": [
        "A yellow hat.",
        "Sunglasses and a scarf.",
        "A pink T-shirt.",
      ],
      "correctAnswer": "b",
    },
    {
      "question": "What are the children doing on the stage?",
      "options": ["Sleeping.", "Reading.", "Dancing."],
      "correctAnswer": "c",
    },
    {
      "question": "What are the teachers doing?",
      "options": ["Singing.", "Clapping.", "Running."],
      "correctAnswer": "b",
    },
    {
      "question": "What is the story about?",
      "options": ["A party.", "A trip.", "A fashion show."],
      "correctAnswer": "c",
    },
  ];

  // State for multiple choice answers
  final Map<int, int?> _selectedMultipleChoiceOptionIndexes = {};

  // State for True/False answers
  final Map<int, bool?> _selectedTrueFalseAnswers = {};

  final List<Map<String, dynamic>> trueFalseQuestions = [
    {"question": "Tom is wearing a green jacket.", "correctAnswer": true},
    {"question": "Lily is wearing a blue dress.", "correctAnswer": false},
    {"question": "Ben is wearing slippers.", "correctAnswer": true},
    {"question": "Emma is crying.", "correctAnswer": false},
    {"question": "Max is wearing his dad’s trousers.", "correctAnswer": true},
  ];

  // New state variables for the matching game (Block 1)
  List<String> _shuffledAnswersBlock1 = []; // Shuffled answers
  int? _selectedQuestionIndexBlock1; // Selected question index
  int? _selectedShuffledAnswerIndexBlock1; // Selected shuffled answer index

  // Map to save correct pairs: key=question index, value=original answer index
  Map<int, int> _correctlyMatchedPairsBlock1 = {};
  // Sets to know which elements have already been matched and should not be selectable
  Set<int> _matchedQuestionIndexesBlock1 = {};
  Set<int> _matchedShuffledAnswerIndexesBlock1 = {};

  @override
  void initState() {
    super.initState();
    // Prepare shuffled answers for block 1
    _shuffledAnswersBlock1 = readingQuestions.map((q) => q['answer']!).toList();
    _shuffledAnswersBlock1.shuffle(Random());
  }

  void _handleQuestionTapBlock1(int questionIndex) {
    if (_matchedQuestionIndexesBlock1.contains(questionIndex))
      return; // Already matched

    setState(() {
      if (_selectedQuestionIndexBlock1 == questionIndex) {
        _selectedQuestionIndexBlock1 = null; // Deselect if tapped again
      } else {
        _selectedQuestionIndexBlock1 = questionIndex;
        if (_selectedShuffledAnswerIndexBlock1 != null) {
          _checkMatchBlock1();
        }
      }
    });
  }

  void _handleAnswerTapBlock1(int shuffledAnswerIndex) {
    if (_matchedShuffledAnswerIndexesBlock1.contains(shuffledAnswerIndex))
      return; // Already matched

    setState(() {
      if (_selectedShuffledAnswerIndexBlock1 == shuffledAnswerIndex) {
        _selectedShuffledAnswerIndexBlock1 = null; // Deselect if tapped again
      } else {
        _selectedShuffledAnswerIndexBlock1 = shuffledAnswerIndex;
        if (_selectedQuestionIndexBlock1 != null) {
          _checkMatchBlock1();
        }
      }
    });
  }

  void _checkMatchBlock1() {
    if (_selectedQuestionIndexBlock1 == null ||
        _selectedShuffledAnswerIndexBlock1 == null) {
      return;
    }

    final selectedQuestion = readingQuestions[_selectedQuestionIndexBlock1!];
    final selectedShuffledAnswer =
        _shuffledAnswersBlock1[_selectedShuffledAnswerIndexBlock1!];

    if (selectedQuestion['answer'] == selectedShuffledAnswer) {
      // Correct pair!
      // We need to find the original index of the answer for _correctlyMatchedPairsBlock1
      int originalAnswerIndex = readingQuestions.indexWhere(
        (q) => q['answer'] == selectedShuffledAnswer,
      );

      if (originalAnswerIndex != -1) {
        // Should always find it
        _correctlyMatchedPairsBlock1[_selectedQuestionIndexBlock1!] =
            originalAnswerIndex;
        _matchedQuestionIndexesBlock1.add(_selectedQuestionIndexBlock1!);
        _matchedShuffledAnswerIndexesBlock1.add(
          _selectedShuffledAnswerIndexBlock1!,
        );
      }

      debugPrint( // Use debugPrint for debug messages
          "Correct! Question: ${selectedQuestion['question']} - Answer: $selectedShuffledAnswer"); // Translated
    } else {
      // Incorrect pair
      debugPrint("Incorrect. Try again."); // Translated
    }

    // Clear selections after attempt
    _selectedQuestionIndexBlock1 = null;
    _selectedShuffledAnswerIndexBlock1 = null;

    // Force rebuild to reflect changes (e.g., colors of matched elements)
    setState(() {});
  }

  Future<void> _calculateAndShowScore() async {
    // Count of correct answers by block
    int correctAnswersBlock1 = _correctlyMatchedPairsBlock1.length;
    int correctAnswersMultipleChoice = 0;
    _selectedMultipleChoiceOptionIndexes.forEach((
      questionIndex,
      selectedOptionIndex,
    ) {
      if (selectedOptionIndex != null) {
        String correctAnswerChar =
            multipleChoiceQuestions[questionIndex]['correctAnswer'] as String;
        String selectedAnswerChar = String.fromCharCode(
          97 + selectedOptionIndex,
        );
        if (selectedAnswerChar == correctAnswerChar) {
          correctAnswersMultipleChoice++;
        }
      }
    });
    int correctAnswersTrueFalse = 0;
    _selectedTrueFalseAnswers.forEach((questionIndex, selectedAnswer) {
      if (selectedAnswer != null) {
        bool correctAnswerBool =
            trueFalseQuestions[questionIndex]['correctAnswer'] as bool;
        if (selectedAnswer == correctAnswerBool) {
          correctAnswersTrueFalse++;
        }
      }
    });

    // Definition of points per correct answer
    const int puntosPorAciertoBloque1 = 20; // Points per correct answer Block 1
    const int puntosPorAciertoBloque2 = 15; // Points per correct answer Block 2
    const int puntosPorAciertoBloque3 = 10; // Points per correct answer Block 3

    // Calculation of numeric score per block
    int puntuacionBloque1 = correctAnswersBlock1 * puntosPorAciertoBloque1;
    int puntuacionBloque2 =
        correctAnswersMultipleChoice * puntosPorAciertoBloque2;
    int puntuacionBloque3 = correctAnswersTrueFalse * puntosPorAciertoBloque3;

    // Calculation of total numeric score
    int totalPuntuacionNumerica =
        puntuacionBloque1 + puntuacionBloque2 + puntuacionBloque3;

    // Assuming a 'normal' difficulty for this game, as it doesn't have a difficulty selector.
    const String gameDifficulty = 'normal';

    // New debugPrints before calling guardarPuntuacion!
    debugPrint('*** ReadingComprehensionScreen: STARTING CALL TO SAVE SCORE ***'); // Translated
    debugPrint('  gameNameIdentifier: "$_gameNameIdentifier"');
    debugPrint('  score: $totalPuntuacionNumerica'); // Translated
    debugPrint('  user: "${widget.usuario}"'); // Translated
    debugPrint('  gameDifficulty (FINAL): "$gameDifficulty"'); // Should be 'normal' // Translated
    debugPrint('*** END CALL TO SAVE SCORE ***'); // Translated

    // Save score with CurrencyManager
    await CurrencyManager.guardarPuntuacion(
      _gameNameIdentifier, // Use the constant here
      totalPuntuacionNumerica,
      widget.usuario,
      gameDifficulty,
    );

    // Save the numeric score in SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final keyPuntuaciones = 'puntuaciones_comprension_lectora_${widget.usuario}';
    List<String> puntuacionesAnteriores =
        prefs.getStringList(keyPuntuaciones) ?? [];
    puntuacionesAnteriores.add(totalPuntuacionNumerica.toString());
    await prefs.setStringList(keyPuntuaciones, puntuacionesAnteriores);


    // Calculate and add coins
    int monedasGanadas = CurrencyManager.calcularRecompensa(
      gameDifficulty,
      totalPuntuacionNumerica,
    );
    await CurrencyManager.addMonedas(monedasGanadas, widget.usuario);

    // Verify achievements
    // --- KEY CORRECTION HERE ---
    await AchievementManager.verificarLogros(
      widget.usuario, // The first argument is the user
      _gameNameIdentifier, // The second argument is the gameNameIdentifier
      gameDifficulty,      // The third argument is the difficulty
      totalPuntuacionNumerica, // The fourth argument is the score
    );

    // Content of the final dialog
    List<Widget> dialogContent = [
      const Text(
        'Attempt Completed!', // Translated
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 16),
      Text('Total Score Obtained: $totalPuntuacionNumerica points'), // Translated
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.monetization_on, color: Colors.amber, size: 20),
          const SizedBox(width: 4),
          Text(
            'Coins Earned: $monedasGanadas', // Translated
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
      const SizedBox(height: 16),
      const Text(
        'Summary of Correct Answers:', // Translated
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      Text(
        'Match Questions: $correctAnswersBlock1 of ${readingQuestions.length} ($puntuacionBloque1 points)', // Translated
      ),
      Text(
        'Multiple Choice: $correctAnswersMultipleChoice of ${multipleChoiceQuestions.length} ($puntuacionBloque2 points)', // Translated
      ),
      Text(
        'True/False: $correctAnswersTrueFalse of ${trueFalseQuestions.length} ($puntuacionBloque3 points)', // Translated
      ),
      const SizedBox(height: 24),
      const Text(
        'Review - Reading Comprehension Questions (Matched):', // Translated
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
    ];

    for (int i = 0; i < readingQuestions.length; i++) {
      String userAnswerDisplay = "Not matched"; // Translated
      bool wasCorrect = _correctlyMatchedPairsBlock1.containsKey(i);
      if (wasCorrect) {
        userAnswerDisplay =
            readingQuestions[_correctlyMatchedPairsBlock1[i]!]['answer']!;
      }
      dialogContent.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${i + 1}. ${readingQuestions[i]['question']}",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: wasCorrect ? Colors.green : Colors.black,
                ),
              ),
              Text(
                "Your match: ${wasCorrect ? userAnswerDisplay : 'Not matched correctly'}", // Translated
              ),
              if (!wasCorrect)
                Text("Correct answer: ${readingQuestions[i]['answer']}"), // Translated
            ],
          ),
        ),
      );
    }

    if (mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'Attempt Finished!', // Translated
            ),
            content: SingleChildScrollView(
              child: ListBody(children: dialogContent),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'), // Translated
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  Navigator.of(context).pop(); // Go back to the previous screen
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "$storyTitle - ${widget.usuario}",
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              storyTitle,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(storyText, style: const TextStyle(fontSize: 16, height: 1.5)),
            const SizedBox(height: 24),

            // --- BLOCK 1: Match Question with Answer ---
            const Text(
              "Match the Question with its Answer:", // Translated
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Questions Column
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: readingQuestions.length,
                      itemBuilder: (context, index) {
                        final questionItem = readingQuestions[index];
                        bool isSelected = _selectedQuestionIndexBlock1 == index;
                        bool isMatched = _matchedQuestionIndexesBlock1.contains(
                          index,
                        );

                        return Card(
                          color:
                              isMatched
                                  ? Colors.green.shade100
                                  : (isSelected ? Colors.blue.shade100 : null),
                          child: ListTile(
                            title: Text(
                              "${index + 1}. ${questionItem['question']!}",
                            ),
                            onTap: () => _handleQuestionTapBlock1(index),
                            enabled: !isMatched,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Shuffled Answers Column
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _shuffledAnswersBlock1.length,
                      itemBuilder: (context, index) {
                        final answerText = _shuffledAnswersBlock1[index];
                        bool isSelected =
                            _selectedShuffledAnswerIndexBlock1 == index;
                        bool isMatched = _matchedShuffledAnswerIndexesBlock1
                            .contains(index);

                        return Card(
                          color:
                              isMatched
                                  ? Colors.green.shade100
                                  : (isSelected
                                        ? Colors.orange.shade100
                                        : null),
                          child: ListTile(
                            title: Text(answerText),
                            onTap: () => _handleAnswerTapBlock1(index),
                            enabled: !isMatched,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section for Multiple Choice Questions
            const Text(
              "Multiple Choice Questions:", // Translated
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: multipleChoiceQuestions.length,
              itemBuilder: (context, questionIndex) {
                final item = multipleChoiceQuestions[questionIndex];
                final List<String> options = item['options'] as List<String>;
                // final String correctAnswerChar = item['correctAnswer'] as String; // Not used directly here

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${questionIndex + 1}. ${item['question']}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Show options as RadioListTile for single selection
                      for (
                          int optionIndex = 0;
                          optionIndex < options.length;
                          optionIndex++
                      )
                        RadioListTile<int>(
                          title: Text(
                            "${String.fromCharCode(97 + optionIndex)}) ${options[optionIndex]}",
                          ),
                          value: optionIndex,
                          groupValue:
                              _selectedMultipleChoiceOptionIndexes[questionIndex],
                          onChanged: (int? value) {
                            setState(() {
                              _selectedMultipleChoiceOptionIndexes[questionIndex] =
                                  value;
                            });
                          },
                          activeColor: Theme.of(context).colorScheme.primary,
                        ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            // Section for True or False Questions
            const Text(
              "True or False:", // Translated
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: trueFalseQuestions.length,
              itemBuilder: (context, questionIndex) {
                final item = trueFalseQuestions[questionIndex];
                // final bool correctAnswer = item['correctAnswer'] as bool; // Not used directly here

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${questionIndex + 1}. ${item['question']}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: RadioListTile<bool>(
                              title: const Text('True'), // Translated
                              value: true,
                              groupValue:
                                  _selectedTrueFalseAnswers[questionIndex],
                              onChanged: (bool? value) {
                                setState(() {
                                  _selectedTrueFalseAnswers[questionIndex] =
                                      value;
                                });
                              },
                              activeColor:
                                  Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<bool>(
                              title: const Text('False'), // Translated
                              value: false,
                              groupValue:
                                  _selectedTrueFalseAnswers[questionIndex],
                              onChanged: (bool? value) {
                                setState(() {
                                  _selectedTrueFalseAnswers[questionIndex] =
                                      value;
                                });
                              },
                              activeColor:
                                  Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 32), // Space before the button
            Center(
              child: ElevatedButton(
                onPressed: _calculateAndShowScore,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 15,
                  ),
                  textStyle: const TextStyle(fontSize: 18, color: Colors.white),
                ),
                child: const Text(
                  'Finish Attempt', // Translated
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16), // Space after the button
          ],
        ),
      ),
    );
  }
}
