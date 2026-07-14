import 'quiz_question.dart';

/// Mock question sets, one per [QuizCategory.sample] name — 5 questions
/// each. Placeholder content: once the quiz data layer exists, these
/// come from `GET /api/categories/{id}/questions/` instead.
abstract final class QuizQuestionBank {
  static List<QuizQuestion> forCategory(String categoryName) {
    return _byCategory[categoryName] ?? _byCategory['Math']!;
  }

  static const Map<String, List<QuizQuestion>> _byCategory = {
    'Math': [
      QuizQuestion(
        text: 'What is 12 × 8?',
        options: ['86', '96', '104', '108'],
        correctIndex: 1,
      ),
      QuizQuestion(
        text: 'What is the square root of 144?',
        options: ['10', '11', '12', '14'],
        correctIndex: 2,
      ),
      QuizQuestion(
        text: 'What is 15% of 200?',
        options: ['20', '25', '30', '35'],
        correctIndex: 2,
      ),
      QuizQuestion(
        text: 'Solve: 7 + 6 × 3',
        options: ['39', '25', '21', '18'],
        correctIndex: 1,
      ),
      QuizQuestion(
        text: 'What is the value of π (rounded to 2 decimals)?',
        options: ['3.14', '3.41', '2.71', '3.16'],
        correctIndex: 0,
      ),
    ],
    'History': [
      QuizQuestion(
        text: 'In which year did Uzbekistan gain independence?',
        options: ['1989', '1991', '1993', '1995'],
        correctIndex: 1,
      ),
      QuizQuestion(
        text: 'Who was the first president of Uzbekistan?',
        options: ['Islam Karimov', 'Shavkat Mirziyoyev', 'Amir Temur', 'Alisher Navoi'],
        correctIndex: 0,
      ),
      QuizQuestion(
        text: 'The Silk Road connected which two continents?',
        options: ['Europe & Africa', 'Asia & Europe', 'Asia & America', 'Africa & America'],
        correctIndex: 1,
      ),
      QuizQuestion(
        text: 'Which ancient city is known as the "Pearl of the East"?',
        options: ['Bukhara', 'Samarkand', 'Khiva', 'Tashkent'],
        correctIndex: 1,
      ),
      QuizQuestion(
        text: 'In what century did Amir Temur (Tamerlane) build his empire?',
        options: ['12th', '13th', '14th', '16th'],
        correctIndex: 2,
      ),
    ],
    'English': [
      QuizQuestion(
        text: 'What is the plural of "child"?',
        options: ['Childs', 'Children', 'Childes', 'Childrens'],
        correctIndex: 1,
      ),
      QuizQuestion(
        text: 'Choose the correct synonym for "happy":',
        options: ['Sad', 'Angry', 'Joyful', 'Tired'],
        correctIndex: 2,
      ),
      QuizQuestion(
        text: 'Which word is a verb?',
        options: ['Quickly', 'Beautiful', 'Run', 'Chair'],
        correctIndex: 2,
      ),
      QuizQuestion(
        text: 'What is the past tense of "go"?',
        options: ['Goed', 'Gone', 'Went', 'Going'],
        correctIndex: 2,
      ),
      QuizQuestion(
        text: 'Fill in the blank: "She ___ to school every day."',
        options: ['go', 'goes', 'going', 'gone'],
        correctIndex: 1,
      ),
    ],
    'Movies': [
      QuizQuestion(
        text: 'Which movie features a character named Jack Dawson?',
        options: ['Titanic', 'Avatar', 'Inception', 'Gladiator'],
        correctIndex: 0,
      ),
      QuizQuestion(
        text: 'Who directed "Jurassic Park"?',
        options: ['James Cameron', 'Steven Spielberg', 'Christopher Nolan', 'Ridley Scott'],
        correctIndex: 1,
      ),
      QuizQuestion(
        text: 'Which superhero wears a red and blue suit with a spider emblem?',
        options: ['Batman', 'Superman', 'Spider-Man', 'Iron Man'],
        correctIndex: 2,
      ),
      QuizQuestion(
        text: 'Which studio created "Toy Story"?',
        options: ['DreamWorks', 'Pixar', 'Disney', 'Illumination'],
        correctIndex: 1,
      ),
      QuizQuestion(
        text: 'Which of these is an animated film?',
        options: ['Titanic', 'Gladiator', 'Avatar', 'Toy Story'],
        correctIndex: 3,
      ),
    ],
    'Football': [
      QuizQuestion(
        text: 'How many players are on a football team on the field at once?',
        options: ['9', '10', '11', '12'],
        correctIndex: 2,
      ),
      QuizQuestion(
        text: 'Which country won the 2022 FIFA World Cup?',
        options: ['France', 'Brazil', 'Argentina', 'Germany'],
        correctIndex: 2,
      ),
      QuizQuestion(
        text: 'How long is a standard football match (excluding stoppage time)?',
        options: ['80 minutes', '90 minutes', '100 minutes', '120 minutes'],
        correctIndex: 1,
      ),
      QuizQuestion(
        text: 'What is it called when a player scores 3 goals in one match?',
        options: ['Double', 'Hat-trick', 'Triple play', 'Grand slam'],
        correctIndex: 1,
      ),
      QuizQuestion(
        text: 'Which position is primarily responsible for stopping goals?',
        options: ['Striker', 'Midfielder', 'Goalkeeper', 'Defender'],
        correctIndex: 2,
      ),
    ],
    'Memes': [
      QuizQuestion(
        text: 'What does "LOL" commonly stand for?',
        options: ['Lots of Love', 'Laugh Out Loud', 'Lack of Logic', 'Live on Line'],
        correctIndex: 1,
      ),
      QuizQuestion(
        text: 'A "meme" was originally described as a unit of what?',
        options: ['Cultural transmission', 'Currency', 'Data storage', 'Sound'],
        correctIndex: 0,
      ),
      QuizQuestion(
        text: 'Which emoji is commonly used to express laughter?',
        options: ['😢', '😂', '😡', '😴'],
        correctIndex: 1,
      ),
      QuizQuestion(
        text: 'What internet term describes something spreading quickly online?',
        options: ['Viral', 'Frozen', 'Static', 'Local'],
        correctIndex: 0,
      ),
      QuizQuestion(
        text: '"Rickrolling" is a prank involving which artist\'s song?',
        options: ['Michael Jackson', 'Rick Astley', 'Elvis Presley', 'Freddie Mercury'],
        correctIndex: 1,
      ),
    ],
  };
}
