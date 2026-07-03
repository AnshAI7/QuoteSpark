// QuoteSpark - A smart quote generator app
// Built with Flutter | Supports mood detection in Hindi & English
// Developer: Ansh Mishra | CodeAlpha Internship Project
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'dart:ui';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );
  runApp(const QuoteApp());
}

// ══════════════════════════════════════════════
//  MOOD CONFIG
//  Each mood has its own emoji, color and keyword list.
//  I added Hindi keywords so Indian users feel more connected.
// ══════════════════════════════════════════════

/// Stores mood data including emoji, label, color and detection keywords.
/// Keywords support both Hindi and English for Indian users.
class MoodConfig {
  final String emoji;
  final String label;
  final Color color;
  final List<String> keywords;
  const MoodConfig(this.emoji, this.label, this.color, this.keywords);
}

// Each mood has unique keywords for smart detection.
// I added Hindi words like 'dukh', 'khushi' to support Indian users.
const Map<String, MoodConfig> moodConfigs = {
  'motivated': MoodConfig('💪', 'Motivated', Color(0xFF6C63FF), [
    'motivat',
    'goal',
    'achieve',
    'work',
    'success',
    'hustle',
    'grind',
    'focus',
    'dream',
    'win',
    'start',
    'begin',
    'try',
    'effort',
    'hard',
    'improve',
    'grow',
    'build',
    'create',
    'study',
    'padhai',
    'kaam',
    'koshish',
    'mehnat',
    'aage',
    'target',
    'exam',
    'career',
    'job',
    'interview',
    'business',
    'startup',
    'inspire',
    'ambition',
    'passion',
  ]),
  'happy': MoodConfig('😊', 'Happy', Color(0xFFFFB300), [
    'happy',
    'joy',
    'smile',
    'laugh',
    'great',
    'amazing',
    'wonderful',
    'khush',
    'mast',
    'best',
    'awesome',
    'excited',
    'celebrate',
    'party',
    'fun',
    'enjoy',
    'good day',
    'blessed',
    'grateful',
    'thankful',
    'positive',
    'energy',
    'dance',
    'music',
    'friend',
    'birthday',
    'success',
    'achieve',
    'win',
    'maza',
    'khushi',
    'shukar',
  ]),
  'sad': MoodConfig('😔', 'Sad', Color(0xFF42A5F5), [
    'sad',
    'cry',
    'hurt',
    'pain',
    'miss',
    'alone',
    'dukh',
    'thaka',
    'bura',
    'upset',
    'breakup',
    'break up',
    'heartbreak',
    'heart break',
    'lonely',
    'lost',
    'failure',
    'fail',
    'depressed',
    'depression',
    'anxiety',
    'anxious',
    'stress',
    'tension',
    'worried',
    'hopeless',
    'give up',
    'tired',
    'exhausted',
    'broken',
    'rejected',
    'rejection',
    'divorce',
    'fight',
    'argument',
    'cheated',
    'betrayed',
    'rona',
    'akela',
    'tanha',
    'dard',
    'gam',
    'udaas',
    'pareshan',
    'tang',
    'disappoint',
    'regret',
    'guilt',
    'shame',
    'embarrass',
    'insecure',
  ]),
  'peaceful': MoodConfig('🧘', 'Peaceful', Color(0xFF26A69A), [
    'peace',
    'calm',
    'relax',
    'rest',
    'quiet',
    'meditat',
    'breath',
    'shanti',
    'sukoon',
    'still',
    'mindful',
    'mindfulness',
    'yoga',
    'nature',
    'sleep',
    'tired',
    'unwind',
    'chill',
    'slow down',
    'balance',
    'harmony',
    'zen',
    'serenity',
    'tranquil',
    'gentle',
    'soft',
    'morning',
    'evening',
    'sunset',
    'sunrise',
    'stars',
    'moon',
    'aram',
    'chain',
    'neend',
    'sona',
    'baith',
    'thak gaya',
  ]),
  'love': MoodConfig('❤️', 'Love', Color(0xFFEF5350), [
    'love',
    'heart',
    'romance',
    'pyar',
    'dil',
    'relationship',
    'care',
    'affection',
    'bond',
    'crush',
    'girlfriend',
    'boyfriend',
    'partner',
    'wife',
    'husband',
    'marriage',
    'couple',
    'date',
    'kiss',
    'hug',
    'miss you',
    'i miss',
    'thinking of you',
    'together',
    'forever',
    'soulmate',
    'true love',
    'unconditional',
    'family',
    'mom',
    'dad',
    'mother',
    'father',
    'parents',
    'baby',
    'ishq',
    'mohabbat',
    'yaar',
    'beloved',
    'darling',
    'sweetheart',
    'valentine',
    'propose',
  ]),
  'strong': MoodConfig('😤', 'Strong', Color(0xFFFF7043), [
    'strong',
    'fight',
    'never give up',
    'struggle',
    'power',
    'brave',
    'courage',
    'warrior',
    'rise',
    'conquer',
    'overcome',
    'challenge',
    'difficult',
    'hard time',
    'tough',
    'pain',
    'suffer',
    'battle',
    'survive',
    'resilient',
    'bounce back',
    'comeback',
    'phoenix',
    'unbreakable',
    'unstoppable',
    'fearless',
    'bold',
    'confidence',
    'determination',
    'willpower',
    'persist',
    'endure',
    'withstand',
    'himmat',
    'hausla',
    'josh',
    'takkat',
    'lad',
    'haar mat',
    'problem',
    'crisis',
    'obstacle',
    'setback',
    'recover',
  ]),
};

// ══════════════════════════════════════════════
//  DATA MODEL
//  timeOfDay field was my idea to make the app smarter.
//  Morning = motivation, night = peace - feels natural!
// ══════════════════════════════════════════════

/// Represents a single quote with its metadata.
/// timeOfDay field helps show relevant quotes based on time of day.
class Quote {
  final String text;
  final String author;
  final String category;
  final String mood;
  final Color cardColor;
  final String timeOfDay; // morning, afternoon, evening, night, all

  const Quote({
    required this.text,
    required this.author,
    required this.category,
    required this.mood,
    required this.cardColor,
    this.timeOfDay = 'all',
  });
}

// ══════════════════════════════════════════════
//  CARD THEME CONFIG
//  I wanted users to personalize the app - so I added 8 themes.
//  Each theme has a gradient and an icon that matches its vibe.
// ══════════════════════════════════════════════
class CardTheme {
  final String name;
  final List<Color> gradientColors;
  final IconData icon;
  const CardTheme(this.name, this.gradientColors, this.icon);
}

final List<CardTheme> cardThemes = [
  CardTheme('Default', [
    const Color(0xFF6C63FF),
    const Color(0xFF3B3486),
  ], Icons.auto_awesome),
  CardTheme('Sunset', [
    const Color(0xFFFF6B6B),
    const Color(0xFFFF8E53),
  ], Icons.wb_sunny),
  CardTheme('Ocean', [
    const Color(0xFF0093E9),
    const Color(0xFF80D0C7),
  ], Icons.waves),
  CardTheme('Forest', [
    const Color(0xFF11998E),
    const Color(0xFF38EF7D),
  ], Icons.forest),
  CardTheme('Galaxy', [
    const Color(0xFF2C3E50),
    const Color(0xFF4CA1AF),
  ], Icons.stars),
  CardTheme('Rose', [
    const Color(0xFFFF416C),
    const Color(0xFFFF4B2B),
  ], Icons.favorite),
  CardTheme('Gold', [
    const Color(0xFFF7971E),
    const Color(0xFFFFD200),
  ], Icons.emoji_events),
  CardTheme('Mint', [
    const Color(0xFF00B4DB),
    const Color(0xFF0083B0),
  ], Icons.spa),
];

// ══════════════════════════════════════════════
//  QUOTES DATABASE
//  I personally handpicked all these quotes.
//  Organized by time of day, mood and category.
//  Added a special India section with APJ, Gandhi, Vivekananda quotes.
// ══════════════════════════════════════════════
final List<Quote> allQuotes = [
  // MORNING QUOTES
  Quote(
    text: "Every morning we are born again. What we do today matters most.",
    author: "Buddha",
    category: "Motivation",
    mood: "motivated",
    cardColor: Color(0xFF6C63FF),
    timeOfDay: 'morning',
  ),
  Quote(
    text: "Rise up, start fresh see the bright opportunity in each day.",
    author: "Unknown",
    category: "Motivation",
    mood: "motivated",
    cardColor: Color(0xFF5C6BC0),
    timeOfDay: 'morning',
  ),
  Quote(
    text: "The morning was full of sunlight and hope.",
    author: "Kate Chopin",
    category: "Life",
    mood: "happy",
    cardColor: Color(0xFFFFB300),
    timeOfDay: 'morning',
  ),
  Quote(
    text:
        "Each morning when I open my eyes I say to myself: I, not events, have the power to make me happy or unhappy today.",
    author: "Groucho Marx",
    category: "Happiness",
    mood: "happy",
    cardColor: Color(0xFFF9A825),
    timeOfDay: 'morning',
  ),
  Quote(
    text:
        "Morning is an important time of day, because how you spend your morning can often tell you what kind of day you are going to have.",
    author: "Lemony Snicket",
    category: "Wisdom",
    mood: "peaceful",
    cardColor: Color(0xFF26A69A),
    timeOfDay: 'morning',
  ),
  Quote(
    text:
        "Today's goals: Coffee and kindness. Maybe two coffees, and then kindness.",
    author: "Nanea Hoffman",
    category: "Happiness",
    mood: "happy",
    cardColor: Color(0xFFFFB300),
    timeOfDay: 'morning',
  ),
  Quote(
    text: "An early-morning walk is a blessing for the whole day.",
    author: "Henry David Thoreau",
    category: "Peace",
    mood: "peaceful",
    cardColor: Color(0xFF26A69A),
    timeOfDay: 'morning',
  ),
  Quote(
    text: "With the new day comes new strength and new thoughts.",
    author: "Eleanor Roosevelt",
    category: "Motivation",
    mood: "motivated",
    cardColor: Color(0xFF6C63FF),
    timeOfDay: 'morning',
  ),
  Quote(
    text: "Morning not only forgives, it forgets.",
    author: "Marty Rubin",
    category: "Peace",
    mood: "peaceful",
    cardColor: Color(0xFF26A69A),
    timeOfDay: 'morning',
  ),
  Quote(
    text:
        "I wake up every morning at nine and grab for the morning paper. Then I look at the obituary page. If my name is not on it, I get up.",
    author: "Benjamin Franklin",
    category: "Happiness",
    mood: "happy",
    cardColor: Color(0xFFFFB300),
    timeOfDay: 'morning',
  ),

  // AFTERNOON QUOTES
  Quote(
    text:
        "Keep going. Each step may get harder, but don't stop. The view is beautiful at the top.",
    author: "Unknown",
    category: "Motivation",
    mood: "motivated",
    cardColor: Color(0xFFFF6F00),
    timeOfDay: 'afternoon',
  ),
  Quote(
    text: "The afternoon knows what the morning never suspected.",
    author: "Robert Frost",
    category: "Wisdom",
    mood: "peaceful",
    cardColor: Color(0xFF37474F),
    timeOfDay: 'afternoon',
  ),
  Quote(
    text: "When you feel like quitting, think about why you started.",
    author: "Unknown",
    category: "Motivation",
    mood: "motivated",
    cardColor: Color(0xFF6C63FF),
    timeOfDay: 'afternoon',
  ),
  Quote(
    text: "Push yourself, because no one else is going to do it for you.",
    author: "Unknown",
    category: "Motivation",
    mood: "motivated",
    cardColor: Color(0xFF5E35B1),
    timeOfDay: 'afternoon',
  ),
  Quote(
    text: "Success is not for the lazy.",
    author: "Unknown",
    category: "Success",
    mood: "motivated",
    cardColor: Color(0xFFFF6F00),
    timeOfDay: 'afternoon',
  ),
  Quote(
    text: "Don't stop when you're tired. Stop when you're done.",
    author: "Unknown",
    category: "Motivation",
    mood: "motivated",
    cardColor: Color(0xFFBF360C),
    timeOfDay: 'afternoon',
  ),
  Quote(
    text: "The secret of getting ahead is getting started.",
    author: "Mark Twain",
    category: "Success",
    mood: "motivated",
    cardColor: Color(0xFFFF8F00),
    timeOfDay: 'afternoon',
  ),
  Quote(
    text: "Work hard in silence, let your success be your noise.",
    author: "Frank Ocean",
    category: "Success",
    mood: "motivated",
    cardColor: Color(0xFF6C63FF),
    timeOfDay: 'afternoon',
  ),
  Quote(
    text: "Opportunities don't happen. You create them.",
    author: "Chris Grosser",
    category: "Success",
    mood: "motivated",
    cardColor: Color(0xFFFF6F00),
    timeOfDay: 'afternoon',
  ),
  Quote(
    text: "Great things never come from comfort zones.",
    author: "Unknown",
    category: "Motivation",
    mood: "motivated",
    cardColor: Color(0xFF5C6BC0),
    timeOfDay: 'afternoon',
  ),

  // EVENING QUOTES
  Quote(
    text:
        "Look back and be grateful, look ahead and be hopeful, look around and be helpful.",
    author: "Unknown",
    category: "Wisdom",
    mood: "peaceful",
    cardColor: Color(0xFF7E57C2),
    timeOfDay: 'evening',
  ),
  Quote(
    text:
        "The evening's the best part of the day. You've done your day's work. Now you can put your feet up and enjoy it.",
    author: "Kazuo Ishiguro",
    category: "Peace",
    mood: "peaceful",
    cardColor: Color(0xFF26A69A),
    timeOfDay: 'evening',
  ),
  Quote(
    text: "Take time to do what makes your soul happy.",
    author: "Unknown",
    category: "Happiness",
    mood: "happy",
    cardColor: Color(0xFFFFB300),
    timeOfDay: 'evening',
  ),
  Quote(
    text: "Every sunset brings the promise of a new dawn.",
    author: "Ralph Waldo Emerson",
    category: "Hope",
    mood: "peaceful",
    cardColor: Color(0xFFFF7043),
    timeOfDay: 'evening',
  ),
  Quote(
    text: "Sunsets are proof that endings can be beautiful.",
    author: "Unknown",
    category: "Peace",
    mood: "peaceful",
    cardColor: Color(0xFFFF5722),
    timeOfDay: 'evening',
  ),
  Quote(
    text: "Count your blessings, not your problems.",
    author: "Unknown",
    category: "Happiness",
    mood: "happy",
    cardColor: Color(0xFFFFB300),
    timeOfDay: 'evening',
  ),
  Quote(
    text:
        "At the end of the day, let there be no excuses, no explanations, no regrets.",
    author: "Steve Maraboli",
    category: "Wisdom",
    mood: "motivated",
    cardColor: Color(0xFF6C63FF),
    timeOfDay: 'evening',
  ),
  Quote(
    text: "What you do today can improve all your tomorrows.",
    author: "Ralph Marston",
    category: "Motivation",
    mood: "motivated",
    cardColor: Color(0xFF5E35B1),
    timeOfDay: 'evening',
  ),
  Quote(
    text:
        "Evening is a time of real experimentation. You never want to look the same way.",
    author: "Donna Karan",
    category: "Life",
    mood: "happy",
    cardColor: Color(0xFFFFB300),
    timeOfDay: 'evening',
  ),
  Quote(
    text: "In the evening of life, we will be judged on love alone.",
    author: "Saint John of the Cross",
    category: "Love",
    mood: "love",
    cardColor: Color(0xFFEF5350),
    timeOfDay: 'evening',
  ),

  // NIGHT QUOTES
  Quote(
    text: "The moon is a friend for the lonesome to talk to.",
    author: "Carl Sandburg",
    category: "Peace",
    mood: "peaceful",
    cardColor: Color(0xFF1A237E),
    timeOfDay: 'night',
  ),
  Quote(
    text: "Night is the other half of life, and the better half.",
    author: "Goethe",
    category: "Life",
    mood: "peaceful",
    cardColor: Color(0xFF283593),
    timeOfDay: 'night',
  ),
  Quote(
    text: "Stars can't shine without darkness.",
    author: "Unknown",
    category: "Strength",
    mood: "strong",
    cardColor: Color(0xFF1A237E),
    timeOfDay: 'night',
  ),
  Quote(
    text:
        "Every night is a chance to reset, recharge, and rise again tomorrow.",
    author: "Unknown",
    category: "Peace",
    mood: "peaceful",
    cardColor: Color(0xFF283593),
    timeOfDay: 'night',
  ),
  Quote(
    text: "The darkest hour has only sixty minutes.",
    author: "Morris Mandel",
    category: "Strength",
    mood: "strong",
    cardColor: Color(0xFF311B92),
    timeOfDay: 'night',
  ),
  Quote(
    text: "Goodnight, sleep tight. Tomorrow is a new opportunity.",
    author: "Unknown",
    category: "Peace",
    mood: "peaceful",
    cardColor: Color(0xFF1A237E),
    timeOfDay: 'night',
  ),
  Quote(
    text: "The night is more alive and more richly colored than the day.",
    author: "Vincent Van Gogh",
    category: "Life",
    mood: "peaceful",
    cardColor: Color(0xFF283593),
    timeOfDay: 'night',
  ),
  Quote(
    text: "I have loved the stars too fondly to be fearful of the night.",
    author: "Galileo",
    category: "Wisdom",
    mood: "peaceful",
    cardColor: Color(0xFF311B92),
    timeOfDay: 'night',
  ),
  Quote(
    text: "Sleep is the best meditation.",
    author: "Dalai Lama",
    category: "Peace",
    mood: "peaceful",
    cardColor: Color(0xFF1A237E),
    timeOfDay: 'night',
  ),
  Quote(
    text: "Let the soft animal of your body love what it loves.",
    author: "Mary Oliver",
    category: "Peace",
    mood: "peaceful",
    cardColor: Color(0xFF283593),
    timeOfDay: 'night',
  ),

  // MOTIVATION (ALL DAY)
  Quote(
    text: "The only way to do great work is to love what you do.",
    author: "Steve Jobs",
    category: "Motivation",
    mood: "motivated",
    cardColor: Color(0xFF6C63FF),
  ),
  Quote(
    text: "Believe you can and you're halfway there.",
    author: "Theodore Roosevelt",
    category: "Motivation",
    mood: "motivated",
    cardColor: Color(0xFF5C6BC0),
  ),
  Quote(
    text: "It does not matter how slowly you go as long as you do not stop.",
    author: "Confucius",
    category: "Motivation",
    mood: "motivated",
    cardColor: Color(0xFF7E57C2),
  ),
  Quote(
    text:
        "Success is not final, failure is not fatal: it is the courage to continue that counts.",
    author: "Winston Churchill",
    category: "Motivation",
    mood: "motivated",
    cardColor: Color(0xFF673AB7),
  ),
  Quote(
    text: "Dream it. Wish it. Do it.",
    author: "Unknown",
    category: "Motivation",
    mood: "motivated",
    cardColor: Color(0xFF6C63FF),
  ),
  Quote(
    text:
        "The harder you work for something, the greater you'll feel when you achieve it.",
    author: "Unknown",
    category: "Motivation",
    mood: "motivated",
    cardColor: Color(0xFF7C4DFF),
  ),
  Quote(
    text: "Do something today that your future self will thank you for.",
    author: "Unknown",
    category: "Motivation",
    mood: "motivated",
    cardColor: Color(0xFF5C6BC0),
  ),
  Quote(
    text: "Don't wait for opportunity. Create it.",
    author: "Unknown",
    category: "Motivation",
    mood: "motivated",
    cardColor: Color(0xFF7E57C2),
  ),
  Quote(
    text:
        "You don't have to be great to start, but you have to start to be great.",
    author: "Zig Ziglar",
    category: "Motivation",
    mood: "motivated",
    cardColor: Color(0xFF673AB7),
  ),
  Quote(
    text: "Your limitation is only your imagination.",
    author: "Unknown",
    category: "Motivation",
    mood: "motivated",
    cardColor: Color(0xFF6C63FF),
  ),
  Quote(
    text:
        "Sometimes we're tested not to show our weaknesses, but to discover our strengths.",
    author: "Unknown",
    category: "Motivation",
    mood: "motivated",
    cardColor: Color(0xFF5C6BC0),
  ),
  Quote(
    text: "The key to success is to focus on goals, not obstacles.",
    author: "Unknown",
    category: "Motivation",
    mood: "motivated",
    cardColor: Color(0xFF7E57C2),
  ),
  Quote(
    text: "Arise, awake and stop not till the goal is reached.",
    author: "Swami Vivekananda",
    category: "Motivation",
    mood: "motivated",
    cardColor: Color(0xFF6C63FF),
  ),
  Quote(
    text: "Take up one idea. Make that one idea your life.",
    author: "Swami Vivekananda",
    category: "Motivation",
    mood: "motivated",
    cardColor: Color(0xFF673AB7),
  ),
  Quote(
    text:
        "Dream is not that which you see while sleeping. It is something that does not let you sleep.",
    author: "A.P.J. Abdul Kalam",
    category: "Motivation",
    mood: "motivated",
    cardColor: Color(0xFF7C4DFF),
  ),

  // SUCCESS
  Quote(
    text: "Don't watch the clock; do what it does. Keep going.",
    author: "Sam Levenson",
    category: "Success",
    mood: "motivated",
    cardColor: Color(0xFFFF6F00),
  ),
  Quote(
    text:
        "Success usually comes to those who are too busy to be looking for it.",
    author: "Henry David Thoreau",
    category: "Success",
    mood: "motivated",
    cardColor: Color(0xFFFF8F00),
  ),
  Quote(
    text: "I find that the harder I work, the more luck I seem to have.",
    author: "Thomas Jefferson",
    category: "Success",
    mood: "motivated",
    cardColor: Color(0xFFF57F17),
  ),
  Quote(
    text: "Success is not owned. It is leased. And rent is due every day.",
    author: "J.J. Watt",
    category: "Success",
    mood: "motivated",
    cardColor: Color(0xFFFF6F00),
  ),
  Quote(
    text: "There are no shortcuts to any place worth going.",
    author: "Beverly Sills",
    category: "Success",
    mood: "motivated",
    cardColor: Color(0xFFFF8F00),
  ),
  Quote(
    text: "I never dreamed about success. I worked for it.",
    author: "Estée Lauder",
    category: "Success",
    mood: "motivated",
    cardColor: Color(0xFFF57F17),
  ),
  Quote(
    text:
        "Success is walking from failure to failure with no loss of enthusiasm.",
    author: "Winston Churchill",
    category: "Success",
    mood: "motivated",
    cardColor: Color(0xFFFF6F00),
  ),
  Quote(
    text: "Action is the foundational key to all success.",
    author: "Pablo Picasso",
    category: "Success",
    mood: "motivated",
    cardColor: Color(0xFFFF8F00),
  ),
  Quote(
    text: "Excellence is a continuous process and not an accident.",
    author: "A.P.J. Abdul Kalam",
    category: "Success",
    mood: "motivated",
    cardColor: Color(0xFFF57F17),
  ),
  Quote(
    text: "Don't stop when you're tired. Stop when you're done.",
    author: "Unknown",
    category: "Success",
    mood: "motivated",
    cardColor: Color(0xFFFF6F00),
  ),

  // LIFE
  Quote(
    text: "Life is what happens when you're busy making other plans.",
    author: "John Lennon",
    category: "Life",
    mood: "peaceful",
    cardColor: Color(0xFF2E7D32),
  ),
  Quote(
    text: "You only live once, but if you do it right, once is enough.",
    author: "Mae West",
    category: "Life",
    mood: "happy",
    cardColor: Color(0xFF43A047),
  ),
  Quote(
    text:
        "Life is not measured by the number of breaths we take, but by the moments that take our breath away.",
    author: "Maya Angelou",
    category: "Life",
    mood: "peaceful",
    cardColor: Color(0xFF2E7D32),
  ),
  Quote(
    text: "Life is really simple, but we insist on making it complicated.",
    author: "Confucius",
    category: "Life",
    mood: "peaceful",
    cardColor: Color(0xFF388E3C),
  ),
  Quote(
    text: "Your time is limited, don't waste it living someone else's life.",
    author: "Steve Jobs",
    category: "Life",
    mood: "motivated",
    cardColor: Color(0xFF43A047),
  ),
  Quote(
    text: "Life is either a daring adventure or nothing at all.",
    author: "Helen Keller",
    category: "Life",
    mood: "motivated",
    cardColor: Color(0xFF2E7D32),
  ),
  Quote(
    text:
        "In three words I can sum up everything I've learned about life: it goes on.",
    author: "Robert Frost",
    category: "Life",
    mood: "peaceful",
    cardColor: Color(0xFF388E3C),
  ),
  Quote(
    text: "You must be the change you wish to see in the world.",
    author: "Mahatma Gandhi",
    category: "Life",
    mood: "motivated",
    cardColor: Color(0xFF43A047),
  ),
  Quote(
    text: "Not how long, but how well you have lived is the main thing.",
    author: "Seneca",
    category: "Life",
    mood: "peaceful",
    cardColor: Color(0xFF2E7D32),
  ),
  Quote(
    text: "The purpose of our lives is to be happy.",
    author: "Dalai Lama",
    category: "Life",
    mood: "happy",
    cardColor: Color(0xFF388E3C),
  ),

  // WISDOM
  Quote(
    text: "The only true wisdom is in knowing you know nothing.",
    author: "Socrates",
    category: "Wisdom",
    mood: "peaceful",
    cardColor: Color(0xFF37474F),
  ),
  Quote(
    text: "The journey of a thousand miles begins with one step.",
    author: "Lao Tzu",
    category: "Wisdom",
    mood: "peaceful",
    cardColor: Color(0xFF455A64),
  ),
  Quote(
    text:
        "Do not go where the path may lead, go instead where there is no path and leave a trail.",
    author: "Ralph Waldo Emerson",
    category: "Wisdom",
    mood: "motivated",
    cardColor: Color(0xFF546E7A),
  ),
  Quote(
    text:
        "The greatest glory in living lies not in never falling, but in rising every time we fall.",
    author: "Nelson Mandela",
    category: "Wisdom",
    mood: "strong",
    cardColor: Color(0xFF37474F),
  ),
  Quote(
    text:
        "Do not dwell in the past, do not dream of the future, concentrate the mind on the present moment.",
    author: "Buddha",
    category: "Wisdom",
    mood: "peaceful",
    cardColor: Color(0xFF455A64),
  ),
  Quote(
    text:
        "Good judgment comes from experience, and experience comes from bad judgment.",
    author: "Rita Mae Brown",
    category: "Wisdom",
    mood: "peaceful",
    cardColor: Color(0xFF546E7A),
  ),
  Quote(
    text: "If you tell the truth, you don't have to remember anything.",
    author: "Mark Twain",
    category: "Wisdom",
    mood: "peaceful",
    cardColor: Color(0xFF37474F),
  ),
  Quote(
    text: "The unexamined life is not worth living.",
    author: "Socrates",
    category: "Wisdom",
    mood: "peaceful",
    cardColor: Color(0xFF455A64),
  ),
  Quote(
    text: "Yesterday is history, tomorrow is a mystery, today is a gift.",
    author: "Bill Keane",
    category: "Wisdom",
    mood: "peaceful",
    cardColor: Color(0xFF546E7A),
  ),
  Quote(
    text: "Have no fear of perfection — you'll never reach it.",
    author: "Salvador Dalí",
    category: "Wisdom",
    mood: "peaceful",
    cardColor: Color(0xFF37474F),
  ),

  // HAPPINESS
  Quote(
    text:
        "Happiness is not something ready made. It comes from your own actions.",
    author: "Dalai Lama",
    category: "Happiness",
    mood: "happy",
    cardColor: Color(0xFFF9A825),
  ),
  Quote(
    text: "For every minute you are angry you lose sixty seconds of happiness.",
    author: "Ralph Waldo Emerson",
    category: "Happiness",
    mood: "happy",
    cardColor: Color(0xFFF57F17),
  ),
  Quote(
    text: "The most important thing is to enjoy your life — to be happy.",
    author: "Audrey Hepburn",
    category: "Happiness",
    mood: "happy",
    cardColor: Color(0xFFFFB300),
  ),
  Quote(
    text:
        "Count your age by friends, not years. Count your life by smiles, not tears.",
    author: "John Lennon",
    category: "Happiness",
    mood: "happy",
    cardColor: Color(0xFFF9A825),
  ),
  Quote(
    text: "Joy is not in things; it is in us.",
    author: "Richard Wagner",
    category: "Happiness",
    mood: "happy",
    cardColor: Color(0xFFF57F17),
  ),
  Quote(
    text: "Be happy for this moment. This moment is your life.",
    author: "Omar Khayyam",
    category: "Happiness",
    mood: "happy",
    cardColor: Color(0xFFFFB300),
  ),
  Quote(
    text:
        "The happiness of your life depends upon the quality of your thoughts.",
    author: "Marcus Aurelius",
    category: "Happiness",
    mood: "happy",
    cardColor: Color(0xFFF9A825),
  ),
  Quote(
    text: "Be the reason someone smiles today.",
    author: "Unknown",
    category: "Happiness",
    mood: "happy",
    cardColor: Color(0xFFF57F17),
  ),
  Quote(
    text:
        "Happiness is not something you postpone for the future; it is something you design for the present.",
    author: "Jim Rohn",
    category: "Happiness",
    mood: "happy",
    cardColor: Color(0xFFFFB300),
  ),
  Quote(
    text:
        "True happiness is to enjoy the present, without anxious dependence upon the future.",
    author: "Seneca",
    category: "Happiness",
    mood: "happy",
    cardColor: Color(0xFFF9A825),
  ),

  // LOVE
  Quote(
    text: "The best thing to hold onto in life is each other.",
    author: "Audrey Hepburn",
    category: "Love",
    mood: "love",
    cardColor: Color(0xFFC62828),
  ),
  Quote(
    text: "Where there is love there is life.",
    author: "Mahatma Gandhi",
    category: "Love",
    mood: "love",
    cardColor: Color(0xFFD32F2F),
  ),
  Quote(
    text: "Love is composed of a single soul inhabiting two bodies.",
    author: "Aristotle",
    category: "Love",
    mood: "love",
    cardColor: Color(0xFFE53935),
  ),
  Quote(
    text: "To love and be loved is to feel the sun from both sides.",
    author: "David Viscott",
    category: "Love",
    mood: "love",
    cardColor: Color(0xFFC62828),
  ),
  Quote(
    text: "The greatest happiness of life is the conviction that we are loved.",
    author: "Victor Hugo",
    category: "Love",
    mood: "love",
    cardColor: Color(0xFFD32F2F),
  ),
  Quote(
    text:
        "Being deeply loved by someone gives you strength, while loving someone deeply gives you courage.",
    author: "Lao Tzu",
    category: "Love",
    mood: "love",
    cardColor: Color(0xFFE53935),
  ),
  Quote(
    text:
        "You know you're in love when you can't fall asleep because reality is finally better than your dreams.",
    author: "Dr. Seuss",
    category: "Love",
    mood: "love",
    cardColor: Color(0xFFC62828),
  ),
  Quote(
    text:
        "The best love is the kind that awakens the soul and makes us reach for more.",
    author: "Nicholas Sparks",
    category: "Love",
    mood: "love",
    cardColor: Color(0xFFD32F2F),
  ),
  Quote(
    text: "A heart that loves is always young.",
    author: "Greek Proverb",
    category: "Love",
    mood: "love",
    cardColor: Color(0xFFE53935),
  ),
  Quote(
    text:
        "Love is not about how many days, months, or years you have been together. Love is about how much you love each other every single day.",
    author: "Unknown",
    category: "Love",
    mood: "love",
    cardColor: Color(0xFFC62828),
  ),

  // PEACE
  Quote(
    text: "Peace comes from within. Do not seek it without.",
    author: "Buddha",
    category: "Peace",
    mood: "peaceful",
    cardColor: Color(0xFF00695C),
  ),
  Quote(
    text: "Nothing can bring you peace but yourself.",
    author: "Ralph Waldo Emerson",
    category: "Peace",
    mood: "peaceful",
    cardColor: Color(0xFF00796B),
  ),
  Quote(
    text:
        "Inner peace begins the moment you choose not to allow another person or event to control your emotions.",
    author: "Pema Chödrön",
    category: "Peace",
    mood: "peaceful",
    cardColor: Color(0xFF00897B),
  ),
  Quote(
    text: "Do not let the behavior of others destroy your inner peace.",
    author: "Dalai Lama",
    category: "Peace",
    mood: "peaceful",
    cardColor: Color(0xFF00695C),
  ),
  Quote(
    text: "Peace begins with a smile.",
    author: "Mother Teresa",
    category: "Peace",
    mood: "peaceful",
    cardColor: Color(0xFF00796B),
  ),
  Quote(
    text: "In the midst of movement and chaos, keep stillness inside of you.",
    author: "Deepak Chopra",
    category: "Peace",
    mood: "peaceful",
    cardColor: Color(0xFF00897B),
  ),
  Quote(
    text:
        "Almost everything will work again if you unplug it for a few minutes, including you.",
    author: "Anne Lamott",
    category: "Peace",
    mood: "peaceful",
    cardColor: Color(0xFF00695C),
  ),
  Quote(
    text:
        "Not all storms come to disrupt your life, some come to clear your path.",
    author: "Unknown",
    category: "Peace",
    mood: "peaceful",
    cardColor: Color(0xFF00796B),
  ),
  Quote(
    text: "Breathing in, I calm body and mind. Breathing out, I smile.",
    author: "Thich Nhat Hanh",
    category: "Peace",
    mood: "peaceful",
    cardColor: Color(0xFF00897B),
  ),
  Quote(
    text: "Sometimes the most productive thing you can do is relax.",
    author: "Mark Black",
    category: "Peace",
    mood: "peaceful",
    cardColor: Color(0xFF00695C),
  ),

  // STRENGTH
  Quote(
    text:
        "You never know how strong you are until being strong is the only choice you have.",
    author: "Bob Marley",
    category: "Strength",
    mood: "strong",
    cardColor: Color(0xFFBF360C),
  ),
  Quote(
    text: "Fall seven times, stand up eight.",
    author: "Japanese Proverb",
    category: "Strength",
    mood: "strong",
    cardColor: Color(0xFFD84315),
  ),
  Quote(
    text:
        "Strength does not come from physical capacity. It comes from an indomitable will.",
    author: "Mahatma Gandhi",
    category: "Strength",
    mood: "strong",
    cardColor: Color(0xFFE64A19),
  ),
  Quote(
    text: "Out of suffering have emerged the strongest souls.",
    author: "Khalil Gibran",
    category: "Strength",
    mood: "strong",
    cardColor: Color(0xFFBF360C),
  ),
  Quote(
    text: "Turn your wounds into wisdom.",
    author: "Oprah Winfrey",
    category: "Strength",
    mood: "strong",
    cardColor: Color(0xFFD84315),
  ),
  Quote(
    text: "Courage is not the absence of fear, but the triumph over it.",
    author: "Nelson Mandela",
    category: "Strength",
    mood: "strong",
    cardColor: Color(0xFFE64A19),
  ),
  Quote(
    text: "Pain is temporary. Quitting lasts forever.",
    author: "Lance Armstrong",
    category: "Strength",
    mood: "strong",
    cardColor: Color(0xFFBF360C),
  ),
  Quote(
    text: "A smooth sea never made a skilled sailor.",
    author: "Franklin D. Roosevelt",
    category: "Strength",
    mood: "strong",
    cardColor: Color(0xFFD84315),
  ),
  Quote(
    text: "Rock bottom will teach you lessons that mountain tops never will.",
    author: "Unknown",
    category: "Strength",
    mood: "strong",
    cardColor: Color(0xFFE64A19),
  ),
  Quote(
    text: "Every storm runs out of rain.",
    author: "Maya Angelou",
    category: "Strength",
    mood: "strong",
    cardColor: Color(0xFFBF360C),
  ),

  // HEALING
  Quote(
    text: "This too shall pass.",
    author: "Persian Proverb",
    category: "Healing",
    mood: "sad",
    cardColor: Color(0xFF1565C0),
  ),
  Quote(
    text: "The wound is the place where the Light enters you.",
    author: "Rumi",
    category: "Healing",
    mood: "sad",
    cardColor: Color(0xFF1976D2),
  ),
  Quote(
    text:
        "You don't have to control your thoughts. You just have to stop letting them control you.",
    author: "Dan Millman",
    category: "Healing",
    mood: "sad",
    cardColor: Color(0xFF1E88E5),
  ),
  Quote(
    text: "The pain you feel today is the strength you feel tomorrow.",
    author: "Unknown",
    category: "Healing",
    mood: "sad",
    cardColor: Color(0xFF1565C0),
  ),
  Quote(
    text:
        "You are allowed to be both a masterpiece and a work in progress simultaneously.",
    author: "Sophia Bush",
    category: "Healing",
    mood: "sad",
    cardColor: Color(0xFF1976D2),
  ),
  Quote(
    text: "Sometimes it's okay if the only thing you did today was breathe.",
    author: "Unknown",
    category: "Healing",
    mood: "sad",
    cardColor: Color(0xFF1E88E5),
  ),
  Quote(
    text: "Be gentle with yourself. You are a child of the universe.",
    author: "Max Ehrmann",
    category: "Healing",
    mood: "sad",
    cardColor: Color(0xFF1565C0),
  ),
  Quote(
    text: "Even the darkest night will end and the sun will rise.",
    author: "Victor Hugo",
    category: "Healing",
    mood: "sad",
    cardColor: Color(0xFF1976D2),
  ),
  Quote(
    text: "It's okay to not be okay — as long as you are not giving up.",
    author: "Karen Salmansohn",
    category: "Healing",
    mood: "sad",
    cardColor: Color(0xFF1E88E5),
  ),
  Quote(
    text:
        "Every day may not be good, but there is something good in every day.",
    author: "Alice Morse Earle",
    category: "Healing",
    mood: "sad",
    cardColor: Color(0xFF1565C0),
  ),

  // FRIENDSHIP
  Quote(
    text:
        "A real friend is one who walks in when the rest of the world walks out.",
    author: "Walter Winchell",
    category: "Friendship",
    mood: "happy",
    cardColor: Color(0xFF6A1B9A),
  ),
  Quote(
    text:
        "Friendship is born at that moment when one person says to another: What! You too?",
    author: "C.S. Lewis",
    category: "Friendship",
    mood: "happy",
    cardColor: Color(0xFF7B1FA2),
  ),
  Quote(
    text: "A friend is someone who knows all about you and still loves you.",
    author: "Elbert Hubbard",
    category: "Friendship",
    mood: "happy",
    cardColor: Color(0xFF8E24AA),
  ),
  Quote(
    text: "Friends are the family we choose for ourselves.",
    author: "Edna Buchanan",
    category: "Friendship",
    mood: "happy",
    cardColor: Color(0xFF6A1B9A),
  ),
  Quote(
    text:
        "Walking with a friend in the dark is better than walking alone in the light.",
    author: "Helen Keller",
    category: "Friendship",
    mood: "peaceful",
    cardColor: Color(0xFF7B1FA2),
  ),
  Quote(
    text: "The greatest gift of life is friendship.",
    author: "Hubert H. Humphrey",
    category: "Friendship",
    mood: "happy",
    cardColor: Color(0xFF8E24AA),
  ),
  Quote(
    text:
        "A friend who understands your tears is much more valuable than a lot of friends who only know your smile.",
    author: "Unknown",
    category: "Friendship",
    mood: "peaceful",
    cardColor: Color(0xFF6A1B9A),
  ),
  Quote(
    text: "Friendship multiplies the good of life and divides the evil.",
    author: "Baltasar Gracian",
    category: "Friendship",
    mood: "happy",
    cardColor: Color(0xFF7B1FA2),
  ),
  Quote(
    text:
        "True friendship comes when the silence between two people is comfortable.",
    author: "David Tyson",
    category: "Friendship",
    mood: "peaceful",
    cardColor: Color(0xFF8E24AA),
  ),
  Quote(
    text:
        "A good friend is like a four-leaf clover; hard to find and lucky to have.",
    author: "Irish Proverb",
    category: "Friendship",
    mood: "happy",
    cardColor: Color(0xFF6A1B9A),
  ),

  // EDUCATION
  Quote(
    text:
        "Education is the most powerful weapon which you can use to change the world.",
    author: "Nelson Mandela",
    category: "Education",
    mood: "motivated",
    cardColor: Color(0xFF00838F),
  ),
  Quote(
    text: "An investment in knowledge pays the best interest.",
    author: "Benjamin Franklin",
    category: "Education",
    mood: "motivated",
    cardColor: Color(0xFF0097A7),
  ),
  Quote(
    text:
        "Live as if you were to die tomorrow. Learn as if you were to live forever.",
    author: "Mahatma Gandhi",
    category: "Education",
    mood: "motivated",
    cardColor: Color(0xFF00ACC1),
  ),
  Quote(
    text:
        "The beautiful thing about learning is that nobody can take it away from you.",
    author: "B.B. King",
    category: "Education",
    mood: "motivated",
    cardColor: Color(0xFF00838F),
  ),
  Quote(
    text: "Education is not the filling of a pail, but the lighting of a fire.",
    author: "William Butler Yeats",
    category: "Education",
    mood: "motivated",
    cardColor: Color(0xFF0097A7),
  ),
  Quote(
    text: "A person who never made a mistake never tried anything new.",
    author: "Albert Einstein",
    category: "Education",
    mood: "motivated",
    cardColor: Color(0xFF00ACC1),
  ),
  Quote(
    text: "The more I learn, the more I realize how much I don't know.",
    author: "Albert Einstein",
    category: "Education",
    mood: "peaceful",
    cardColor: Color(0xFF00838F),
  ),
  Quote(
    text: "Knowledge is power. Information is liberating.",
    author: "Kofi Annan",
    category: "Education",
    mood: "motivated",
    cardColor: Color(0xFF0097A7),
  ),
  Quote(
    text:
        "The capacity to learn is a gift; the ability to learn is a skill; the willingness to learn is a choice.",
    author: "Brian Herbert",
    category: "Education",
    mood: "motivated",
    cardColor: Color(0xFF00ACC1),
  ),
  Quote(
    text:
        "Develop a passion for learning. If you do, you will never cease to grow.",
    author: "Anthony J. D'Angelo",
    category: "Education",
    mood: "motivated",
    cardColor: Color(0xFF00838F),
  ),

  // INDIA
  Quote(
    text:
        "A nation's culture resides in the hearts and in the soul of its people.",
    author: "Mahatma Gandhi",
    category: "India",
    mood: "peaceful",
    cardColor: Color(0xFFE65100),
  ),
  Quote(
    text:
        "The best way to find yourself is to lose yourself in the service of others.",
    author: "Mahatma Gandhi",
    category: "India",
    mood: "peaceful",
    cardColor: Color(0xFFF4511E),
  ),
  Quote(
    text: "Be the change you wish to see in the world.",
    author: "Mahatma Gandhi",
    category: "India",
    mood: "motivated",
    cardColor: Color(0xFFFF5722),
  ),
  Quote(
    text: "In a gentle way, you can shake the world.",
    author: "Mahatma Gandhi",
    category: "India",
    mood: "peaceful",
    cardColor: Color(0xFFE65100),
  ),
  Quote(
    text:
        "Where there is righteousness in the heart, there is beauty in the character.",
    author: "A.P.J. Abdul Kalam",
    category: "India",
    mood: "peaceful",
    cardColor: Color(0xFFF4511E),
  ),
  Quote(
    text: "If you want to shine like a sun, first burn like a sun.",
    author: "A.P.J. Abdul Kalam",
    category: "India",
    mood: "motivated",
    cardColor: Color(0xFFFF5722),
  ),
  Quote(
    text: "You have to dream before your dreams can come true.",
    author: "A.P.J. Abdul Kalam",
    category: "India",
    mood: "motivated",
    cardColor: Color(0xFFE65100),
  ),
  Quote(
    text:
        "Man needs difficulties in life because they are necessary to enjoy success.",
    author: "A.P.J. Abdul Kalam",
    category: "India",
    mood: "motivated",
    cardColor: Color(0xFFF4511E),
  ),
  Quote(
    text: "One best book is equal to a hundred good friends.",
    author: "A.P.J. Abdul Kalam",
    category: "India",
    mood: "peaceful",
    cardColor: Color(0xFFFF5722),
  ),
  Quote(
    text: "You cannot shake hands with a clenched fist.",
    author: "Indira Gandhi",
    category: "India",
    mood: "peaceful",
    cardColor: Color(0xFFE65100),
  ),
];

// ══════════════════════════════════════════════
//  PARTICLE MODEL
//  Stores position, size, speed and opacity of each floating particle.
// ══════════════════════════════════════════════
class Particle {
  double x, y, size, speed, opacity;
  Particle(this.x, this.y, this.size, this.speed, this.opacity);
}

// ══════════════════════════════════════════════
//  PARTICLE PAINTER
//  Draws floating particles on canvas for premium background effect.
//  I added this to make the quote card feel more alive and dynamic.
// ══════════════════════════════════════════════
class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final Color color;
  ParticlePainter(this.particles, this.color);

  /// Draws each particle as a circle on the canvas.
  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final paint = Paint()
        ..color = color.withValues(alpha: p.opacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(p.x * size.width, p.y * size.height),
        p.size,
        paint,
      );
    }
  }

  // Returns true to always repaint for smooth particle animation.
  @override
  bool shouldRepaint(ParticlePainter old) => true;
}

// ══════════════════════════════════════════════
//  APP ROOT
//  Entry point of the app. Sets up MaterialApp with theme and home page.
// ══════════════════════════════════════════════
class QuoteApp extends StatelessWidget {
  const QuoteApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuoteSpark',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, fontFamily: 'Georgia'),
      home: const QuoteHomePage(),
    );
  }
}

// ══════════════════════════════════════════════
//  HOME PAGE
//  Main screen with quote display, filters, mood picker and favorites.
// ══════════════════════════════════════════════
class QuoteHomePage extends StatefulWidget {
  const QuoteHomePage({super.key});
  @override
  State<QuoteHomePage> createState() => _QuoteHomePageState();
}

class _QuoteHomePageState extends State<QuoteHomePage>
    with TickerProviderStateMixin {
  final Random _random = Random();

  // Quote state
  Quote _currentQuote = allQuotes[0];
  final List<Quote> _shownQuotes = [];
  final List<Quote> _favorites = [];

  // Filters
  String _selectedCategory = 'All';
  String _selectedMood = 'All';
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();

  // UI state
  bool _showFavorites = false;
  bool _showSearch = false;
  int _selectedThemeIndex = 0;

  // Streak
  int _streak = 1;
  String _lastVisitDate = '';

  // Animations
  late AnimationController _fadeCtrl;
  late AnimationController _scaleCtrl;
  late AnimationController _particleCtrl;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  // Particles
  final List<Particle> _particles = [];

  // Swipe
  double _dragStart = 0;

  // All 13 categories available in the app for filtering quotes
  static const List<String> _categories = [
    'All',
    'Motivation',
    'Success',
    'Life',
    'Wisdom',
    'Happiness',
    'Love',
    'Peace',
    'Strength',
    'Healing',
    'Friendship',
    'Education',
    'India',
  ];

  // ── Time of day greeting ──────────────────────
  String get _timeGreeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning ☀️';
    if (hour < 17) return 'Good Afternoon 🌤️';
    if (hour < 21) return 'Good Evening 🌅';
    return 'Good Night 🌙';
  }

  // Returns time of day string used for filtering time-based quotes
  String get _currentTimeOfDay {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    if (hour < 21) return 'evening';
    return 'night';
  }

  // ── Mood detection from text ──────────────────
  // Scans search input for Hindi and English keywords to detect user mood.
  // Returns 'All' if no mood keyword is found in the text.
  String _detectMoodFromText(String text) {
    if (text.isEmpty) return 'All';
    final lower = text.toLowerCase();
    for (final entry in moodConfigs.entries) {
      for (final keyword in entry.value.keywords) {
        if (lower.contains(keyword)) return entry.key;
      }
    }
    return 'All';
  }

  /// Called once when the screen loads.
  /// Initializes particles, animations and loads first quote.
  @override
  void initState() {
    super.initState();

    // Generate 20 particles with random properties
    for (int i = 0; i < 20; i++) {
      _particles.add(
        Particle(
          _random.nextDouble(),
          _random.nextDouble(),
          _random.nextDouble() * 3 + 1,
          _random.nextDouble() * 0.5 + 0.1,
          _random.nextDouble() * 0.3 + 0.05,
        ),
      );
    }

    // Setup fade and scale animations for quote transitions
    _fadeCtrl = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleCtrl = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _particleCtrl = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _fadeAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn));
    _scaleAnim = Tween<double>(
      begin: 0.88,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _scaleCtrl, curve: Curves.elasticOut));
    // Move particles upward on each frame, reset when they go off screen
    _particleCtrl.addListener(() {
      setState(() {
        for (final p in _particles) {
          p.y -= p.speed * 0.003;
          if (p.y < 0) {
            p.y = 1.0;
            p.x = _random.nextDouble();
          }
        }
      });
    });

    // Streak check
    final today = DateTime.now().toIso8601String().substring(0, 10);
    if (_lastVisitDate != today) {
      setState(() {
        _lastVisitDate = today;
        _streak++;
      });
    }

    _pickQuoteForTimeOfDay();
  }

  /// Frees memory by disposing all animation controllers when screen closes.
  @override
  void dispose() {
    _fadeCtrl.dispose();
    _scaleCtrl.dispose();
    _particleCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Filtered pool ─────────────────────────────
  // Filters quotes based on selected category, mood and search query.
  List<Quote> get _filteredPool {
    return allQuotes.where((q) {
      final catOk =
          _selectedCategory == 'All' || q.category == _selectedCategory;
      final moodOk = _selectedMood == 'All' || q.mood == _selectedMood;
      final searchOk =
          _searchQuery.isEmpty ||
          q.text.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          q.author.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          q.category.toLowerCase().contains(_searchQuery.toLowerCase());
      return catOk && moodOk && searchOk;
    }).toList();
  }

  /// Selects a quote based on current time of day.
  /// Morning shows motivational quotes, night shows peaceful ones.
  void _pickQuoteForTimeOfDay() {
    final timeOfDay = _currentTimeOfDay;
    final timeQuotes = allQuotes
        .where((q) => q.timeOfDay == timeOfDay)
        .toList();
    if (timeQuotes.isNotEmpty &&
        _selectedCategory == 'All' &&
        _selectedMood == 'All' &&
        _searchQuery.isEmpty) {
      final unshown = timeQuotes
          .where((q) => !_shownQuotes.contains(q))
          .toList();
      final source = unshown.isEmpty ? timeQuotes : unshown;
      setState(() {
        _currentQuote = source[_random.nextInt(source.length)];
      });
    } else {
      _pickNewQuote();
    }
    _animate();
  }

  /// Smart shuffle algorithm - never repeats a quote until all are shown.
  /// Resets the history once every quote has been displayed once.
  void _pickNewQuote() {
    final pool = _filteredPool;
    if (pool.isEmpty) return;
    final unshown = pool.where((q) => !_shownQuotes.contains(q)).toList();
    final source = unshown.isEmpty ? pool : unshown;
    Quote next;
    do {
      next = source[_random.nextInt(source.length)];
    } while (next == _currentQuote && source.length > 1);
    setState(() {
      _currentQuote = next;
      _shownQuotes.add(next);
      if (_shownQuotes.length > allQuotes.length) _shownQuotes.clear();
    });
    _animate();
  }

  // Resets and plays fade and scale animations for smooth quote transition.
  void _animate() {
    _fadeCtrl.reset();
    _scaleCtrl.reset();
    _fadeCtrl.forward();
    _scaleCtrl.forward();
  }

  // Called when user taps a category chip - resets history and loads new quote.
  void _onCategoryTap(String cat) {
    setState(() {
      _selectedCategory = cat;
      _shownQuotes.clear();
    });
    _pickNewQuote();
  }

  // Toggles mood filter on/off - tapping same mood resets to 'All'.
  void _onMoodTap(String mood) {
    setState(() {
      _selectedMood = mood == _selectedMood ? 'All' : mood;
      _shownQuotes.clear();
    });
    _pickNewQuote();
  }

  // Copies current quote text and author to clipboard.
  void _copyQuote() {
    Clipboard.setData(
      ClipboardData(text: '"${_currentQuote.text}"\n— ${_currentQuote.author}'),
    );
    _showSnack('Quote copied!', Icons.check_circle, Colors.green[700]!);
  }

  // Adds or removes current quote from favorites list.
  // Shows a snackbar notification after the action.
  void _toggleFavorite() {
    setState(() {
      _favorites.contains(_currentQuote)
          ? _favorites.remove(_currentQuote)
          : _favorites.add(_currentQuote);
    });
    _showSnack(
      _favorites.contains(_currentQuote) ? 'Added to favorites!' : 'Removed!',
      _favorites.contains(_currentQuote)
          ? Icons.favorite
          : Icons.favorite_border,
      _favorites.contains(_currentQuote) ? Colors.red : Colors.grey,
    );
  }

  // Returns true if current quote is already saved in favorites.
  bool get _isFav => _favorites.contains(_currentQuote);

  // Displays a floating notification at the bottom of the screen.
  // Used for copy, favorite and other user actions.
  void _showSnack(String msg, IconData icon, Color color) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(msg),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Returns gradient colors based on selected theme or quote's own color.
  List<Color> get _activeGradient {
    if (_selectedThemeIndex == 0) {
      return [
        _currentQuote.cardColor,
        _currentQuote.cardColor.withValues(alpha: 0.6),
        Colors.black.withValues(alpha: 0.4),
      ];
    }
    final theme = cardThemes[_selectedThemeIndex];
    return [...theme.gradientColors, Colors.black.withValues(alpha: 0.3)];
  }

  // Returns the primary accent color for buttons and highlights.
  Color get _accentColor => _selectedThemeIndex == 0
      ? _currentQuote.cardColor
      : cardThemes[_selectedThemeIndex].gradientColors[0];

  /// Builds the main scaffold - switches between home and favorites screen.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080808),
      body: SafeArea(child: _showFavorites ? _buildFavScreen() : _buildMain()),
    );
  }

  // ══════════════════════════════════════════════
  //  MAIN SCREEN
  //  Combines top bar, filters, quote card, streak and action buttons.
  // ══════════════════════════════════════════════
  Widget _buildMain() {
    return Column(
      children: [
        _buildTopBar(),
        if (_showSearch) _buildSearchBar(),
        _buildFilterRow(),
        Expanded(
          child: GestureDetector(
            onHorizontalDragStart: (d) => _dragStart = d.globalPosition.dx,
            onHorizontalDragEnd: (d) {
              final diff = d.globalPosition.dx - _dragStart;
              if (diff.abs() > 50) _pickNewQuote();
            },
            child: _buildQuoteCard(),
          ),
        ),
        _buildStreakBar(),
        _buildActions(),
        const SizedBox(height: 16),
      ],
    );
  }

  // ── Top Bar ───────────────────────────────────
  // ── Top Bar ──────────────────────────────────
  // Shows app name, time greeting and action icon buttons.
  // Uses MediaQuery for responsive sizing across all phone sizes.
  Widget _buildTopBar() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final titleSize = isSmallScreen ? 18.0 : 22.0;
    final iconSize = isSmallScreen ? 16.0 : 20.0;
    final iconPadding = isSmallScreen ? 7.0 : 9.0;
    final hPadding = isSmallScreen ? 12.0 : 16.0;
    final spacing = isSmallScreen ? 4.0 : 6.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(hPadding, 14, hPadding, 6),
      child: Row(
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'QuoteSpark ✨',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: titleSize,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _timeGreeting,
                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _iconBtn(
            Icons.search_rounded,
            () => setState(() => _showSearch = !_showSearch),
            iconSize,
            iconPadding,
          ),
          SizedBox(width: spacing),
          _iconBtn(
            Icons.palette_rounded,
            _showThemePicker,
            iconSize,
            iconPadding,
          ),
          SizedBox(width: spacing),
          Stack(
            children: [
              _iconBtn(
                Icons.favorite_rounded,
                () => setState(() => _showFavorites = true),
                iconSize,
                iconPadding,
              ),
              if (_favorites.isNotEmpty)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${_favorites.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // Reusable icon button widget used in the top bar.
  Widget _iconBtn(
    IconData icon,
    VoidCallback fn, [
    double iconSize = 20,
    double padding = 9,
  ]) {
    return GestureDetector(
      onTap: fn,
      child: Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[800]!),
        ),
        child: Icon(icon, color: Colors.white70, size: iconSize),
      ),
    );
  }

  // ── Search Bar ────────────────────────────────
  // Smart search that also detects mood from typed keywords.
  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        MediaQuery.of(context).size.width < 360 ? 12 : 16,
        4,
        MediaQuery.of(context).size.width < 360 ? 12 : 16,
        8,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _accentColor.withValues(alpha: 0.4)),
        ),
        child: TextField(
          controller: _searchCtrl,
          autofocus: true,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Search or describe your mood...',
            hintStyle: TextStyle(color: Colors.grey[600], fontSize: 13),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: Colors.grey[600],
              size: 20,
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey, size: 18),
                    onPressed: () {
                      _searchCtrl.clear();
                      setState(() {
                        _searchQuery = '';
                        _selectedMood = 'All';
                      });
                      _pickNewQuote();
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          onChanged: (val) {
            final detectedMood = _detectMoodFromText(val);
            setState(() {
              _searchQuery = val;
              if (detectedMood != 'All') _selectedMood = detectedMood;
            });
            if (val.isNotEmpty) _pickNewQuote();
          },
        ),
      ),
    );
  }

  // ── Filter Row (Mood + Categories in one line) ─
  // Single scrollable row with mood dropdown and category chips.
  Widget _buildFilterRow() {
    final activeMood = _selectedMood != 'All'
        ? moodConfigs[_selectedMood]
        : null;
    return SizedBox(
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // Mood button
          GestureDetector(
            onTap: _showMoodPicker,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: activeMood != null
                    ? activeMood.color
                    : const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: activeMood != null
                      ? activeMood.color
                      : Colors.grey[700]!,
                ),
                boxShadow: activeMood != null
                    ? [
                        BoxShadow(
                          color: activeMood.color.withValues(alpha: 0.4),
                          blurRadius: 8,
                        ),
                      ]
                    : [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (activeMood != null) ...[
                    Text(
                      activeMood.emoji,
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      activeMood.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                  ] else ...[
                    const Icon(
                      Icons.mood_rounded,
                      color: Colors.white60,
                      size: 15,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Mood',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                    const SizedBox(width: 3),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.white38,
                      size: 14,
                    ),
                  ],
                ],
              ),
            ),
          ),
          // Category chips
          ..._categories.map((cat) {
            final sel = _selectedCategory == cat;
            return GestureDetector(
              onTap: () => _onCategoryTap(cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: sel ? _accentColor : const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: sel ? _accentColor : Colors.grey[800]!,
                  ),
                ),
                child: Text(
                  cat,
                  style: TextStyle(
                    color: sel ? Colors.white : Colors.grey[500],
                    fontSize: 12,
                    fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Quote Card with Particles ─────────────────
  // Main quote display card with gradient, floating particles and animations.
  // Supports swipe gesture to load next quote.
  Widget _buildQuoteCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: FadeTransition(
        opacity: _fadeAnim,
        child: ScaleTransition(
          scale: _scaleAnim,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _activeGradient,
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: _accentColor.withValues(alpha: 0.4),
                  blurRadius: 30,
                  spreadRadius: 2,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Stack(
                children: [
                  // Particle background
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: _particleCtrl,
                      builder: (_, __) => CustomPaint(
                        painter: ParticlePainter(_particles, Colors.white),
                      ),
                    ),
                  ),
                  // Glass overlay
                  Positioned.fill(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
                      child: Container(color: Colors.transparent),
                    ),
                  ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Quote icon circle
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                          child: const Icon(
                            Icons.format_quote_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 22),
                        // Quote text
                        Text(
                          '"${_currentQuote.text}"',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontStyle: FontStyle.italic,
                            height: 1.75,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 22),
                        // Divider
                        Container(
                          width: 36,
                          height: 1.5,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 14),
                        // Author
                        Text(
                          '— ${_currentQuote.author}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 14),
                        // Tags
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _tag(_currentQuote.category),
                            const SizedBox(width: 8),
                            _tag(moodConfigs[_currentQuote.mood]?.emoji ?? ''),
                            if (_currentQuote.timeOfDay != 'all') ...[
                              const SizedBox(width: 8),
                              _tag(_timeOfDayEmoji(_currentQuote.timeOfDay)),
                            ],
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Swipe hint
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.swipe_rounded,
                              color: Colors.white.withValues(alpha: 0.35),
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Swipe for next',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.35),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Returns emoji based on time of day for the quote card tag.
  String _timeOfDayEmoji(String t) {
    switch (t) {
      case 'morning':
        return '☀️';
      case 'afternoon':
        return '🌤️';
      case 'evening':
        return '🌅';
      case 'night':
        return '🌙';
      default:
        return '';
    }
  }

  // Builds a small pill-shaped tag widget for category and mood display.
  Widget _tag(String label) {
    if (label.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  // ── Streak Bar ────────────────────────────────
  // Shows daily streak count with 7 dot indicators to motivate daily use.
  Widget _buildStreakBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey[800]!),
        ),
        child: Row(
          children: [
            const Text('🔥', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Text(
              '$_streak Day Streak',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Text(
              'Keep it up!',
              style: TextStyle(color: Colors.grey[500], fontSize: 11),
            ),
            const SizedBox(width: 8),
            // Mini streak dots
            Row(
              children: List.generate(
                7,
                (i) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(left: 3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i < _streak ? _accentColor : Colors.grey[800],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Actions ───────────────────────────────────
  // New Quote button and Save, Copy, Shuffle action buttons.
  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        children: [
          // New Quote Button
          GestureDetector(
            onTap: _pickNewQuote,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_accentColor, _accentColor.withValues(alpha: 0.7)],
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: _accentColor.withValues(alpha: 0.4),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'New Quote',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          // 3 action buttons
          Row(
            children: [
              Expanded(
                child: _actionBtn(
                  _isFav
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  _isFav ? 'Saved' : 'Save',
                  _isFav ? Colors.red[900]! : const Color(0xFF1A1A1A),
                  _toggleFavorite,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _actionBtn(
                  Icons.copy_rounded,
                  'Copy',
                  const Color(0xFF1A1A1A),
                  _copyQuote,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _actionBtn(
                  Icons.shuffle_rounded,
                  'Shuffle',
                  const Color(0xFF1A1A1A),
                  _pickNewQuote,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Reusable action button widget for Save, Copy and Shuffle buttons.
  Widget _actionBtn(IconData icon, String label, Color bg, VoidCallback fn) {
    return GestureDetector(
      onTap: fn,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey[800]!),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Mood Picker Bottom Sheet ──────────────────
  // Shows a bottom sheet with all 6 moods for user to select and filter quotes.
  void _showMoodPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111111),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Choose Your Mood',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedMood = 'All';
                        _shownQuotes.clear();
                      });
                      _pickNewQuote();
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Reset',
                        style: TextStyle(color: Colors.white60, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Tap a mood to filter quotes',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: moodConfigs.entries.map((e) {
                  final sel = _selectedMood == e.key;
                  return GestureDetector(
                    onTap: () {
                      _onMoodTap(e.key);
                      Navigator.pop(ctx);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: sel ? e.value.color : const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: sel ? e.value.color : Colors.grey[800]!,
                        ),
                        boxShadow: sel
                            ? [
                                BoxShadow(
                                  color: e.value.color.withValues(alpha: 0.4),
                                  blurRadius: 10,
                                ),
                              ]
                            : [],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            e.value.emoji,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            e.value.label,
                            style: TextStyle(
                              color: sel ? Colors.white : Colors.grey[300],
                              fontSize: 14,
                              fontWeight: sel
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          if (sel) ...[
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 14,
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ── Theme Picker ──────────────────────────────
  // Shows 8 card themes in a bottom sheet for user to personalize the app.
  void _showThemePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111111),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Card Theme',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Customize your quote card look',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: cardThemes.length,
                  itemBuilder: (_, i) {
                    final theme = cardThemes[i];
                    final sel = _selectedThemeIndex == i;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedThemeIndex = i);
                        setModal(() {});
                      },
                      child: Container(
                        width: 70,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: theme.gradientColors,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: sel ? Colors.white : Colors.transparent,
                            width: 2.5,
                          ),
                          boxShadow: sel
                              ? [
                                  BoxShadow(
                                    color: theme.gradientColors[0].withValues(
                                      alpha: 0.5,
                                    ),
                                    blurRadius: 12,
                                  ),
                                ]
                              : [],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(theme.icon, color: Colors.white, size: 22),
                            const SizedBox(height: 6),
                            Text(
                              theme.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════
  //  FAVORITES SCREEN
  //  Displays all saved quotes with option to remove them.
  // ══════════════════════════════════════════════
  Widget _buildFavScreen() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _showFavorites = false),
                child: Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[800]!),
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              const Text(
                'My Favorites',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${_favorites.length} saved',
                style: TextStyle(color: Colors.grey[500], fontSize: 13),
              ),
            ],
          ),
        ),
        Expanded(
          child: _favorites.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite_border_rounded,
                        color: Colors.grey[800],
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No favorites yet',
                        style: TextStyle(color: Colors.grey[600], fontSize: 17),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap ♥ on any quote to save it',
                        style: TextStyle(color: Colors.grey[700], fontSize: 13),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _favorites.length,
                  itemBuilder: (_, i) {
                    final q = _favorites[i];
                    final color = _selectedThemeIndex == 0
                        ? q.cardColor
                        : cardThemes[_selectedThemeIndex].gradientColors[0];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            color.withValues(alpha: 0.25),
                            color.withValues(alpha: 0.08),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: color.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '"${q.text}"',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '— ${q.author}',
                                style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              GestureDetector(
                                onTap: () =>
                                    setState(() => _favorites.remove(q)),
                                child: const Icon(
                                  Icons.favorite_rounded,
                                  color: Colors.red,
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
