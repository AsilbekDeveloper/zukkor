///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

part of 'strings.g.dart';

// Path: <root>
typedef TranslationsEn = Translations; // ignore: unused_element
class Translations with BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	dynamic operator[](String key) => $meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations
	late final Translations$common$en common = Translations$common$en._(_root);
	late final Translations$home$en home = Translations$home$en._(_root);
	late final Translations$categories$en categories = Translations$categories$en._(_root);
	late final Translations$leaderboard$en leaderboard = Translations$leaderboard$en._(_root);
	late final Translations$fullLeaderboard$en fullLeaderboard = Translations$fullLeaderboard$en._(_root);
	late final Translations$playerDetail$en playerDetail = Translations$playerDetail$en._(_root);
	late final Translations$friends$en friends = Translations$friends$en._(_root);
	late final Translations$addFriend$en addFriend = Translations$addFriend$en._(_root);
	late final Translations$friendRequests$en friendRequests = Translations$friendRequests$en._(_root);
	late final Translations$duelPick$en duelPick = Translations$duelPick$en._(_root);
	late final Translations$profile$en profile = Translations$profile$en._(_root);
	late final Translations$settings$en settings = Translations$settings$en._(_root);
	late final Translations$changePassword$en changePassword = Translations$changePassword$en._(_root);
	late final Translations$deleteAccount$en deleteAccount = Translations$deleteAccount$en._(_root);
	late final Translations$history$en history = Translations$history$en._(_root);
	late final Translations$quizSetup$en quizSetup = Translations$quizSetup$en._(_root);
	late final Translations$quizIntro$en quizIntro = Translations$quizIntro$en._(_root);
	late final Translations$quiz$en quiz = Translations$quiz$en._(_root);
	late final Translations$ballReveal$en ballReveal = Translations$ballReveal$en._(_root);
	late final Translations$result$en result = Translations$result$en._(_root);
	late final Translations$joinCode$en joinCode = Translations$joinCode$en._(_root);
	late final Translations$lobby$en lobby = Translations$lobby$en._(_root);
	late final Translations$lobbyGame$en lobbyGame = Translations$lobbyGame$en._(_root);
	late final Translations$lobbyResult$en lobbyResult = Translations$lobbyResult$en._(_root);
	late final Translations$duelWaiting$en duelWaiting = Translations$duelWaiting$en._(_root);
	late final Translations$duelInvite$en duelInvite = Translations$duelInvite$en._(_root);
	late final Translations$duelGame$en duelGame = Translations$duelGame$en._(_root);
	late final Translations$duelResult$en duelResult = Translations$duelResult$en._(_root);
	late final Translations$notifications$en notifications = Translations$notifications$en._(_root);
	late final Translations$editProfile$en editProfile = Translations$editProfile$en._(_root);
	late final Translations$notificationSettings$en notificationSettings = Translations$notificationSettings$en._(_root);
	late final Translations$privacyPolicy$en privacyPolicy = Translations$privacyPolicy$en._(_root);
	late final Translations$termsOfUse$en termsOfUse = Translations$termsOfUse$en._(_root);
	late final Translations$helpCenter$en helpCenter = Translations$helpCenter$en._(_root);
	late final Translations$bottomNav$en bottomNav = Translations$bottomNav$en._(_root);
	late final Translations$onboarding$en onboarding = Translations$onboarding$en._(_root);
	late final Translations$introduction$en introduction = Translations$introduction$en._(_root);
	late final Translations$auth$en auth = Translations$auth$en._(_root);
	late final Translations$authValidation$en authValidation = Translations$authValidation$en._(_root);
	late final Translations$errors$en errors = Translations$errors$en._(_root);
	late final Translations$aiQuiz$en aiQuiz = Translations$aiQuiz$en._(_root);
}

// Path: common
class Translations$common$en {
	Translations$common$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Zukkor'
	String get appName => 'Zukkor';

	/// en: 'Knowledge competition'
	String get appTagline => 'Knowledge competition';

	/// en: 'OK'
	String get ok => 'OK';

	/// en: 'Cancel'
	String get cancel => 'Cancel';

	/// en: 'Retry'
	String get retry => 'Retry';

	/// en: 'Loading...'
	String get loading => 'Loading...';

	/// en: 'Delete'
	String get delete => 'Delete';

	/// en: '(one) {day} (other) {days}'
	String dayUnit({required num count}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(count,
		one: 'day',
		other: 'days',
	);

	/// en: '(one) {$count friend} (other) {$count friends}'
	String friendsCount({required num count}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(count,
		one: '${count} friend',
		other: '${count} friends',
	);

	/// en: '(one) {$count question} (other) {$count questions}'
	String questionCount({required num count}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(count,
		one: '${count} question',
		other: '${count} questions',
	);
}

// Path: home
class Translations$home$en {
	Translations$home$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Good morning'
	String get greeting => 'Good morning';

	/// en: 'Who's strong today?'
	String get duelHeroTitle => 'Who\'s strong today?';

	/// en: 'Challenge a friend or a random opponent'
	String get duelHeroSubtitle => 'Challenge a friend or a random opponent';

	/// en: 'Start a duel'
	String get startDuel => 'Start a duel';

	/// en: 'Total XP'
	String get totalXpLabel => 'Total XP';

	/// en: 'Rank'
	String get rankLabel => 'Rank';

	/// en: 'Level'
	String get levelLabel => 'Level';

	/// en: 'Create a room'
	String get createRoom => 'Create a room';

	/// en: 'Join with a code'
	String get joinWithCode => 'Join with a code';

	/// en: 'Categories'
	String get categoriesTitle => 'Categories';

	/// en: 'See all'
	String get seeAll => 'See all';

	/// en: 'Challenge to a duel'
	String get challengeToDuel => 'Challenge to a duel';
}

// Path: categories
class Translations$categories$en {
	Translations$categories$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Choose a category'
	String get title => 'Choose a category';
}

// Path: leaderboard
class Translations$leaderboard$en {
	Translations$leaderboard$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Leaderboard'
	String get greeting => 'Leaderboard';

	/// en: 'Who's the best?'
	String get title => 'Who\'s the best?';

	/// en: 'Weekly'
	String get segmentWeekly => 'Weekly';

	/// en: 'All-time'
	String get segmentAllTime => 'All-time';

	/// en: 'Friends'
	String get segmentFriends => 'Friends';

	/// en: 'You'
	String get you => 'You';

	/// en: 'See full ranking'
	String get seeFullRanking => 'See full ranking';

	/// en: '$xp XP'
	String xpValue({required Object xp}) => '${xp} XP';

	/// en: 'Player'
	String get anonymousPlayer => 'Player';
}

// Path: fullLeaderboard
class Translations$fullLeaderboard$en {
	Translations$fullLeaderboard$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Full ranking'
	String get title => 'Full ranking';
}

// Path: playerDetail
class Translations$playerDetail$en {
	Translations$playerDetail$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Profile'
	String get title => 'Profile';

	/// en: 'Streak'
	String get streakLabel => 'Streak';

	/// en: 'Add to friends'
	String get addToFriends => 'Add to friends';

	/// en: 'Sent'
	String get requestSent => 'Sent';

	/// en: 'Ranked #$rank · $xp XP'
	String rankedLabel({required Object rank, required Object xp}) => 'Ranked #${rank} · ${xp} XP';

	/// en: 'You're friends'
	String get alreadyFriends => 'You\'re friends';

	/// en: 'Accept'
	String get acceptRequest => 'Accept';

	/// en: 'Decline'
	String get declineRequest => 'Decline';

	/// en: 'Their quizzes'
	String get aiQuizzesTitle => 'Their quizzes';
}

// Path: friends
class Translations$friends$en {
	Translations$friends$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Add friend'
	String get addFriend => 'Add friend';

	/// en: 'Search friends'
	String get searchPlaceholder => 'Search friends';

	/// en: 'All friends'
	String get allSection => 'All friends';

	/// en: 'No friends found'
	String get noneFound => 'No friends found';
}

// Path: addFriend
class Translations$addFriend$en {
	Translations$addFriend$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Search by username'
	String get searchByUsername => 'Search by username';

	/// en: 'Or via invite link'
	String get orViaInviteLink => 'Or via invite link';

	/// en: 'Your invite code'
	String get yourInviteCode => 'Your invite code';

	/// en: 'Share the link'
	String get shareLink => 'Share the link';

	/// en: 'Add'
	String get addButton => 'Add';

	/// en: 'Requested'
	String get requestedLabel => 'Requested';

	/// en: 'No users found'
	String get noUsersFound => 'No users found';
}

// Path: friendRequests
class Translations$friendRequests$en {
	Translations$friendRequests$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Friend requests'
	String get title => 'Friend requests';

	/// en: 'No requests yet'
	String get emptyState => 'No requests yet';
}

// Path: duelPick
class Translations$duelPick$en {
	Translations$duelPick$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: '1v1 Duel'
	String get title => '1v1 Duel';

	/// en: 'Choose your friend'
	String get chooseYourFriend => 'Choose your friend';
}

// Path: profile
class Translations$profile$en {
	Translations$profile$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Edit profile'
	String get editProfile => 'Edit profile';

	/// en: 'Settings'
	String get settings => 'Settings';

	/// en: 'Total games'
	String get statTotalGames => 'Total games';

	/// en: 'Win rate'
	String get statWinRate => 'Win rate';

	/// en: 'Longest streak'
	String get statLongestStreak => 'Longest streak';

	/// en: 'Game history'
	String get gameHistory => 'Game history';

	/// en: 'Settings & help'
	String get settingsAndHelp => 'Settings & help';

	/// en: 'Level $level · $title'
	String levelWithTitle({required Object level, required Object title}) => 'Level ${level} · ${title}';

	/// en: '$current / $target XP · $remaining to next level'
	String xpProgressLabel({required Object current, required Object target, required Object remaining}) => '${current} / ${target} XP · ${remaining} to next level';
}

// Path: settings
class Translations$settings$en {
	Translations$settings$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'General'
	String get groupGeneral => 'General';

	/// en: 'Language'
	String get language => 'Language';

	/// en: 'Notifications'
	String get notifications => 'Notifications';

	/// en: 'Theme'
	String get theme => 'Theme';

	/// en: 'Light'
	String get themeLight => 'Light';

	/// en: 'Dark'
	String get themeDark => 'Dark';

	/// en: 'Sound effects'
	String get soundEffects => 'Sound effects';

	/// en: 'Account'
	String get groupAccount => 'Account';

	/// en: 'Privacy'
	String get privacy => 'Privacy';

	/// en: 'Help center'
	String get helpCenter => 'Help center';

	/// en: 'Terms of use'
	String get termsOfUse => 'Terms of use';

	/// en: 'Change password'
	String get changePassword => 'Change password';

	/// en: 'Log out'
	String get logOut => 'Log out';

	/// en: 'Danger zone'
	String get groupDangerZone => 'Danger zone';

	/// en: 'Delete account'
	String get deleteAccount => 'Delete account';
}

// Path: changePassword
class Translations$changePassword$en {
	Translations$changePassword$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Change password'
	String get title => 'Change password';

	/// en: 'Current password'
	String get currentPasswordLabel => 'Current password';

	/// en: 'Enter your current password'
	String get currentPasswordHint => 'Enter your current password';

	/// en: 'New password'
	String get newPasswordLabel => 'New password';

	/// en: 'At least 8 characters'
	String get newPasswordHint => 'At least 8 characters';

	/// en: 'Confirm new password'
	String get confirmNewPasswordLabel => 'Confirm new password';

	/// en: 'Re-enter your new password'
	String get confirmNewPasswordHint => 'Re-enter your new password';

	/// en: 'Save'
	String get saveButton => 'Save';

	/// en: 'Password changed successfully'
	String get updated => 'Password changed successfully';
}

// Path: deleteAccount
class Translations$deleteAccount$en {
	Translations$deleteAccount$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Delete account'
	String get confirmTitle => 'Delete account';

	/// en: 'This can't be undone. All your data — friends, history, ball — will be permanently deleted. Enter your password to continue.'
	String get confirmMessage => 'This can\'t be undone. All your data — friends, history, ball — will be permanently deleted. Enter your password to continue.';

	/// en: 'Yes, delete'
	String get confirmButton => 'Yes, delete';
}

// Path: history
class Translations$history$en {
	Translations$history$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'All'
	String get segmentAll => 'All';

	/// en: 'Solo'
	String get segmentSolo => 'Solo';

	/// en: 'Duel'
	String get segmentDuel => 'Duel';

	/// en: 'Lobby'
	String get segmentLobby => 'Lobby';

	/// en: 'Win'
	String get winBadge => 'Win';

	/// en: 'Loss'
	String get lossBadge => 'Loss';

	/// en: 'Draw'
	String get drawBadge => 'Draw';

	/// en: 'Today'
	String get today => 'Today';

	/// en: 'Yesterday'
	String get yesterday => 'Yesterday';

	/// en: '$days days ago'
	String daysAgo({required Object days}) => '${days} days ago';

	/// en: 'Games of this type aren't saved yet'
	String get emptyState => 'Games of this type aren\'t saved yet';

	/// en: 'No games played yet'
	String get noGamesYet => 'No games played yet';

	/// en: '$count players'
	String lobbyPlayerCount({required Object count}) => '${count} players';
}

// Path: quizSetup
class Translations$quizSetup$en {
	Translations$quizSetup$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'How many questions?'
	String get title => 'How many questions?';

	/// en: 'Pick a quick option or choose your own'
	String get subtitle => 'Pick a quick option or choose your own';

	/// en: 'Custom'
	String get customLabel => 'Custom';

	/// en: 'Start quiz'
	String get startButton => 'Start quiz';
}

// Path: quizIntro
class Translations$quizIntro$en {
	Translations$quizIntro$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Start!'
	String get startLabel => 'Start!';
}

// Path: quiz
class Translations$quiz$en {
	Translations$quiz$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Question $current/$total'
	String questionProgress({required Object current, required Object total}) => 'Question ${current}/${total}';
}

// Path: ballReveal
class Translations$ballReveal$en {
	Translations$ballReveal$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Your points'
	String get title => 'Your points';

	/// en: 'points'
	String get ballLabel => 'points';
}

// Path: result
class Translations$result$en {
	Translations$result$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Result'
	String get label => 'Result';

	/// en: '$correct out of $total correct'
	String summary({required Object correct, required Object total}) => '${correct} out of ${total} correct';

	/// en: '$ball points'
	String totalBall({required Object ball}) => '${ball} points';

	/// en: '+$xp XP'
	String xpEarned({required Object xp}) => '+${xp} XP';

	/// en: 'Play again'
	String get playAgain => 'Play again';

	/// en: 'Challenge a friend'
	String get challengeAFriend => 'Challenge a friend';

	/// en: 'Back to home'
	String get backToHome => 'Back to home';

	/// en: 'Question by question'
	String get breakdownTitle => 'Question by question';
}

// Path: joinCode
class Translations$joinCode$en {
	Translations$joinCode$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Enter the 6-digit room code your friend sent you'
	String get hint => 'Enter the 6-digit room code your friend sent you';

	/// en: 'Join'
	String get joinButton => 'Join';

	/// en: 'Code digit $position'
	String codeDigitLabel({required Object position}) => 'Code digit ${position}';

	/// en: 'No room found with that code'
	String get roomNotFound => 'No room found with that code';

	/// en: 'That room is full'
	String get roomFull => 'That room is full';

	/// en: 'This room's game has already started'
	String get alreadyStarted => 'This room\'s game has already started';

	/// en: 'Couldn't connect — check your connection and try again'
	String get timedOut => 'Couldn\'t connect — check your connection and try again';
}

// Path: lobby
class Translations$lobby$en {
	Translations$lobby$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Multiplayer room'
	String get title => 'Multiplayer room';

	/// en: 'Room code'
	String get roomCode => 'Room code';

	/// en: 'Players'
	String get players => 'Players';

	/// en: 'Host'
	String get hostRole => 'Host';

	/// en: 'Guest'
	String get guestRole => 'Guest';

	/// en: 'Start the game'
	String get startGame => 'Start the game';

	/// en: 'Waiting for the host to start…'
	String get waitingForHost => 'Waiting for the host to start…';

	/// en: '$current/$max'
	String playerCount({required Object current, required Object max}) => '${current}/${max}';

	/// en: 'The host left, the room closed'
	String get closedMessage => 'The host left, the room closed';

	/// en: 'Creating room…'
	String get creatingRoom => 'Creating room…';

	/// en: 'Couldn't create the room — check your connection and try again'
	String get createFailed => 'Couldn\'t create the room — check your connection and try again';

	/// en: 'Back to home'
	String get backToHome => 'Back to home';
}

// Path: lobbyGame
class Translations$lobbyGame$en {
	Translations$lobbyGame$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Room'
	String get title => 'Room';

	/// en: 'Preparing the question…'
	String get waitingForQuestion => 'Preparing the question…';

	/// en: 'You've answered every question! Waiting for the others…'
	String get waitingForOthers => 'You\'ve answered every question! Waiting for the others…';

	/// en: 'The game didn't start — check your connection and try again'
	String get startFailed => 'The game didn\'t start — check your connection and try again';

	/// en: 'Back to home'
	String get backToHome => 'Back to home';
}

// Path: lobbyResult
class Translations$lobbyResult$en {
	Translations$lobbyResult$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Room results'
	String get title => 'Room results';

	/// en: 'Here's how everyone in the room did'
	String get subtitle => 'Here\'s how everyone in the room did';

	/// en: 'Play again'
	String get playAgain => 'Play again';
}

// Path: duelWaiting
class Translations$duelWaiting$en {
	Translations$duelWaiting$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Duel'
	String get title => 'Duel';

	/// en: 'Invite sent, waiting for a response…'
	String get waitingForAccept => 'Invite sent, waiting for a response…';

	/// en: 'Invite declined'
	String get declined => 'Invite declined';

	/// en: 'Invite expired'
	String get expired => 'Invite expired';

	/// en: 'Couldn't send the invite'
	String get failed => 'Couldn\'t send the invite';

	/// en: 'Couldn't reach your friend — check your connection and try again'
	String get timedOut => 'Couldn\'t reach your friend — check your connection and try again';

	/// en: 'Back to home'
	String get backToHome => 'Back to home';
}

// Path: duelInvite
class Translations$duelInvite$en {
	Translations$duelInvite$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Duel invite'
	String get title => 'Duel invite';

	/// en: 'is challenging you to a duel'
	String get challengesYou => 'is challenging you to a duel';

	/// en: 'Accept'
	String get accept => 'Accept';

	/// en: 'Decline'
	String get decline => 'Decline';
}

// Path: duelGame
class Translations$duelGame$en {
	Translations$duelGame$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Duel'
	String get title => 'Duel';

	/// en: 'Preparing the question…'
	String get waitingForQuestion => 'Preparing the question…';

	/// en: 'Opponent: question $index/$total'
	String opponentProgress({required Object index, required Object total}) => 'Opponent: question ${index}/${total}';

	/// en: 'You've answered every question! Waiting for your opponent…'
	String get waitingForOpponent => 'You\'ve answered every question! Waiting for your opponent…';

	/// en: 'The game didn't start — check your connection and try again'
	String get startFailed => 'The game didn\'t start — check your connection and try again';

	/// en: 'Back to home'
	String get backToHome => 'Back to home';
}

// Path: duelResult
class Translations$duelResult$en {
	Translations$duelResult$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'You won!'
	String get won => 'You won!';

	/// en: 'You lost'
	String get lost => 'You lost';

	/// en: 'It's a draw!'
	String get draw => 'It\'s a draw!';

	/// en: 'You'
	String get yourScoreLabel => 'You';

	/// en: 'Opponent'
	String get opponentScoreLabel => 'Opponent';
}

// Path: notifications
class Translations$notifications$en {
	Translations$notifications$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Notifications'
	String get title => 'Notifications';

	/// en: '$name challenged you to a duel'
	String duelChallenge({required Object name}) => '${name} challenged you to a duel';

	/// en: 'You were challenged to a duel'
	String get duelChallengeGeneric => 'You were challenged to a duel';

	/// en: 'Don't lose your 5-day streak — play today!'
	String get streakReminder => 'Don\'t lose your 5-day streak — play today!';

	/// en: 'You made it into the weekly Top 50'
	String get top50 => 'You made it into the weekly Top 50';

	/// en: '$name sent you a friend request'
	String friendRequest({required Object name}) => '${name} sent you a friend request';

	/// en: 'You have a new friend request'
	String get friendRequestGeneric => 'You have a new friend request';

	/// en: 'Welcome to Zukkor! Start your first quiz'
	String get welcome => 'Welcome to Zukkor! Start your first quiz';

	/// en: 'No notifications yet'
	String get emptyState => 'No notifications yet';
}

// Path: editProfile
class Translations$editProfile$en {
	Translations$editProfile$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Save'
	String get save => 'Save';

	/// en: 'Profile updated'
	String get updated => 'Profile updated';
}

// Path: notificationSettings
class Translations$notificationSettings$en {
	Translations$notificationSettings$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Notification preferences'
	String get title => 'Notification preferences';

	/// en: 'Duel invites'
	String get duelInvites => 'Duel invites';

	/// en: 'Streak reminders'
	String get streakReminders => 'Streak reminders';

	/// en: 'Leaderboard updates'
	String get leaderboardUpdates => 'Leaderboard updates';

	/// en: 'Friend requests'
	String get friendRequests => 'Friend requests';

	/// en: 'Product updates'
	String get productUpdates => 'Product updates';
}

// Path: privacyPolicy
class Translations$privacyPolicy$en {
	Translations$privacyPolicy$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Privacy Policy'
	String get title => 'Privacy Policy';

	/// en: 'Information we collect'
	String get collectionTitle => 'Information we collect';

	/// en: 'We collect your name, username, and quiz activity — scores, categories played, and streaks — to run the game and show your progress.'
	String get collectionBody => 'We collect your name, username, and quiz activity — scores, categories played, and streaks — to run the game and show your progress.';

	/// en: 'How we use it'
	String get useTitle => 'How we use it';

	/// en: 'Your data is used to operate Zukkor: matching you in duels and lobbies, computing XP and rankings, and showing your stats back to you.'
	String get useBody => 'Your data is used to operate Zukkor: matching you in duels and lobbies, computing XP and rankings, and showing your stats back to you.';

	/// en: 'Sharing'
	String get sharingTitle => 'Sharing';

	/// en: 'We do not sell your data. Your name, avatar, and public stats are visible to other players as part of normal gameplay, such as the leaderboard, friends list, and duels.'
	String get sharingBody => 'We do not sell your data. Your name, avatar, and public stats are visible to other players as part of normal gameplay, such as the leaderboard, friends list, and duels.';

	/// en: 'Contact'
	String get contactTitle => 'Contact';

	/// en: 'Questions about your data? Reach out through the Help Center and we will get back to you.'
	String get contactBody => 'Questions about your data? Reach out through the Help Center and we will get back to you.';
}

// Path: termsOfUse
class Translations$termsOfUse$en {
	Translations$termsOfUse$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Terms of Use'
	String get title => 'Terms of Use';

	/// en: 'Your account'
	String get accountTitle => 'Your account';

	/// en: 'You are responsible for keeping your account secure and for the activity that happens under it.'
	String get accountBody => 'You are responsible for keeping your account secure and for the activity that happens under it.';

	/// en: 'Fair play'
	String get conductTitle => 'Fair play';

	/// en: 'Cheating, exploiting bugs for XP, or harassing other players can result in a suspension.'
	String get conductBody => 'Cheating, exploiting bugs for XP, or harassing other players can result in a suspension.';

	/// en: 'Content'
	String get contentTitle => 'Content';

	/// en: 'Quiz questions and app content belong to Zukkor. Do not copy or redistribute them without permission.'
	String get contentBody => 'Quiz questions and app content belong to Zukkor. Do not copy or redistribute them without permission.';

	/// en: 'Changes'
	String get changesTitle => 'Changes';

	/// en: 'We may update these terms as Zukkor grows. We will let you know about any major changes.'
	String get changesBody => 'We may update these terms as Zukkor grows. We will let you know about any major changes.';
}

// Path: helpCenter
class Translations$helpCenter$en {
	Translations$helpCenter$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'How do I start a duel?'
	String get duelQuestion => 'How do I start a duel?';

	/// en: 'Go to Friends, pick an online friend, then choose a category. Your opponent gets an invite.'
	String get duelAnswer => 'Go to Friends, pick an online friend, then choose a category. Your opponent gets an invite.';

	/// en: 'How is XP calculated?'
	String get xpQuestion => 'How is XP calculated?';

	/// en: 'You earn XP for each correct answer, plus a bonus for finishing a solo quiz or winning a duel.'
	String get xpAnswer => 'You earn XP for each correct answer, plus a bonus for finishing a solo quiz or winning a duel.';

	/// en: 'What happens if I miss a day?'
	String get streakQuestion => 'What happens if I miss a day?';

	/// en: 'Your streak resets to zero if you skip a full day without playing at least one quiz.'
	String get streakAnswer => 'Your streak resets to zero if you skip a full day without playing at least one quiz.';

	/// en: 'How many players can join a room?'
	String get lobbyQuestion => 'How many players can join a room?';

	/// en: 'Rooms currently support up to 10 players.'
	String get lobbyAnswer => 'Rooms currently support up to 10 players.';

	/// en: 'How do I report a bug or a bad question?'
	String get reportQuestion => 'How do I report a bug or a bad question?';

	/// en: 'Reach out to us through this Help Center. We are a small team and every report helps us improve Zukkor.'
	String get reportAnswer => 'Reach out to us through this Help Center. We are a small team and every report helps us improve Zukkor.';
}

// Path: bottomNav
class Translations$bottomNav$en {
	Translations$bottomNav$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Home'
	String get home => 'Home';

	/// en: 'Leaderboard'
	String get leaderboard => 'Leaderboard';

	/// en: 'Friends'
	String get friends => 'Friends';

	/// en: 'Profile'
	String get profile => 'Profile';

	/// en: 'Coming soon'
	String get comingSoon => 'Coming soon';
}

// Path: onboarding
class Translations$onboarding$en {
	Translations$onboarding$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Step'
	String get stepCount => 'Step';

	/// en: 'Continue'
	String get continueButton => 'Continue';

	/// en: 'Start'
	String get start => 'Start';

	/// en: 'Pick an avatar that suits you'
	String get avatarTitle => 'Pick an avatar that suits you';

	/// en: 'You can change it anytime later'
	String get avatarSubtitle => 'You can change it anytime later';

	/// en: 'Upload photo'
	String get uploadPhoto => 'Upload photo';

	/// en: 'Let's get to know you'
	String get profileTitle => 'Let\'s get to know you';

	/// en: 'This info will be visible on your profile and to your friends'
	String get profileSubtitle => 'This info will be visible on your profile and to your friends';

	/// en: 'First name'
	String get firstNameLabel => 'First name';

	/// en: 'Aziz'
	String get firstNameHint => 'Aziz';

	/// en: 'Last name'
	String get lastNameLabel => 'Last name';

	/// en: 'Karimov'
	String get lastNameHint => 'Karimov';

	/// en: 'Username'
	String get usernameLabel => 'Username';

	/// en: 'aziz_karimov'
	String get usernameHint => 'aziz_karimov';

	/// en: 'Why are you using Zukkor?'
	String get directionTitle => 'Why are you using Zukkor?';

	/// en: 'We'll recommend content and categories that fit you'
	String get directionSubtitle => 'We\'ll recommend content and categories that fit you';

	/// en: 'Please choose one to continue'
	String get directionRequired => 'Please choose one to continue';

	/// en: 'Student'
	String get studentUniTitle => 'Student';

	/// en: 'I study at university or college'
	String get studentUniSubtitle => 'I study at university or college';

	/// en: 'Pupil'
	String get studentSchoolTitle => 'Pupil';

	/// en: 'I study at school'
	String get studentSchoolSubtitle => 'I study at school';

	/// en: 'Exam prep'
	String get examPrepTitle => 'Exam prep';

	/// en: 'I'm preparing for an exam (e.g. IELTS)'
	String get examPrepSubtitle => 'I\'m preparing for an exam (e.g. IELTS)';

	/// en: 'Just for fun'
	String get casualTitle => 'Just for fun';

	/// en: 'Playing and passing the time'
	String get casualSubtitle => 'Playing and passing the time';
}

// Path: introduction
class Translations$introduction$en {
	Translations$introduction$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Skip'
	String get skip => 'Skip';

	/// en: 'Get started'
	String get getStarted => 'Get started';

	/// en: 'Welcome to Zukkor!'
	String get welcomeTitle => 'Welcome to Zukkor!';

	/// en: 'The knowledge competition app where learning feels like a game'
	String get welcomeSubtitle => 'The knowledge competition app where learning feels like a game';

	/// en: 'Choose your language'
	String get languageLabel => 'Choose your language';

	/// en: 'Test yourself'
	String get soloTitle => 'Test yourself';

	/// en: 'Pick a category and answer questions solo — earn XP and beat your own best score'
	String get soloSubtitle => 'Pick a category and answer questions solo — earn XP and beat your own best score';

	/// en: 'Challenge your friends'
	String get duelTitle => 'Challenge your friends';

	/// en: 'Duel a friend head-to-head, or create a room and play with a whole group in real time'
	String get duelSubtitle => 'Duel a friend head-to-head, or create a room and play with a whole group in real time';

	/// en: 'Climb the leaderboard'
	String get leaderboardTitle => 'Climb the leaderboard';

	/// en: 'Every correct answer earns XP — track your rank among friends and everyone else'
	String get leaderboardSubtitle => 'Every correct answer earns XP — track your rank among friends and everyone else';

	/// en: 'What are you into?'
	String get interestsTitle => 'What are you into?';

	/// en: 'Pick a few — we'll use these to recommend categories'
	String get interestsSubtitle => 'Pick a few — we\'ll use these to recommend categories';

	/// en: 'Almost done!'
	String get studyTitle => 'Almost done!';

	/// en: 'A couple more quick questions'
	String get studySubtitle => 'A couple more quick questions';

	/// en: 'Where do you study?'
	String get studyPlaceLabel => 'Where do you study?';

	/// en: 'Do you enjoy solving quizzes and puzzles?'
	String get quizLikingLabel => 'Do you enjoy solving quizzes and puzzles?';

	/// en: 'School'
	String get studyPlaceSchool => 'School';

	/// en: 'University'
	String get studyPlaceUniversity => 'University';

	/// en: 'Exam prep'
	String get studyPlaceExamPrep => 'Exam prep';

	/// en: 'Love it'
	String get quizLikingLoveIt => 'Love it';

	/// en: 'It's ok'
	String get quizLikingItsOk => 'It\'s ok';

	/// en: 'Not really'
	String get quizLikingNotReally => 'Not really';

	/// en: 'Other'
	String get otherOption => 'Other';

	/// en: 'Tell us more'
	String get otherFieldLabel => 'Tell us more';

	/// en: 'Type here...'
	String get otherFieldHint => 'Type here...';
}

// Path: auth
class Translations$auth$en {
	Translations$auth$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Welcome back!'
	String get loginTitle => 'Welcome back!';

	/// en: 'Sign in and continue the game'
	String get loginSubtitle => 'Sign in and continue the game';

	/// en: 'Create an account'
	String get registerTitle => 'Create an account';

	/// en: 'Sign up in a minute and get started'
	String get registerSubtitle => 'Sign up in a minute and get started';

	/// en: 'Email'
	String get emailLabel => 'Email';

	/// en: 'you@example.com'
	String get emailHint => 'you@example.com';

	/// en: 'Password'
	String get passwordLabel => 'Password';

	/// en: 'At least 8 characters'
	String get passwordHint => 'At least 8 characters';

	/// en: 'Confirm password'
	String get confirmPasswordLabel => 'Confirm password';

	/// en: 'Re-enter your password'
	String get confirmPasswordHint => 'Re-enter your password';

	/// en: 'Sign in'
	String get loginButton => 'Sign in';

	/// en: 'Sign up'
	String get registerButton => 'Sign up';

	/// en: 'or'
	String get orDivider => 'or';

	/// en: 'Continue with Google'
	String get continueWithGoogle => 'Continue with Google';

	/// en: 'Don't have an account?'
	String get noAccountPrompt => 'Don\'t have an account?';

	/// en: 'Already have an account?'
	String get haveAccountPrompt => 'Already have an account?';

	/// en: 'Sign up'
	String get switchToRegister => 'Sign up';

	/// en: 'Sign in'
	String get switchToLogin => 'Sign in';
}

// Path: authValidation
class Translations$authValidation$en {
	Translations$authValidation$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Email is required'
	String get emailRequired => 'Email is required';

	/// en: 'Invalid email format'
	String get emailInvalid => 'Invalid email format';

	/// en: 'Password is required'
	String get passwordRequired => 'Password is required';

	/// en: 'Password must be at least 8 characters, with 1 uppercase letter and 1 number'
	String get passwordTooShort => 'Password must be at least 8 characters, with 1 uppercase letter and 1 number';

	/// en: 'Passwords don't match'
	String get passwordMismatch => 'Passwords don\'t match';

	/// en: 'Username is required'
	String get usernameRequired => 'Username is required';

	/// en: 'Username may only contain letters, numbers and underscores (3–30 characters)'
	String get usernameInvalid => 'Username may only contain letters, numbers and underscores (3–30 characters)';

	/// en: 'This username is already taken'
	String get usernameTaken => 'This username is already taken';

	/// en: 'This field is required'
	String get nameRequired => 'This field is required';

	/// en: 'Too long (maximum 50 characters)'
	String get nameTooLong => 'Too long (maximum 50 characters)';
}

// Path: errors
class Translations$errors$en {
	Translations$errors$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'No internet connection. Please check your connection and try again.'
	String get noConnection => 'No internet connection. Please check your connection and try again.';

	/// en: 'The server is not responding. Please try again shortly.'
	String get timeout => 'The server is not responding. Please try again shortly.';

	/// en: 'A server error occurred. Please try again shortly.'
	String get server => 'A server error occurred. Please try again shortly.';

	/// en: 'An unexpected error occurred.'
	String get unknown => 'An unexpected error occurred.';

	/// en: 'Incorrect email or password.'
	String get invalidCredentials => 'Incorrect email or password.';

	/// en: 'Your session has expired. Please sign in again.'
	String get sessionExpired => 'Your session has expired. Please sign in again.';

	/// en: 'Google sign-in was cancelled.'
	String get googleCancelled => 'Google sign-in was cancelled.';
}

// Path: aiQuiz
class Translations$aiQuiz$en {
	Translations$aiQuiz$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Create a quiz from a document with AI'
	String get entryCardLabel => 'Create a quiz from a document with AI';

	/// en: 'My AI quizzes'
	String get myQuizzesTitle => 'My AI quizzes';

	/// en: '+ Create a new AI quiz'
	String get createButton => '+ Create a new AI quiz';

	/// en: 'You haven't created an AI quiz yet'
	String get emptyTitle => 'You haven\'t created an AI quiz yet';

	/// en: 'Upload a document (PDF, Word, or text) and get a quiz generated from it'
	String get emptySubtitle => 'Upload a document (PDF, Word, or text) and get a quiz generated from it';

	/// en: 'Delete quiz'
	String get deleteConfirmTitle => 'Delete quiz';

	/// en: 'Delete "$name"? This can't be undone.'
	String deleteConfirmMessage({required Object name}) => 'Delete "${name}"? This can\'t be undone.';

	/// en: 'Create a quiz with AI'
	String get generateTitle => 'Create a quiz with AI';

	/// en: 'Create a quiz with AI from a document or a topic'
	String get generateSubtitle => 'Create a quiz with AI from a document or a topic';

	/// en: 'Document'
	String get modeDocumentLabel => 'Document';

	/// en: 'Topic'
	String get modeTopicLabel => 'Topic';

	/// en: 'Choose a document (PDF, Word, text)'
	String get pickFileLabel => 'Choose a document (PDF, Word, text)';

	/// en: 'Choose a document first'
	String get pickFileFirst => 'Choose a document first';

	/// en: 'Instructions (optional)'
	String get instructionLabel => 'Instructions (optional)';

	/// en: 'E.g.: 10 questions from chapter 3, or from the whole document'
	String get instructionHint => 'E.g.: 10 questions from chapter 3, or from the whole document';

	/// en: 'Topic'
	String get topicLabel => 'Topic';

	/// en: 'E.g.: ask for WWII history questions at medium difficulty, or Uzbek movie questions'
	String get topicHint => 'E.g.: ask for WWII history questions at medium difficulty, or Uzbek movie questions';

	/// en: 'Enter a topic'
	String get topicRequired => 'Enter a topic';

	/// en: 'Number of questions'
	String get questionCountLabel => 'Number of questions';

	/// en: 'Generate'
	String get generateButton => 'Generate';

	/// en: 'Done! Saved to "My AI quizzes"'
	String get generated => 'Done! Saved to "My AI quizzes"';

	/// en: 'AI is generating questions...'
	String get generatingTitle => 'AI is generating questions...';

	/// en: 'This can take a moment, please wait'
	String get generatingSubtitle => 'This can take a moment, please wait';

	/// en: 'AI'
	String get sourceAi => 'AI';

	/// en: 'Manual'
	String get sourceManual => 'Manual';

	/// en: 'Nobody'
	String get visibilityPrivate => 'Nobody';

	/// en: 'Friends'
	String get visibilityFriends => 'Friends';

	/// en: 'Everyone'
	String get visibilityPublic => 'Everyone';

	/// en: 'Who can see this?'
	String get visibilityDialogTitle => 'Who can see this?';

	/// en: 'Visibility updated'
	String get visibilityUpdated => 'Visibility updated';

	/// en: 'How do you want to create it?'
	String get createChooseTitle => 'How do you want to create it?';

	/// en: 'With AI'
	String get createViaAi => 'With AI';

	/// en: 'Manually'
	String get createManually => 'Manually';

	/// en: 'Create a quiz manually'
	String get createManualTitle => 'Create a quiz manually';

	/// en: 'Quiz name'
	String get manualNameLabel => 'Quiz name';

	/// en: 'E.g.: My geography test'
	String get manualNameHint => 'E.g.: My geography test';

	/// en: 'Enter a quiz name'
	String get manualNameRequired => 'Enter a quiz name';

	/// en: 'Question $number'
	String manualQuestionLabel({required Object number}) => 'Question ${number}';

	/// en: 'Question text'
	String get manualQuestionTextLabel => 'Question text';

	/// en: 'Option $number'
	String manualOptionLabel({required Object number}) => 'Option ${number}';

	/// en: 'Fill in all fields'
	String get manualFillAllFields => 'Fill in all fields';

	/// en: '+ Add question'
	String get manualAddQuestion => '+ Add question';

	/// en: 'Create'
	String get manualSubmit => 'Create';
}

/// The flat map containing all translations for locale <en>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on Translations {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'common.appName' => 'Zukkor',
			'common.appTagline' => 'Knowledge competition',
			'common.ok' => 'OK',
			'common.cancel' => 'Cancel',
			'common.retry' => 'Retry',
			'common.loading' => 'Loading...',
			'common.delete' => 'Delete',
			'common.dayUnit' => ({required num count}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(count, one: 'day', other: 'days', ), 
			'common.friendsCount' => ({required num count}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(count, one: '${count} friend', other: '${count} friends', ), 
			'common.questionCount' => ({required num count}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(count, one: '${count} question', other: '${count} questions', ), 
			'home.greeting' => 'Good morning',
			'home.duelHeroTitle' => 'Who\'s strong today?',
			'home.duelHeroSubtitle' => 'Challenge a friend or a random opponent',
			'home.startDuel' => 'Start a duel',
			'home.totalXpLabel' => 'Total XP',
			'home.rankLabel' => 'Rank',
			'home.levelLabel' => 'Level',
			'home.createRoom' => 'Create a room',
			'home.joinWithCode' => 'Join with a code',
			'home.categoriesTitle' => 'Categories',
			'home.seeAll' => 'See all',
			'home.challengeToDuel' => 'Challenge to a duel',
			'categories.title' => 'Choose a category',
			'leaderboard.greeting' => 'Leaderboard',
			'leaderboard.title' => 'Who\'s the best?',
			'leaderboard.segmentWeekly' => 'Weekly',
			'leaderboard.segmentAllTime' => 'All-time',
			'leaderboard.segmentFriends' => 'Friends',
			'leaderboard.you' => 'You',
			'leaderboard.seeFullRanking' => 'See full ranking',
			'leaderboard.xpValue' => ({required Object xp}) => '${xp} XP',
			'leaderboard.anonymousPlayer' => 'Player',
			'fullLeaderboard.title' => 'Full ranking',
			'playerDetail.title' => 'Profile',
			'playerDetail.streakLabel' => 'Streak',
			'playerDetail.addToFriends' => 'Add to friends',
			'playerDetail.requestSent' => 'Sent',
			'playerDetail.rankedLabel' => ({required Object rank, required Object xp}) => 'Ranked #${rank} · ${xp} XP',
			'playerDetail.alreadyFriends' => 'You\'re friends',
			'playerDetail.acceptRequest' => 'Accept',
			'playerDetail.declineRequest' => 'Decline',
			'playerDetail.aiQuizzesTitle' => 'Their quizzes',
			'friends.addFriend' => 'Add friend',
			'friends.searchPlaceholder' => 'Search friends',
			'friends.allSection' => 'All friends',
			'friends.noneFound' => 'No friends found',
			'addFriend.searchByUsername' => 'Search by username',
			'addFriend.orViaInviteLink' => 'Or via invite link',
			'addFriend.yourInviteCode' => 'Your invite code',
			'addFriend.shareLink' => 'Share the link',
			'addFriend.addButton' => 'Add',
			'addFriend.requestedLabel' => 'Requested',
			'addFriend.noUsersFound' => 'No users found',
			'friendRequests.title' => 'Friend requests',
			'friendRequests.emptyState' => 'No requests yet',
			'duelPick.title' => '1v1 Duel',
			'duelPick.chooseYourFriend' => 'Choose your friend',
			'profile.editProfile' => 'Edit profile',
			'profile.settings' => 'Settings',
			'profile.statTotalGames' => 'Total games',
			'profile.statWinRate' => 'Win rate',
			'profile.statLongestStreak' => 'Longest streak',
			'profile.gameHistory' => 'Game history',
			'profile.settingsAndHelp' => 'Settings & help',
			'profile.levelWithTitle' => ({required Object level, required Object title}) => 'Level ${level} · ${title}',
			'profile.xpProgressLabel' => ({required Object current, required Object target, required Object remaining}) => '${current} / ${target} XP · ${remaining} to next level',
			'settings.groupGeneral' => 'General',
			'settings.language' => 'Language',
			'settings.notifications' => 'Notifications',
			'settings.theme' => 'Theme',
			'settings.themeLight' => 'Light',
			'settings.themeDark' => 'Dark',
			'settings.soundEffects' => 'Sound effects',
			'settings.groupAccount' => 'Account',
			'settings.privacy' => 'Privacy',
			'settings.helpCenter' => 'Help center',
			'settings.termsOfUse' => 'Terms of use',
			'settings.changePassword' => 'Change password',
			'settings.logOut' => 'Log out',
			'settings.groupDangerZone' => 'Danger zone',
			'settings.deleteAccount' => 'Delete account',
			'changePassword.title' => 'Change password',
			'changePassword.currentPasswordLabel' => 'Current password',
			'changePassword.currentPasswordHint' => 'Enter your current password',
			'changePassword.newPasswordLabel' => 'New password',
			'changePassword.newPasswordHint' => 'At least 8 characters',
			'changePassword.confirmNewPasswordLabel' => 'Confirm new password',
			'changePassword.confirmNewPasswordHint' => 'Re-enter your new password',
			'changePassword.saveButton' => 'Save',
			'changePassword.updated' => 'Password changed successfully',
			'deleteAccount.confirmTitle' => 'Delete account',
			'deleteAccount.confirmMessage' => 'This can\'t be undone. All your data — friends, history, ball — will be permanently deleted. Enter your password to continue.',
			'deleteAccount.confirmButton' => 'Yes, delete',
			'history.segmentAll' => 'All',
			'history.segmentSolo' => 'Solo',
			'history.segmentDuel' => 'Duel',
			'history.segmentLobby' => 'Lobby',
			'history.winBadge' => 'Win',
			'history.lossBadge' => 'Loss',
			'history.drawBadge' => 'Draw',
			'history.today' => 'Today',
			'history.yesterday' => 'Yesterday',
			'history.daysAgo' => ({required Object days}) => '${days} days ago',
			'history.emptyState' => 'Games of this type aren\'t saved yet',
			'history.noGamesYet' => 'No games played yet',
			'history.lobbyPlayerCount' => ({required Object count}) => '${count} players',
			'quizSetup.title' => 'How many questions?',
			'quizSetup.subtitle' => 'Pick a quick option or choose your own',
			'quizSetup.customLabel' => 'Custom',
			'quizSetup.startButton' => 'Start quiz',
			'quizIntro.startLabel' => 'Start!',
			'quiz.questionProgress' => ({required Object current, required Object total}) => 'Question ${current}/${total}',
			'ballReveal.title' => 'Your points',
			'ballReveal.ballLabel' => 'points',
			'result.label' => 'Result',
			'result.summary' => ({required Object correct, required Object total}) => '${correct} out of ${total} correct',
			'result.totalBall' => ({required Object ball}) => '${ball} points',
			'result.xpEarned' => ({required Object xp}) => '+${xp} XP',
			'result.playAgain' => 'Play again',
			'result.challengeAFriend' => 'Challenge a friend',
			'result.backToHome' => 'Back to home',
			'result.breakdownTitle' => 'Question by question',
			'joinCode.hint' => 'Enter the 6-digit room code your friend sent you',
			'joinCode.joinButton' => 'Join',
			'joinCode.codeDigitLabel' => ({required Object position}) => 'Code digit ${position}',
			'joinCode.roomNotFound' => 'No room found with that code',
			'joinCode.roomFull' => 'That room is full',
			'joinCode.alreadyStarted' => 'This room\'s game has already started',
			'joinCode.timedOut' => 'Couldn\'t connect — check your connection and try again',
			'lobby.title' => 'Multiplayer room',
			'lobby.roomCode' => 'Room code',
			'lobby.players' => 'Players',
			'lobby.hostRole' => 'Host',
			'lobby.guestRole' => 'Guest',
			'lobby.startGame' => 'Start the game',
			'lobby.waitingForHost' => 'Waiting for the host to start…',
			'lobby.playerCount' => ({required Object current, required Object max}) => '${current}/${max}',
			'lobby.closedMessage' => 'The host left, the room closed',
			'lobby.creatingRoom' => 'Creating room…',
			'lobby.createFailed' => 'Couldn\'t create the room — check your connection and try again',
			'lobby.backToHome' => 'Back to home',
			'lobbyGame.title' => 'Room',
			'lobbyGame.waitingForQuestion' => 'Preparing the question…',
			'lobbyGame.waitingForOthers' => 'You\'ve answered every question! Waiting for the others…',
			'lobbyGame.startFailed' => 'The game didn\'t start — check your connection and try again',
			'lobbyGame.backToHome' => 'Back to home',
			'lobbyResult.title' => 'Room results',
			'lobbyResult.subtitle' => 'Here\'s how everyone in the room did',
			'lobbyResult.playAgain' => 'Play again',
			'duelWaiting.title' => 'Duel',
			'duelWaiting.waitingForAccept' => 'Invite sent, waiting for a response…',
			'duelWaiting.declined' => 'Invite declined',
			'duelWaiting.expired' => 'Invite expired',
			'duelWaiting.failed' => 'Couldn\'t send the invite',
			'duelWaiting.timedOut' => 'Couldn\'t reach your friend — check your connection and try again',
			'duelWaiting.backToHome' => 'Back to home',
			'duelInvite.title' => 'Duel invite',
			'duelInvite.challengesYou' => 'is challenging you to a duel',
			'duelInvite.accept' => 'Accept',
			'duelInvite.decline' => 'Decline',
			'duelGame.title' => 'Duel',
			'duelGame.waitingForQuestion' => 'Preparing the question…',
			'duelGame.opponentProgress' => ({required Object index, required Object total}) => 'Opponent: question ${index}/${total}',
			'duelGame.waitingForOpponent' => 'You\'ve answered every question! Waiting for your opponent…',
			'duelGame.startFailed' => 'The game didn\'t start — check your connection and try again',
			'duelGame.backToHome' => 'Back to home',
			'duelResult.won' => 'You won!',
			'duelResult.lost' => 'You lost',
			'duelResult.draw' => 'It\'s a draw!',
			'duelResult.yourScoreLabel' => 'You',
			'duelResult.opponentScoreLabel' => 'Opponent',
			'notifications.title' => 'Notifications',
			'notifications.duelChallenge' => ({required Object name}) => '${name} challenged you to a duel',
			'notifications.duelChallengeGeneric' => 'You were challenged to a duel',
			'notifications.streakReminder' => 'Don\'t lose your 5-day streak — play today!',
			'notifications.top50' => 'You made it into the weekly Top 50',
			'notifications.friendRequest' => ({required Object name}) => '${name} sent you a friend request',
			'notifications.friendRequestGeneric' => 'You have a new friend request',
			'notifications.welcome' => 'Welcome to Zukkor! Start your first quiz',
			'notifications.emptyState' => 'No notifications yet',
			'editProfile.save' => 'Save',
			'editProfile.updated' => 'Profile updated',
			'notificationSettings.title' => 'Notification preferences',
			'notificationSettings.duelInvites' => 'Duel invites',
			'notificationSettings.streakReminders' => 'Streak reminders',
			'notificationSettings.leaderboardUpdates' => 'Leaderboard updates',
			'notificationSettings.friendRequests' => 'Friend requests',
			'notificationSettings.productUpdates' => 'Product updates',
			'privacyPolicy.title' => 'Privacy Policy',
			'privacyPolicy.collectionTitle' => 'Information we collect',
			'privacyPolicy.collectionBody' => 'We collect your name, username, and quiz activity — scores, categories played, and streaks — to run the game and show your progress.',
			'privacyPolicy.useTitle' => 'How we use it',
			'privacyPolicy.useBody' => 'Your data is used to operate Zukkor: matching you in duels and lobbies, computing XP and rankings, and showing your stats back to you.',
			'privacyPolicy.sharingTitle' => 'Sharing',
			'privacyPolicy.sharingBody' => 'We do not sell your data. Your name, avatar, and public stats are visible to other players as part of normal gameplay, such as the leaderboard, friends list, and duels.',
			'privacyPolicy.contactTitle' => 'Contact',
			'privacyPolicy.contactBody' => 'Questions about your data? Reach out through the Help Center and we will get back to you.',
			'termsOfUse.title' => 'Terms of Use',
			'termsOfUse.accountTitle' => 'Your account',
			'termsOfUse.accountBody' => 'You are responsible for keeping your account secure and for the activity that happens under it.',
			'termsOfUse.conductTitle' => 'Fair play',
			'termsOfUse.conductBody' => 'Cheating, exploiting bugs for XP, or harassing other players can result in a suspension.',
			'termsOfUse.contentTitle' => 'Content',
			'termsOfUse.contentBody' => 'Quiz questions and app content belong to Zukkor. Do not copy or redistribute them without permission.',
			'termsOfUse.changesTitle' => 'Changes',
			'termsOfUse.changesBody' => 'We may update these terms as Zukkor grows. We will let you know about any major changes.',
			'helpCenter.duelQuestion' => 'How do I start a duel?',
			'helpCenter.duelAnswer' => 'Go to Friends, pick an online friend, then choose a category. Your opponent gets an invite.',
			'helpCenter.xpQuestion' => 'How is XP calculated?',
			'helpCenter.xpAnswer' => 'You earn XP for each correct answer, plus a bonus for finishing a solo quiz or winning a duel.',
			'helpCenter.streakQuestion' => 'What happens if I miss a day?',
			'helpCenter.streakAnswer' => 'Your streak resets to zero if you skip a full day without playing at least one quiz.',
			'helpCenter.lobbyQuestion' => 'How many players can join a room?',
			'helpCenter.lobbyAnswer' => 'Rooms currently support up to 10 players.',
			'helpCenter.reportQuestion' => 'How do I report a bug or a bad question?',
			'helpCenter.reportAnswer' => 'Reach out to us through this Help Center. We are a small team and every report helps us improve Zukkor.',
			'bottomNav.home' => 'Home',
			'bottomNav.leaderboard' => 'Leaderboard',
			'bottomNav.friends' => 'Friends',
			'bottomNav.profile' => 'Profile',
			'bottomNav.comingSoon' => 'Coming soon',
			'onboarding.stepCount' => 'Step',
			'onboarding.continueButton' => 'Continue',
			'onboarding.start' => 'Start',
			'onboarding.avatarTitle' => 'Pick an avatar that suits you',
			'onboarding.avatarSubtitle' => 'You can change it anytime later',
			'onboarding.uploadPhoto' => 'Upload photo',
			'onboarding.profileTitle' => 'Let\'s get to know you',
			'onboarding.profileSubtitle' => 'This info will be visible on your profile and to your friends',
			'onboarding.firstNameLabel' => 'First name',
			'onboarding.firstNameHint' => 'Aziz',
			'onboarding.lastNameLabel' => 'Last name',
			'onboarding.lastNameHint' => 'Karimov',
			'onboarding.usernameLabel' => 'Username',
			'onboarding.usernameHint' => 'aziz_karimov',
			'onboarding.directionTitle' => 'Why are you using Zukkor?',
			'onboarding.directionSubtitle' => 'We\'ll recommend content and categories that fit you',
			'onboarding.directionRequired' => 'Please choose one to continue',
			'onboarding.studentUniTitle' => 'Student',
			'onboarding.studentUniSubtitle' => 'I study at university or college',
			'onboarding.studentSchoolTitle' => 'Pupil',
			'onboarding.studentSchoolSubtitle' => 'I study at school',
			'onboarding.examPrepTitle' => 'Exam prep',
			'onboarding.examPrepSubtitle' => 'I\'m preparing for an exam (e.g. IELTS)',
			'onboarding.casualTitle' => 'Just for fun',
			'onboarding.casualSubtitle' => 'Playing and passing the time',
			'introduction.skip' => 'Skip',
			'introduction.getStarted' => 'Get started',
			'introduction.welcomeTitle' => 'Welcome to Zukkor!',
			'introduction.welcomeSubtitle' => 'The knowledge competition app where learning feels like a game',
			'introduction.languageLabel' => 'Choose your language',
			'introduction.soloTitle' => 'Test yourself',
			'introduction.soloSubtitle' => 'Pick a category and answer questions solo — earn XP and beat your own best score',
			'introduction.duelTitle' => 'Challenge your friends',
			'introduction.duelSubtitle' => 'Duel a friend head-to-head, or create a room and play with a whole group in real time',
			'introduction.leaderboardTitle' => 'Climb the leaderboard',
			'introduction.leaderboardSubtitle' => 'Every correct answer earns XP — track your rank among friends and everyone else',
			'introduction.interestsTitle' => 'What are you into?',
			'introduction.interestsSubtitle' => 'Pick a few — we\'ll use these to recommend categories',
			'introduction.studyTitle' => 'Almost done!',
			'introduction.studySubtitle' => 'A couple more quick questions',
			'introduction.studyPlaceLabel' => 'Where do you study?',
			'introduction.quizLikingLabel' => 'Do you enjoy solving quizzes and puzzles?',
			'introduction.studyPlaceSchool' => 'School',
			'introduction.studyPlaceUniversity' => 'University',
			'introduction.studyPlaceExamPrep' => 'Exam prep',
			'introduction.quizLikingLoveIt' => 'Love it',
			'introduction.quizLikingItsOk' => 'It\'s ok',
			'introduction.quizLikingNotReally' => 'Not really',
			'introduction.otherOption' => 'Other',
			'introduction.otherFieldLabel' => 'Tell us more',
			'introduction.otherFieldHint' => 'Type here...',
			'auth.loginTitle' => 'Welcome back!',
			'auth.loginSubtitle' => 'Sign in and continue the game',
			'auth.registerTitle' => 'Create an account',
			'auth.registerSubtitle' => 'Sign up in a minute and get started',
			'auth.emailLabel' => 'Email',
			'auth.emailHint' => 'you@example.com',
			'auth.passwordLabel' => 'Password',
			'auth.passwordHint' => 'At least 8 characters',
			'auth.confirmPasswordLabel' => 'Confirm password',
			'auth.confirmPasswordHint' => 'Re-enter your password',
			'auth.loginButton' => 'Sign in',
			'auth.registerButton' => 'Sign up',
			'auth.orDivider' => 'or',
			'auth.continueWithGoogle' => 'Continue with Google',
			'auth.noAccountPrompt' => 'Don\'t have an account?',
			'auth.haveAccountPrompt' => 'Already have an account?',
			'auth.switchToRegister' => 'Sign up',
			'auth.switchToLogin' => 'Sign in',
			'authValidation.emailRequired' => 'Email is required',
			'authValidation.emailInvalid' => 'Invalid email format',
			'authValidation.passwordRequired' => 'Password is required',
			'authValidation.passwordTooShort' => 'Password must be at least 8 characters, with 1 uppercase letter and 1 number',
			'authValidation.passwordMismatch' => 'Passwords don\'t match',
			'authValidation.usernameRequired' => 'Username is required',
			'authValidation.usernameInvalid' => 'Username may only contain letters, numbers and underscores (3–30 characters)',
			'authValidation.usernameTaken' => 'This username is already taken',
			'authValidation.nameRequired' => 'This field is required',
			'authValidation.nameTooLong' => 'Too long (maximum 50 characters)',
			'errors.noConnection' => 'No internet connection. Please check your connection and try again.',
			'errors.timeout' => 'The server is not responding. Please try again shortly.',
			'errors.server' => 'A server error occurred. Please try again shortly.',
			'errors.unknown' => 'An unexpected error occurred.',
			'errors.invalidCredentials' => 'Incorrect email or password.',
			'errors.sessionExpired' => 'Your session has expired. Please sign in again.',
			'errors.googleCancelled' => 'Google sign-in was cancelled.',
			'aiQuiz.entryCardLabel' => 'Create a quiz from a document with AI',
			'aiQuiz.myQuizzesTitle' => 'My AI quizzes',
			'aiQuiz.createButton' => '+ Create a new AI quiz',
			'aiQuiz.emptyTitle' => 'You haven\'t created an AI quiz yet',
			'aiQuiz.emptySubtitle' => 'Upload a document (PDF, Word, or text) and get a quiz generated from it',
			'aiQuiz.deleteConfirmTitle' => 'Delete quiz',
			'aiQuiz.deleteConfirmMessage' => ({required Object name}) => 'Delete "${name}"? This can\'t be undone.',
			'aiQuiz.generateTitle' => 'Create a quiz with AI',
			'aiQuiz.generateSubtitle' => 'Create a quiz with AI from a document or a topic',
			'aiQuiz.modeDocumentLabel' => 'Document',
			'aiQuiz.modeTopicLabel' => 'Topic',
			'aiQuiz.pickFileLabel' => 'Choose a document (PDF, Word, text)',
			'aiQuiz.pickFileFirst' => 'Choose a document first',
			'aiQuiz.instructionLabel' => 'Instructions (optional)',
			'aiQuiz.instructionHint' => 'E.g.: 10 questions from chapter 3, or from the whole document',
			'aiQuiz.topicLabel' => 'Topic',
			'aiQuiz.topicHint' => 'E.g.: ask for WWII history questions at medium difficulty, or Uzbek movie questions',
			'aiQuiz.topicRequired' => 'Enter a topic',
			'aiQuiz.questionCountLabel' => 'Number of questions',
			'aiQuiz.generateButton' => 'Generate',
			'aiQuiz.generated' => 'Done! Saved to "My AI quizzes"',
			'aiQuiz.generatingTitle' => 'AI is generating questions...',
			'aiQuiz.generatingSubtitle' => 'This can take a moment, please wait',
			'aiQuiz.sourceAi' => 'AI',
			'aiQuiz.sourceManual' => 'Manual',
			'aiQuiz.visibilityPrivate' => 'Nobody',
			'aiQuiz.visibilityFriends' => 'Friends',
			'aiQuiz.visibilityPublic' => 'Everyone',
			'aiQuiz.visibilityDialogTitle' => 'Who can see this?',
			'aiQuiz.visibilityUpdated' => 'Visibility updated',
			'aiQuiz.createChooseTitle' => 'How do you want to create it?',
			'aiQuiz.createViaAi' => 'With AI',
			'aiQuiz.createManually' => 'Manually',
			'aiQuiz.createManualTitle' => 'Create a quiz manually',
			'aiQuiz.manualNameLabel' => 'Quiz name',
			'aiQuiz.manualNameHint' => 'E.g.: My geography test',
			'aiQuiz.manualNameRequired' => 'Enter a quiz name',
			'aiQuiz.manualQuestionLabel' => ({required Object number}) => 'Question ${number}',
			'aiQuiz.manualQuestionTextLabel' => 'Question text',
			'aiQuiz.manualOptionLabel' => ({required Object number}) => 'Option ${number}',
			'aiQuiz.manualFillAllFields' => 'Fill in all fields',
			'aiQuiz.manualAddQuestion' => '+ Add question',
			'aiQuiz.manualSubmit' => 'Create',
			_ => null,
		};
	}
}
