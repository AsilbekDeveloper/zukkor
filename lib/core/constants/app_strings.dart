import '../utils/formatters.dart';

/// ALL user-facing text in the app lives here.
/// Screen code never hardcodes text directly — only through AppStrings.
/// (When multi-language support is added later, only this file changes.)
abstract final class AppStrings {
  // Common
  static const String appName = 'Zukkor';
  static const String appTagline = 'Knowledge competition';
  static const String ok = 'OK';
  static const String cancel = 'Cancel';
  static const String retry = 'Retry';
  static const String loading = 'Loading...';

  // Home
  static const String homeGreeting = 'Good morning';
  static const String duelHeroTitle = "Who's strong today?";
  static const String duelHeroSubtitle = 'Challenge a friend or a random opponent';
  static const String startDuel = 'Start a duel';
  static const String totalXpLabel = 'Total XP';
  static const String rankLabel = 'Rank';
  static const String levelLabel = 'Level';
  static const String createRoom = 'Create a room';
  static const String joinWithCode = 'Join with a code';
  static const String categoriesTitle = 'Categories';
  static const String seeAll = 'See all';
  static const String challengeToDuel = 'Challenge to a duel';
  static const String createQuizTitle = 'Create your own quiz';
  static const String createQuizSubtitle = 'Write your questions and challenge your friends';

  static String dayUnit(int count) => count == 1 ? 'day' : 'days';
  static String friendsCount(int count) => '$count friend${count == 1 ? '' : 's'}';
  static String questionCount(int count) => '$count questions';

  // Categories screen
  static const String categoriesScreenTitle = 'Choose a category';

  // AI quiz
  static const String myAiQuizzesScreenTitle = 'My AI quizzes';

  // Leaderboard
  static const String leaderboardGreeting = 'Leaderboard';
  static const String leaderboardTitle = "Who's the best?";
  static const String segmentWeekly = 'Weekly';
  static const String segmentAllTime = 'All-time';
  static const String segmentFriends = 'Friends';
  static const String currentUserName = 'You';
  static const String seeFullRanking = 'See full ranking';

  static String xpValue(int xp) => '${formatThousands(xp)} XP';

  // Full leaderboard screen
  static const String fullLeaderboardTitle = 'Full ranking';

  // Player detail screen
  static const String playerDetailTitle = 'Profile';
  static const String streakLabel = 'Streak';
  static const String addToFriendsButton = 'Add to friends';
  static const String friendRequestSentLabel = 'Sent';
  static String rankedLabel(int rank, int xp) => 'Ranked #$rank · ${formatThousands(xp)} XP';
  static const String alreadyFriendsLabel = "You're friends";
  static const String acceptRequestButton = 'Accept';
  static const String declineRequestButton = 'Decline';

  // Friends
  static const String addFriend = 'Add friend';
  static const String searchFriendsPlaceholder = 'Search by name or username';
  static const String allFriendsSectionTitle = 'All friends';
  static const String otherUsersSectionTitle = 'Other users';
  static const String noFriendsFound = 'No friends found';

  // Add friend screen
  static const String searchByUsername = 'Search by username';
  static const String orViaInviteLink = 'Or via invite link';
  static const String yourInviteCode = 'Your invite code';
  static const String shareLink = 'Share the link';
  static const String addButton = 'Add';
  static const String requestedLabel = 'Requested';
  static const String noUsersFound = 'No users found';
  static const String codeCopied = 'Code copied';

  // Friend requests screen
  static const String friendRequestsTitle = 'Friend requests';
  static const String friendRequestsEmptyState = 'No requests yet';

  // Duel (choose a friend) screen
  static const String duelScreenTitle = '1v1 Duel';
  static const String chooseYourFriend = 'Choose your friend';

  // Profile
  static const String editProfile = 'Edit profile';
  static const String settings = 'Settings';
  static const String statTotalGames = 'Total games';
  static const String statWinRate = 'Win rate';
  static const String statLongestStreak = 'Longest streak';
  static const String gameHistory = 'Game history';
  static const String settingsAndHelp = 'Settings & help';

  static String levelWithTitle(int level, String title) => 'Level $level · $title';
  static String xpProgressLabel(int current, int target, int remaining) =>
      '${formatThousands(current)} / ${formatThousands(target)} XP · $remaining to next level';

  // Settings screen
  static const String settingsGroupGeneral = 'General';
  static const String settingsLanguage = 'Language';
  static const String settingsLanguageValue = 'English';
  static const String settingsNotifications = 'Notifications';
  static const String settingsTheme = 'Theme';
  static const String settingsThemeLight = 'Light';
  static const String settingsThemeDark = 'Dark';
  static const String settingsSoundEffects = 'Sound effects';
  static const String settingsGroupAccount = 'Account';
  static const String settingsPrivacy = 'Privacy';
  static const String settingsHelpCenter = 'Help center';
  static const String settingsTermsOfUse = 'Terms of use';
  static const String settingsChangePassword = 'Change password';
  static const String settingsLogOut = 'Log out';
  static const String settingsGroupDangerZone = 'Danger zone';
  static const String settingsDeleteAccount = 'Delete account';

  // Change password screen
  static const String changePasswordTitle = 'Change password';
  static const String changePasswordCurrentLabel = 'Current password';
  static const String changePasswordNewLabel = 'New password';
  static const String changePasswordConfirmLabel = 'Confirm new password';
  static const String changePasswordSaveButton = 'Save';
  static const String changePasswordUpdated = 'Password changed successfully';

  // Delete account confirmation dialog
  static const String deleteAccountConfirmTitle = 'Delete account';
  static const String deleteAccountConfirmButton = 'Yes, delete';

  // Game history screen
  static const String historySegmentAll = 'All';
  static const String historySegmentSolo = 'Solo';
  static const String historySegmentDuel = 'Duel';
  static const String historySegmentLobby = 'Lobby';
  static const String historyWinBadge = 'Win';
  static const String historyLossBadge = 'Loss';
  static const String historyDrawBadge = 'Draw';
  static const String historyEmptyState = "Games of this type aren't saved yet";
  static const String historyNoGamesYet = 'No games played yet';
  static String historyLobbyPlayerCount(int count) => '$count players';

  // Quiz intro (countdown)
  static const String quizStartLabel = 'Start!';

  // Quiz (question) screen
  static String questionProgress(int current, int total) => 'Question $current/$total';

  // Ball reveal screen
  static const String ballRevealTitle = 'Your points';
  static const String ballRevealBallLabel = 'points';

  // Result screen
  static const String resultLabel = 'Result';
  static String resultSummary(int correct, int total) => '$correct out of $total correct';
  static String totalBallLabel(int ball) => '$ball points';
  static String xpEarnedLabel(int xp) => '+$xp XP';
  static const String playAgain = 'Play again';
  static const String challengeAFriendButton = 'Challenge a friend';
  static const String backToHome = 'Back to home';

  // Join with a code screen
  static const String joinCodeHint = 'Enter the 6-digit room code your friend sent you';
  static const String joinButton = 'Join';
  static String codeDigitLabel(int position) => 'Code digit $position';
  static const String roomNotFound = 'No room found with that code';
  static const String roomFull = 'That room is full';
  static const String joinCodeTimedOut = "Couldn't connect — check your connection and try again";

  // Lobby (multiplayer room) screen
  static const String lobbyScreenTitle = 'Multiplayer room';
  static const String roomCodeLabel = 'Room code';
  static const String playersLabel = 'Players';
  static const String hostRoleLabel = 'Host';
  static const String guestRoleLabel = 'Guest';
  static const String startGameButton = 'Start the game';
  static const String waitingForHostLabel = 'Waiting for the host to start…';
  static const String lobbyClosedMessage = 'The host left, the room closed';
  static const String lobbyCreatingRoom = 'Creating room…';
  static const String lobbyCreateFailed = "Couldn't create the room — check your connection and try again";

  static String playerCount(int current, int max) => '$current/$max';

  // Lobby game screen
  static const String lobbyGameTitle = 'Room';
  static const String lobbyWaitingForQuestion = 'Preparing the question…';
  static String lobbyAnsweredProgress(int answered, int total) => '$answered/$total answered';
  static const String lobbyGameStartFailed = "The game didn't start — check your connection and try again";
  static const String lobbyGameBackToHome = 'Back to home';

  // Lobby result (room leaderboard) screen
  static const String lobbyResultTitle = 'Room results';
  static const String lobbyResultSubtitle = "Here's how everyone in the room did";
  static const String backToLobby = 'Play again';

  // Duel waiting screen
  static const String duelWaitingTitle = 'Duel';
  static const String waitingForAcceptLabel = 'Invite sent, waiting for a response…';
  static const String duelDeclinedLabel = 'Invite declined';
  static const String duelExpiredLabel = 'Invite expired';
  static const String duelTimedOutLabel = "Couldn't reach your friend — check your connection and try again";
  static const String duelWaitingBackToHome = 'Back to home';

  // Duel invite screen
  static const String duelInviteTitle = 'Duel invite';
  static const String challengesYouLabel = 'is challenging you to a duel';
  static const String acceptButton = 'Accept';
  static const String declineButton = 'Decline';

  // Duel game screen
  static const String duelGameTitle = 'Duel';
  static const String duelWaitingForQuestion = 'Preparing the question…';
  static const String duelOpponentAnsweredLabel = 'Opponent answered';
  static const String duelGameStartFailed = "The game didn't start — check your connection and try again";
  static const String duelGameBackToHome = 'Back to home';

  // Duel result screen
  static const String duelResultWon = 'You won!';
  static const String duelResultLost = 'You lost';
  static const String duelResultDraw = "It's a draw!";
  static const String duelYourScoreLabel = 'You';
  static const String duelOpponentScoreLabel = 'Opponent';

  // Notifications screen
  static const String notificationsTitle = 'Notifications';
  static String notifDuelChallenge(String name) => '$name challenged you to a duel';
  static const String notifDuelChallengeGeneric = 'You were challenged to a duel';
  static const String notifStreakReminder = "Don't lose your 5-day streak — play today!";
  static const String notifTop50 = 'You made it into the weekly Top 50';
  static String notifFriendRequest(String name) => '$name sent you a friend request';
  static const String notifFriendRequestGeneric = 'You have a new friend request';
  static const String notifWelcome = 'Welcome to Zukkor! Start your first quiz';
  static const String notifEmptyState = 'No notifications yet';

  // Edit Profile screen
  static const String saveButton = 'Save';
  static const String profileUpdatedMessage = 'Profile updated';

  // Language screen (title reuses settingsLanguage)
  static const String languageEnglish = 'English';
  static const String languageUzbek = "O'zbek";
  static const String languageRussian = 'Русский';

  // Notification preferences screen
  static const String notificationsPrefTitle = 'Notification preferences';
  static const String notifPrefDuelInvites = 'Duel invites';
  static const String notifPrefStreakReminders = 'Streak reminders';
  static const String notifPrefLeaderboardUpdates = 'Leaderboard updates';
  static const String notifPrefFriendRequests = 'Friend requests';
  static const String notifPrefProductUpdates = 'Product updates';

  // Privacy Policy screen
  static const String privacyPolicyTitle = 'Privacy Policy';
  static const String privacySectionCollectionTitle = 'Information we collect';
  static const String privacySectionCollectionBody =
      'We collect your name, username, and quiz activity — scores, categories played, and streaks — to run the game and show your progress.';
  static const String privacySectionUseTitle = 'How we use it';
  static const String privacySectionUseBody =
      'Your data is used to operate Zukkor: matching you in duels and lobbies, computing XP and rankings, and showing your stats back to you.';
  static const String privacySectionSharingTitle = 'Sharing';
  static const String privacySectionSharingBody =
      'We do not sell your data. Your name, avatar, and public stats are visible to other players as part of normal gameplay, such as the leaderboard, friends list, and duels.';
  static const String privacySectionContactTitle = 'Contact';
  static const String privacySectionContactBody =
      'Questions about your data? Reach out through the Help Center and we will get back to you.';

  // Terms of Use screen
  static const String termsOfUseTitle = 'Terms of Use';
  static const String termsSectionAccountTitle = 'Your account';
  static const String termsSectionAccountBody =
      'You are responsible for keeping your account secure and for the activity that happens under it.';
  static const String termsSectionConductTitle = 'Fair play';
  static const String termsSectionConductBody =
      'Cheating, exploiting bugs for XP, or harassing other players can result in a suspension.';
  static const String termsSectionContentTitle = 'Content';
  static const String termsSectionContentBody =
      'Quiz questions and app content belong to Zukkor. Do not copy or redistribute them without permission.';
  static const String termsSectionChangesTitle = 'Changes';
  static const String termsSectionChangesBody =
      'We may update these terms as Zukkor grows. We will let you know about any major changes.';

  // Help Center screen (title reuses settingsHelpCenter)
  static const String faqDuelQuestion = 'How do I start a duel?';
  static const String faqDuelAnswer =
      'Go to Friends, pick an online friend, then choose a category. Your opponent gets an invite.';
  static const String faqXpQuestion = 'How is XP calculated?';
  static const String faqXpAnswer =
      'You earn XP for each correct answer, plus a bonus for finishing a solo quiz or winning a duel.';
  static const String faqStreakQuestion = 'What happens if I miss a day?';
  static const String faqStreakAnswer =
      'Your streak resets to zero if you skip a full day without playing at least one quiz.';
  static const String faqLobbyQuestion = 'How many players can join a room?';
  static const String faqLobbyAnswer = 'Rooms currently support up to 10 players.';
  static const String faqReportQuestion = 'How do I report a bug or a bad question?';
  static const String faqReportAnswer =
      'Reach out to us through this Help Center. We are a small team and every report helps us improve Zukkor.';

  // Bottom navigation
  static const String navHome = 'Home';
  static const String navLeaderboard = 'Leaderboard';
  static const String navFriends = 'Friends';
  static const String navProfile = 'Profile';
  static const String comingSoon = 'Coming soon';
  static const String manualQuizScreenTitle = 'Create a quiz manually';

  // Onboarding — 3-step wizard (Zukkor_Profil_Yaratish.docx)
  static const String onboardingStepCount = 'Step';
  static const String onboardingContinue = 'Continue';
  static const String onboardingStart = 'Start';

  static const String avatarStepTitle = 'Pick an avatar that suits you';
  static const String avatarStepSubtitle = 'You can change it anytime later';
  static const String uploadPhoto = 'Upload photo';

  static const String profileStepTitle = "Let's get to know you";
  static const String profileStepSubtitle =
      'This info will be visible on your profile and to your friends';
  static const String firstNameLabel = 'First name';
  static const String firstNameHint = 'Aziz';
  static const String lastNameLabel = 'Last name';
  static const String lastNameHint = 'Karimov';
  static const String usernameLabel = 'Username';
  static const String usernameHint = 'aziz_karimov';

  static const String directionStepTitle = 'Why are you using Zukkor?';
  static const String directionStepSubtitle =
      "We'll recommend content and categories that fit you";
  static const String directionRequired = 'Please choose one to continue';

  static const String directionStudentUniTitle = 'Student';
  static const String directionStudentUniSubtitle =
      'I study at university or college';
  static const String directionStudentSchoolTitle = 'Pupil';
  static const String directionStudentSchoolSubtitle = 'I study at school';
  static const String directionExamPrepTitle = 'Exam prep';
  static const String directionExamPrepSubtitle =
      "I'm preparing for an exam (e.g. IELTS)";
  static const String directionCasualTitle = 'Just for fun';
  static const String directionCasualSubtitle = 'Playing and passing the time';

  // Introduction — 6-page first-launch walkthrough, shown once before
  // Login/Register.
  static const String introSkip = 'Skip';
  static const String introGetStarted = 'Get started';

  static const String introWelcomeTitle = 'Welcome to Zukkor!';
  static const String introWelcomeSubtitle =
      'The knowledge competition app where learning feels like a game';
  static const String introLanguageLabel = 'Choose your language';

  static const String introSoloTitle = 'Test yourself';
  static const String introSoloSubtitle =
      'Pick a category and answer questions solo — earn XP and beat your own best score';

  static const String introDuelTitle = 'Challenge your friends';
  static const String introDuelSubtitle =
      'Duel a friend head-to-head, or create a room and play with a whole group in real time';

  static const String introLeaderboardTitle = 'Climb the leaderboard';
  static const String introLeaderboardSubtitle =
      'Every correct answer earns XP — track your rank among friends and everyone else';

  static const String introInterestsTitle = 'What are you into?';
  static const String introInterestsSubtitle =
      "Pick a few — we'll use these to recommend categories";

  static const String introStudyTitle = 'Almost done!';
  static const String introStudySubtitle = 'A couple more quick questions';
  static const String introStudyPlaceLabel = 'Where do you study?';
  static const String introQuizLikingLabel = 'Do you enjoy solving quizzes and puzzles?';

  static const String introStudyPlaceSchool = 'School';
  static const String introStudyPlaceUniversity = 'University';
  static const String introStudyPlaceExamPrep = 'Exam prep';

  static const String introQuizLikingLoveIt = 'Love it';
  static const String introQuizLikingItsOk = "It's ok";
  static const String introQuizLikingNotReally = 'Not really';

  static const String introOtherOption = 'Other';
  static const String introOtherFieldLabel = 'Tell us more';
  static const String introOtherFieldHint = 'Type here...';

  // Auth — screen
  static const String loginTitle = 'Welcome back!';
  static const String loginSubtitle = 'Sign in and continue the game';
  static const String registerTitle = 'Create an account';
  static const String registerSubtitle = 'Sign up in a minute and get started';
  static const String emailLabel = 'Email';
  static const String emailHint = 'you@example.com';
  static const String passwordLabel = 'Password';
  static const String passwordHint = 'At least 8 characters';
  static const String confirmPasswordLabel = 'Confirm password';
  static const String confirmPasswordHint = 'Re-enter your password';
  static const String loginButton = 'Sign in';
  static const String registerButton = 'Sign up';
  static const String orDivider = 'or';
  static const String continueWithGoogle = 'Continue with Google';
  static const String noAccountPrompt = "Don't have an account?";
  static const String haveAccountPrompt = 'Already have an account?';
  static const String switchToRegister = 'Sign up';
  static const String switchToLogin = 'Sign in';

  // Auth — validation (same rules as the backend)
  static const String emailRequired = 'Email is required';
  static const String emailInvalid = 'Invalid email format';
  static const String passwordRequired = 'Password is required';
  static const String passwordTooShort = 'Password must be at least 8 characters';
  static const String passwordMismatch = "Passwords don't match";
  static const String usernameRequired = 'Username is required';
  static const String usernameInvalid =
      'Username may only contain letters, numbers and underscores (3–30 characters)';
  static const String usernameTaken = 'This username is already taken';
  static const String nameRequired = 'This field is required';
  static const String nameTooLong = 'Too long (maximum 50 characters)';

  // Errors (generic Failure messages)
  static const String errorNoConnection =
      'No internet connection. Please check your connection and try again.';
  static const String errorTimeout =
      'The server is not responding. Please try again shortly.';
  static const String errorServer =
      'A server error occurred. Please try again shortly.';
  static const String errorUnknown = 'An unexpected error occurred.';
  static const String errorInvalidCredentials = 'Incorrect email or password.';
  static const String errorSessionExpired = 'Your session has expired. Please sign in again.';
  static const String errorGoogleCancelled = 'Google sign-in was cancelled.';
}
