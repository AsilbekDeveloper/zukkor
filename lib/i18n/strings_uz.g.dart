///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:slang/generated.dart';
import 'strings.g.dart';

// Path: <root>
class TranslationsUz with BaseTranslations<AppLocale, Translations> implements Translations {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsUz({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.uz,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <uz>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key);

	late final TranslationsUz _root = this; // ignore: unused_field

	@override 
	TranslationsUz $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsUz(meta: meta ?? this.$meta);

	// Translations
	@override late final _Translations$common$uz common = _Translations$common$uz._(_root);
	@override late final _Translations$home$uz home = _Translations$home$uz._(_root);
	@override late final _Translations$categories$uz categories = _Translations$categories$uz._(_root);
	@override late final _Translations$leaderboard$uz leaderboard = _Translations$leaderboard$uz._(_root);
	@override late final _Translations$fullLeaderboard$uz fullLeaderboard = _Translations$fullLeaderboard$uz._(_root);
	@override late final _Translations$playerDetail$uz playerDetail = _Translations$playerDetail$uz._(_root);
	@override late final _Translations$friends$uz friends = _Translations$friends$uz._(_root);
	@override late final _Translations$addFriend$uz addFriend = _Translations$addFriend$uz._(_root);
	@override late final _Translations$friendRequests$uz friendRequests = _Translations$friendRequests$uz._(_root);
	@override late final _Translations$duelPick$uz duelPick = _Translations$duelPick$uz._(_root);
	@override late final _Translations$profile$uz profile = _Translations$profile$uz._(_root);
	@override late final _Translations$settings$uz settings = _Translations$settings$uz._(_root);
	@override late final _Translations$changePassword$uz changePassword = _Translations$changePassword$uz._(_root);
	@override late final _Translations$deleteAccount$uz deleteAccount = _Translations$deleteAccount$uz._(_root);
	@override late final _Translations$history$uz history = _Translations$history$uz._(_root);
	@override late final _Translations$quizSetup$uz quizSetup = _Translations$quizSetup$uz._(_root);
	@override late final _Translations$quizIntro$uz quizIntro = _Translations$quizIntro$uz._(_root);
	@override late final _Translations$quiz$uz quiz = _Translations$quiz$uz._(_root);
	@override late final _Translations$ballReveal$uz ballReveal = _Translations$ballReveal$uz._(_root);
	@override late final _Translations$result$uz result = _Translations$result$uz._(_root);
	@override late final _Translations$joinCode$uz joinCode = _Translations$joinCode$uz._(_root);
	@override late final _Translations$lobby$uz lobby = _Translations$lobby$uz._(_root);
	@override late final _Translations$lobbyGame$uz lobbyGame = _Translations$lobbyGame$uz._(_root);
	@override late final _Translations$lobbyResult$uz lobbyResult = _Translations$lobbyResult$uz._(_root);
	@override late final _Translations$duelWaiting$uz duelWaiting = _Translations$duelWaiting$uz._(_root);
	@override late final _Translations$duelInvite$uz duelInvite = _Translations$duelInvite$uz._(_root);
	@override late final _Translations$duelGame$uz duelGame = _Translations$duelGame$uz._(_root);
	@override late final _Translations$duelResult$uz duelResult = _Translations$duelResult$uz._(_root);
	@override late final _Translations$notifications$uz notifications = _Translations$notifications$uz._(_root);
	@override late final _Translations$editProfile$uz editProfile = _Translations$editProfile$uz._(_root);
	@override late final _Translations$notificationSettings$uz notificationSettings = _Translations$notificationSettings$uz._(_root);
	@override late final _Translations$privacyPolicy$uz privacyPolicy = _Translations$privacyPolicy$uz._(_root);
	@override late final _Translations$termsOfUse$uz termsOfUse = _Translations$termsOfUse$uz._(_root);
	@override late final _Translations$helpCenter$uz helpCenter = _Translations$helpCenter$uz._(_root);
	@override late final _Translations$bottomNav$uz bottomNav = _Translations$bottomNav$uz._(_root);
	@override late final _Translations$onboarding$uz onboarding = _Translations$onboarding$uz._(_root);
	@override late final _Translations$introduction$uz introduction = _Translations$introduction$uz._(_root);
	@override late final _Translations$auth$uz auth = _Translations$auth$uz._(_root);
	@override late final _Translations$authValidation$uz authValidation = _Translations$authValidation$uz._(_root);
	@override late final _Translations$errors$uz errors = _Translations$errors$uz._(_root);
	@override late final _Translations$aiQuiz$uz aiQuiz = _Translations$aiQuiz$uz._(_root);
}

// Path: common
class _Translations$common$uz implements Translations$common$en {
	_Translations$common$uz._(this._root);

	final TranslationsUz _root; // ignore: unused_field

	// Translations
	@override String get appName => 'Zukkor';
	@override String get appTagline => 'Bilim musobaqasi';
	@override String get ok => 'OK';
	@override String get cancel => 'Bekor qilish';
	@override String get retry => 'Qayta urinish';
	@override String get loading => 'Yuklanmoqda...';
	@override String get delete => 'O\'chirish';
	@override String dayUnit({required num count}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('uz'))(count,
		one: 'kun',
		other: 'kun',
	);
	@override String friendsCount({required num count}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('uz'))(count,
		one: '${count} do\'stingiz bor',
		other: '${count} do\'stingiz bor',
	);
	@override String questionCount({required num count}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('uz'))(count,
		one: '${count} savol',
		other: '${count} savol',
	);
}

// Path: home
class _Translations$home$uz implements Translations$home$en {
	_Translations$home$uz._(this._root);

	final TranslationsUz _root; // ignore: unused_field

	// Translations
	@override String get greeting => 'Xayrli tong';
	@override String get duelHeroTitle => 'Bugun kim kuchli?';
	@override String get duelHeroSubtitle => 'Do\'stingizga yoki tasodifiy raqibga chaqiruv tashlang';
	@override String get startDuel => 'Duel boshlash';
	@override String get totalXpLabel => 'Jami XP';
	@override String get rankLabel => 'O\'rin';
	@override String get levelLabel => 'Daraja';
	@override String get createRoom => 'Xona yaratish';
	@override String get joinWithCode => 'Kod bilan qo\'shilish';
	@override String get categoriesTitle => 'Kategoriyalar';
	@override String get seeAll => 'Barchasi';
	@override String get challengeToDuel => 'Duelga chaqirish';
}

// Path: categories
class _Translations$categories$uz implements Translations$categories$en {
	_Translations$categories$uz._(this._root);

	final TranslationsUz _root; // ignore: unused_field

	// Translations
	@override String get title => 'Kategoriya tanlang';
}

// Path: leaderboard
class _Translations$leaderboard$uz implements Translations$leaderboard$en {
	_Translations$leaderboard$uz._(this._root);

	final TranslationsUz _root; // ignore: unused_field

	// Translations
	@override String get greeting => 'Reyting';
	@override String get title => 'Kim eng zo\'r?';
	@override String get segmentWeekly => 'Haftalik';
	@override String get segmentAllTime => 'Barcha vaqt';
	@override String get segmentFriends => 'Do\'stlar';
	@override String get you => 'Siz';
	@override String get seeFullRanking => 'To\'liq reytingni ko\'rish';
	@override String xpValue({required Object xp}) => '${xp} XP';
	@override String get anonymousPlayer => 'O\'yinchi';
}

// Path: fullLeaderboard
class _Translations$fullLeaderboard$uz implements Translations$fullLeaderboard$en {
	_Translations$fullLeaderboard$uz._(this._root);

	final TranslationsUz _root; // ignore: unused_field

	// Translations
	@override String get title => 'To\'liq reyting';
}

// Path: playerDetail
class _Translations$playerDetail$uz implements Translations$playerDetail$en {
	_Translations$playerDetail$uz._(this._root);

	final TranslationsUz _root; // ignore: unused_field

	// Translations
	@override String get title => 'Profil';
	@override String get streakLabel => 'Seriya';
	@override String get addToFriends => 'Do\'stlikka qo\'shish';
	@override String get requestSent => 'Yuborildi';
	@override String rankedLabel({required Object rank, required Object xp}) => '#${rank} o\'rin · ${xp} XP';
	@override String get alreadyFriends => 'Siz do\'stsiz';
	@override String get acceptRequest => 'Qabul qilish';
	@override String get declineRequest => 'Rad etish';
}

// Path: friends
class _Translations$friends$uz implements Translations$friends$en {
	_Translations$friends$uz._(this._root);

	final TranslationsUz _root; // ignore: unused_field

	// Translations
	@override String get addFriend => 'Do\'st qo\'shish';
	@override String get searchPlaceholder => 'Do\'stlarni qidirish';
	@override String get allSection => 'Barcha do\'stlar';
	@override String get noneFound => 'Do\'stlar topilmadi';
}

// Path: addFriend
class _Translations$addFriend$uz implements Translations$addFriend$en {
	_Translations$addFriend$uz._(this._root);

	final TranslationsUz _root; // ignore: unused_field

	// Translations
	@override String get searchByUsername => 'Foydalanuvchi nomi bo\'yicha qidirish';
	@override String get orViaInviteLink => 'Yoki taklif havolasi orqali';
	@override String get yourInviteCode => 'Sizning taklif kodingiz';
	@override String get shareLink => 'Havolani ulashish';
	@override String get addButton => 'Qo\'shish';
	@override String get requestedLabel => 'So\'rov yuborildi';
	@override String get noUsersFound => 'Foydalanuvchilar topilmadi';
}

// Path: friendRequests
class _Translations$friendRequests$uz implements Translations$friendRequests$en {
	_Translations$friendRequests$uz._(this._root);

	final TranslationsUz _root; // ignore: unused_field

	// Translations
	@override String get title => 'Do\'stlik so\'rovlari';
	@override String get emptyState => 'Hozircha so\'rovlar yo\'q';
}

// Path: duelPick
class _Translations$duelPick$uz implements Translations$duelPick$en {
	_Translations$duelPick$uz._(this._root);

	final TranslationsUz _root; // ignore: unused_field

	// Translations
	@override String get title => '1v1 Duel';
	@override String get chooseYourFriend => 'Do\'stingizni tanlang';
}

// Path: profile
class _Translations$profile$uz implements Translations$profile$en {
	_Translations$profile$uz._(this._root);

	final TranslationsUz _root; // ignore: unused_field

	// Translations
	@override String get editProfile => 'Profilni tahrirlash';
	@override String get settings => 'Sozlamalar';
	@override String get statTotalGames => 'Jami o\'yinlar';
	@override String get statWinRate => 'G\'alaba foizi';
	@override String get statLongestStreak => 'Eng uzun seriya';
	@override String get gameHistory => 'O\'yinlar tarixi';
	@override String get settingsAndHelp => 'Sozlamalar va yordam';
	@override String levelWithTitle({required Object level, required Object title}) => '${level}-daraja · ${title}';
	@override String xpProgressLabel({required Object current, required Object target, required Object remaining}) => '${current} / ${target} XP · keyingi darajagacha ${remaining}';
}

// Path: settings
class _Translations$settings$uz implements Translations$settings$en {
	_Translations$settings$uz._(this._root);

	final TranslationsUz _root; // ignore: unused_field

	// Translations
	@override String get groupGeneral => 'Umumiy';
	@override String get language => 'Til';
	@override String get notifications => 'Bildirishnomalar';
	@override String get theme => 'Mavzu';
	@override String get themeLight => 'Yorug\'';
	@override String get themeDark => 'Qorong\'i';
	@override String get soundEffects => 'Ovoz effektlari';
	@override String get groupAccount => 'Hisob';
	@override String get privacy => 'Maxfiylik';
	@override String get helpCenter => 'Yordam markazi';
	@override String get termsOfUse => 'Foydalanish shartlari';
	@override String get changePassword => 'Parolni o\'zgartirish';
	@override String get logOut => 'Chiqish';
	@override String get groupDangerZone => 'Xavfli zona';
	@override String get deleteAccount => 'Akkauntni o\'chirish';
}

// Path: changePassword
class _Translations$changePassword$uz implements Translations$changePassword$en {
	_Translations$changePassword$uz._(this._root);

	final TranslationsUz _root; // ignore: unused_field

	// Translations
	@override String get title => 'Parolni o\'zgartirish';
	@override String get currentPasswordLabel => 'Joriy parol';
	@override String get currentPasswordHint => 'Joriy parolingizni kiriting';
	@override String get newPasswordLabel => 'Yangi parol';
	@override String get newPasswordHint => 'Kamida 8 ta belgi';
	@override String get confirmNewPasswordLabel => 'Yangi parolni tasdiqlang';
	@override String get confirmNewPasswordHint => 'Yangi parolni qayta kiriting';
	@override String get saveButton => 'Saqlash';
	@override String get updated => 'Parol muvaffaqiyatli o\'zgartirildi';
}

// Path: deleteAccount
class _Translations$deleteAccount$uz implements Translations$deleteAccount$en {
	_Translations$deleteAccount$uz._(this._root);

	final TranslationsUz _root; // ignore: unused_field

	// Translations
	@override String get confirmTitle => 'Akkauntni o\'chirish';
	@override String get confirmMessage => 'Bu amalni ortga qaytarib bo\'lmaydi. Barcha ma\'lumotlaringiz — do\'stlar, tarix, ball — butunlay o\'chiriladi. Davom etish uchun parolingizni kiriting.';
	@override String get confirmButton => 'Ha, o\'chirish';
}

// Path: history
class _Translations$history$uz implements Translations$history$en {
	_Translations$history$uz._(this._root);

	final TranslationsUz _root; // ignore: unused_field

	// Translations
	@override String get segmentAll => 'Barchasi';
	@override String get segmentSolo => 'Yakka';
	@override String get segmentDuel => 'Duel';
	@override String get segmentLobby => 'Xona';
	@override String get winBadge => 'G\'alaba';
	@override String get lossBadge => 'Mag\'lubiyat';
	@override String get drawBadge => 'Durrang';
	@override String get today => 'Bugun';
	@override String get yesterday => 'Kecha';
	@override String daysAgo({required Object days}) => '${days} kun oldin';
	@override String get emptyState => 'Bu turdagi o\'yinlar hali saqlanmaydi';
	@override String get noGamesYet => 'Hali o\'ynalgan o\'yinlar yo\'q';
	@override String lobbyPlayerCount({required Object count}) => '${count} o\'yinchi';
}

// Path: quizSetup
class _Translations$quizSetup$uz implements Translations$quizSetup$en {
	_Translations$quizSetup$uz._(this._root);

	final TranslationsUz _root; // ignore: unused_field

	// Translations
	@override String get title => 'Nechta savol?';
	@override String get subtitle => 'Tezkor variantni tanlang yoki o\'zingiz belgilang';
	@override String get customLabel => 'O\'zi tanlash';
	@override String get startButton => 'Quizni boshlash';
}

// Path: quizIntro
class _Translations$quizIntro$uz implements Translations$quizIntro$en {
	_Translations$quizIntro$uz._(this._root);

	final TranslationsUz _root; // ignore: unused_field

	// Translations
	@override String get startLabel => 'Boshlash!';
}

// Path: quiz
class _Translations$quiz$uz implements Translations$quiz$en {
	_Translations$quiz$uz._(this._root);

	final TranslationsUz _root; // ignore: unused_field

	// Translations
	@override String questionProgress({required Object current, required Object total}) => '${current}/${total}-savol';
}

// Path: ballReveal
class _Translations$ballReveal$uz implements Translations$ballReveal$en {
	_Translations$ballReveal$uz._(this._root);

	final TranslationsUz _root; // ignore: unused_field

	// Translations
	@override String get title => 'Sizning balingiz';
	@override String get ballLabel => 'ball';
}

// Path: result
class _Translations$result$uz implements Translations$result$en {
	_Translations$result$uz._(this._root);

	final TranslationsUz _root; // ignore: unused_field

	// Translations
	@override String get label => 'Natija';
	@override String summary({required Object total, required Object correct}) => '${total} tadan ${correct} tasi to\'g\'ri';
	@override String totalBall({required Object ball}) => '${ball} ball';
	@override String xpEarned({required Object xp}) => '+${xp} XP';
	@override String get playAgain => 'Yana o\'ynash';
	@override String get challengeAFriend => 'Do\'stni chaqirish';
	@override String get backToHome => 'Bosh sahifaga';
	@override String get breakdownTitle => 'Savollar bo\'yicha natija';
}

// Path: joinCode
class _Translations$joinCode$uz implements Translations$joinCode$en {
	_Translations$joinCode$uz._(this._root);

	final TranslationsUz _root; // ignore: unused_field

	// Translations
	@override String get hint => 'Do\'stingiz yuborgan 6 xonali xona kodini kiriting';
	@override String get joinButton => 'Qo\'shilish';
	@override String codeDigitLabel({required Object position}) => '${position}-raqam';
	@override String get roomNotFound => 'Bunday xona topilmadi';
	@override String get roomFull => 'Xona to\'lgan';
	@override String get alreadyStarted => 'Bu xonada o\'yin allaqachon boshlangan';
	@override String get timedOut => 'Bog\'lanib bo\'lmadi — internetni tekshirib qayta urinib ko\'ring';
}

// Path: lobby
class _Translations$lobby$uz implements Translations$lobby$en {
	_Translations$lobby$uz._(this._root);

	final TranslationsUz _root; // ignore: unused_field

	// Translations
	@override String get title => 'Ko\'p o\'yinchili xona';
	@override String get roomCode => 'Xona kodi';
	@override String get players => 'O\'yinchilar';
	@override String get hostRole => 'Xost';
	@override String get guestRole => 'Mehmon';
	@override String get startGame => 'O\'yinni boshlash';
	@override String get waitingForHost => 'Xost o\'yinni boshlashini kutmoqda…';
	@override String playerCount({required Object current, required Object max}) => '${current}/${max}';
	@override String get closedMessage => 'Xost xonani tark etdi, xona yopildi';
	@override String get creatingRoom => 'Xona yaratilmoqda…';
	@override String get createFailed => 'Xona yaratib bo\'lmadi — internetni tekshirib qayta urinib ko\'ring';
	@override String get backToHome => 'Bosh sahifaga';
}

// Path: lobbyGame
class _Translations$lobbyGame$uz implements Translations$lobbyGame$en {
	_Translations$lobbyGame$uz._(this._root);

	final TranslationsUz _root; // ignore: unused_field

	// Translations
	@override String get title => 'Xona';
	@override String get waitingForQuestion => 'Savol tayyorlanmoqda…';
	@override String get waitingForOthers => 'Siz barcha savollarga javob berdingiz! Boshqalarni kutmoqdamiz…';
	@override String get startFailed => 'O\'yin boshlanmadi — internetni tekshirib qayta urinib ko\'ring';
	@override String get backToHome => 'Bosh sahifaga';
}

// Path: lobbyResult
class _Translations$lobbyResult$uz implements Translations$lobbyResult$en {
	_Translations$lobbyResult$uz._(this._root);

	final TranslationsUz _root; // ignore: unused_field

	// Translations
	@override String get title => 'Xona natijalari';
	@override String get subtitle => 'Xonadagi hammaning natijasi shunday';
	@override String get playAgain => 'Yana o\'ynash';
}

// Path: duelWaiting
class _Translations$duelWaiting$uz implements Translations$duelWaiting$en {
	_Translations$duelWaiting$uz._(this._root);

	final TranslationsUz _root; // ignore: unused_field

	// Translations
	@override String get title => 'Duel';
	@override String get waitingForAccept => 'Taklif yuborildi, javobni kutmoqda…';
	@override String get declined => 'Taklif rad etildi';
	@override String get expired => 'Taklif muddati tugadi';
	@override String get failed => 'Taklifni yuborib bo\'lmadi';
	@override String get timedOut => 'Do\'stingizga ulanib bo\'lmadi — internetni tekshirib qayta urinib ko\'ring';
	@override String get backToHome => 'Bosh sahifaga';
}

// Path: duelInvite
class _Translations$duelInvite$uz implements Translations$duelInvite$en {
	_Translations$duelInvite$uz._(this._root);

	final TranslationsUz _root; // ignore: unused_field

	// Translations
	@override String get title => 'Duelga taklif';
	@override String get challengesYou => 'sizni duelga chaqirmoqda';
	@override String get accept => 'Qabul qilish';
	@override String get decline => 'Rad etish';
}

// Path: duelGame
class _Translations$duelGame$uz implements Translations$duelGame$en {
	_Translations$duelGame$uz._(this._root);

	final TranslationsUz _root; // ignore: unused_field

	// Translations
	@override String get title => 'Duel';
	@override String get waitingForQuestion => 'Savol tayyorlanmoqda…';
	@override String opponentProgress({required Object index, required Object total}) => 'Raqib: ${index}/${total} savolda';
	@override String get waitingForOpponent => 'Siz barcha savollarga javob berdingiz! Sherigingizni kutmoqdamiz…';
	@override String get startFailed => 'O\'yin boshlanmadi — internetni tekshirib qayta urinib ko\'ring';
	@override String get backToHome => 'Bosh sahifaga';
}

// Path: duelResult
class _Translations$duelResult$uz implements Translations$duelResult$en {
	_Translations$duelResult$uz._(this._root);

	final TranslationsUz _root; // ignore: unused_field

	// Translations
	@override String get won => 'Siz g\'olib bo\'ldingiz!';
	@override String get lost => 'Siz yutqazdingiz';
	@override String get draw => 'Durrang!';
	@override String get yourScoreLabel => 'Siz';
	@override String get opponentScoreLabel => 'Raqib';
}

// Path: notifications
class _Translations$notifications$uz implements Translations$notifications$en {
	_Translations$notifications$uz._(this._root);

	final TranslationsUz _root; // ignore: unused_field

	// Translations
	@override String get title => 'Bildirishnomalar';
	@override String duelChallenge({required Object name}) => '${name} sizni duelga chaqirdi';
	@override String get duelChallengeGeneric => 'Sizni duelga chaqirishdi';
	@override String get streakReminder => '5 kunlik seriyangizni yo\'qotmang — bugun o\'ynang!';
	@override String get top50 => 'Siz haftalik Top 50ga kirdingiz';
	@override String friendRequest({required Object name}) => '${name} sizga do\'stlik so\'rovi yubordi';
	@override String get friendRequestGeneric => 'Sizga do\'stlik so\'rovi keldi';
	@override String get welcome => 'Zukkorga xush kelibsiz! Birinchi viktorinangizni boshlang';
	@override String get emptyState => 'Hozircha bildirishnomalar yo\'q';
}

// Path: editProfile
class _Translations$editProfile$uz implements Translations$editProfile$en {
	_Translations$editProfile$uz._(this._root);

	final TranslationsUz _root; // ignore: unused_field

	// Translations
	@override String get save => 'Saqlash';
	@override String get updated => 'Profil yangilandi';
}

// Path: notificationSettings
class _Translations$notificationSettings$uz implements Translations$notificationSettings$en {
	_Translations$notificationSettings$uz._(this._root);

	final TranslationsUz _root; // ignore: unused_field

	// Translations
	@override String get title => 'Bildirishnoma sozlamalari';
	@override String get duelInvites => 'Duel takliflari';
	@override String get streakReminders => 'Seriya eslatmalari';
	@override String get leaderboardUpdates => 'Reyting yangilanishlari';
	@override String get friendRequests => 'Do\'stlik so\'rovlari';
	@override String get productUpdates => 'Yangilanishlar haqida';
}

// Path: privacyPolicy
class _Translations$privacyPolicy$uz implements Translations$privacyPolicy$en {
	_Translations$privacyPolicy$uz._(this._root);

	final TranslationsUz _root; // ignore: unused_field

	// Translations
	@override String get title => 'Maxfiylik siyosati';
	@override String get collectionTitle => 'Biz to\'playdigan ma\'lumotlar';
	@override String get collectionBody => 'O\'yinni ishga tushirish va rivojlanishingizni ko\'rsatish uchun ismingiz, foydalanuvchi nomingiz va viktorina faoliyatingizni — ballar, o\'ynalgan kategoriyalar va seriyalarni — to\'playmiz.';
	@override String get useTitle => 'Ulardan qanday foydalanamiz';
	@override String get useBody => 'Ma\'lumotlaringiz Zukkorni ishga tushirish uchun ishlatiladi: sizni dueller va xonalarda moslashtirish, XP va reytinglarni hisoblash, hamda statistikangizni sizga ko\'rsatish.';
	@override String get sharingTitle => 'Ulashish';
	@override String get sharingBody => 'Biz ma\'lumotlaringizni sotmaymiz. Ismingiz, avataringiz va ochiq statistikangiz oddiy o\'yin jarayonining bir qismi sifatida boshqa o\'yinchilarga ko\'rinadi — masalan, reyting, do\'stlar ro\'yxati va duellarda.';
	@override String get contactTitle => 'Aloqa';
	@override String get contactBody => 'Ma\'lumotlaringiz haqida savollaringiz bormi? Yordam markazi orqali murojaat qiling, biz siz bilan bog\'lanamiz.';
}

// Path: termsOfUse
class _Translations$termsOfUse$uz implements Translations$termsOfUse$en {
	_Translations$termsOfUse$uz._(this._root);

	final TranslationsUz _root; // ignore: unused_field

	// Translations
	@override String get title => 'Foydalanish shartlari';
	@override String get accountTitle => 'Hisobingiz';
	@override String get accountBody => 'Hisobingiz xavfsizligini saqlash va u orqali sodir bo\'ladigan faoliyat uchun siz javobgarsiz.';
	@override String get conductTitle => 'Halol o\'yin';
	@override String get conductBody => 'Aldash, XP uchun xatolardan foydalanish yoki boshqa o\'yinchilarni bezovta qilish hisobingizning to\'xtatib qo\'yilishiga olib kelishi mumkin.';
	@override String get contentTitle => 'Kontent';
	@override String get contentBody => 'Viktorina savollari va ilova kontenti Zukkorga tegishli. Ularni ruxsatsiz nusxalash yoki tarqatish mumkin emas.';
	@override String get changesTitle => 'O\'zgarishlar';
	@override String get changesBody => 'Zukkor rivojlanishi bilan ushbu shartlarni yangilashimiz mumkin. Har qanday muhim o\'zgarish haqida sizga xabar beramiz.';
}

// Path: helpCenter
class _Translations$helpCenter$uz implements Translations$helpCenter$en {
	_Translations$helpCenter$uz._(this._root);

	final TranslationsUz _root; // ignore: unused_field

	// Translations
	@override String get duelQuestion => 'Duelni qanday boshlayman?';
	@override String get duelAnswer => 'Do\'stlar bo\'limiga o\'ting, onlayn do\'stni tanlang, so\'ng kategoriyani tanlang. Raqibingizga taklif yuboriladi.';
	@override String get xpQuestion => 'XP qanday hisoblanadi?';
	@override String get xpAnswer => 'Har bir to\'g\'ri javob uchun XP olasiz, shuningdek yakka viktorinani tugatgan yoki duelda g\'alaba qozongan uchun bonus beriladi.';
	@override String get streakQuestion => 'Bir kun o\'tkazib yuborsam nima bo\'ladi?';
	@override String get streakAnswer => 'Agar butun kun davomida kamida bitta viktorina o\'ynamasangiz, seriyangiz nolga tushadi.';
	@override String get lobbyQuestion => 'Xonaga nechta o\'yinchi qo\'shilishi mumkin?';
	@override String get lobbyAnswer => 'Hozircha xonalar 10 tagacha o\'yinchini qo\'llab-quvvatlaydi.';
	@override String get reportQuestion => 'Xato yoki noto\'g\'ri savol haqida qanday xabar beraman?';
	@override String get reportAnswer => 'Shu Yordam markazi orqali biz bilan bog\'laning. Biz kichik jamoamiz va har bir xabar Zukkorni yaxshilashga yordam beradi.';
}

// Path: bottomNav
class _Translations$bottomNav$uz implements Translations$bottomNav$en {
	_Translations$bottomNav$uz._(this._root);

	final TranslationsUz _root; // ignore: unused_field

	// Translations
	@override String get home => 'Bosh sahifa';
	@override String get leaderboard => 'Reyting';
	@override String get friends => 'Do\'stlar';
	@override String get profile => 'Profil';
	@override String get comingSoon => 'Tez orada';
}

// Path: onboarding
class _Translations$onboarding$uz implements Translations$onboarding$en {
	_Translations$onboarding$uz._(this._root);

	final TranslationsUz _root; // ignore: unused_field

	// Translations
	@override String get stepCount => 'Bosqich';
	@override String get continueButton => 'Davom etish';
	@override String get start => 'Boshlash';
	@override String get avatarTitle => 'O\'zingizga mos avatar tanlang';
	@override String get avatarSubtitle => 'Uni istalgan vaqtda o\'zgartirishingiz mumkin';
	@override String get uploadPhoto => 'Rasm yuklash';
	@override String get profileTitle => 'Siz bilan tanishib olaylik';
	@override String get profileSubtitle => 'Bu ma\'lumot profilingizda va do\'stlaringizga ko\'rinadi';
	@override String get firstNameLabel => 'Ism';
	@override String get firstNameHint => 'Aziz';
	@override String get lastNameLabel => 'Familiya';
	@override String get lastNameHint => 'Karimov';
	@override String get usernameLabel => 'Foydalanuvchi nomi';
	@override String get usernameHint => 'aziz_karimov';
	@override String get directionTitle => 'Zukkordan nima uchun foydalanyapsiz?';
	@override String get directionSubtitle => 'Sizga mos kontent va kategoriyalarni tavsiya qilamiz';
	@override String get directionRequired => 'Davom etish uchun birini tanlang';
	@override String get studentUniTitle => 'Talaba';
	@override String get studentUniSubtitle => 'Universitet yoki kollejda o\'qiyman';
	@override String get studentSchoolTitle => 'O\'quvchi';
	@override String get studentSchoolSubtitle => 'Maktabda o\'qiyman';
	@override String get examPrepTitle => 'Imtihonga tayyorgarlik';
	@override String get examPrepSubtitle => 'Imtihonga tayyorlanyapman (masalan, IELTS)';
	@override String get casualTitle => 'Shunchaki qiziqib';
	@override String get casualSubtitle => 'O\'ynab, vaqt o\'tkazyapman';
}

// Path: introduction
class _Translations$introduction$uz implements Translations$introduction$en {
	_Translations$introduction$uz._(this._root);

	final TranslationsUz _root; // ignore: unused_field

	// Translations
	@override String get skip => 'O\'tkazib yuborish';
	@override String get getStarted => 'Boshlash';
	@override String get welcomeTitle => 'Zukkorga xush kelibsiz!';
	@override String get welcomeSubtitle => 'O\'rganish o\'yinga aylangan bilim musobaqasi ilovasi';
	@override String get languageLabel => 'Tilingizni tanlang';
	@override String get soloTitle => 'O\'zingizni sinang';
	@override String get soloSubtitle => 'Kategoriya tanlang va yakka savollarga javob bering — XP to\'plang va o\'z rekordingizni yenging';
	@override String get duelTitle => 'Do\'stlaringizga qarshi chiqing';
	@override String get duelSubtitle => 'Do\'st bilan yakkama-yakka duel qiling yoki xona yaratib, butun guruh bilan real vaqtda o\'ynang';
	@override String get leaderboardTitle => 'Reytingda ko\'tariling';
	@override String get leaderboardSubtitle => 'Har bir to\'g\'ri javob XP beradi — do\'stlaringiz va boshqalar orasidagi o\'rningizni kuzating';
	@override String get interestsTitle => 'Nimalarga qiziqasiz?';
	@override String get interestsSubtitle => 'Bir nechtasini tanlang — ulardan kategoriyalarni tavsiya qilishda foydalanamiz';
	@override String get studyTitle => 'Deyarli tayyor!';
	@override String get studySubtitle => 'Yana bir nechta qisqa savol';
	@override String get studyPlaceLabel => 'Qayerda o\'qiysiz?';
	@override String get quizLikingLabel => 'Viktorina va topishmoqlarni yechishni yoqtirasizmi?';
	@override String get studyPlaceSchool => 'Maktab';
	@override String get studyPlaceUniversity => 'Universitet';
	@override String get studyPlaceExamPrep => 'Imtihonga tayyorgarlik';
	@override String get quizLikingLoveIt => 'Juda yoqtiraman';
	@override String get quizLikingItsOk => 'Yomon emas';
	@override String get quizLikingNotReally => 'Unchalik emas';
	@override String get otherOption => 'Boshqa';
	@override String get otherFieldLabel => 'Batafsilroq ayting';
	@override String get otherFieldHint => 'Shu yerga yozing...';
}

// Path: auth
class _Translations$auth$uz implements Translations$auth$en {
	_Translations$auth$uz._(this._root);

	final TranslationsUz _root; // ignore: unused_field

	// Translations
	@override String get loginTitle => 'Xush kelibsiz!';
	@override String get loginSubtitle => 'Tizimga kiring va o\'yinni davom ettiring';
	@override String get registerTitle => 'Hisob yaratish';
	@override String get registerSubtitle => 'Bir daqiqada ro\'yxatdan o\'ting va boshlang';
	@override String get emailLabel => 'Email';
	@override String get emailHint => 'siz@misol.com';
	@override String get passwordLabel => 'Parol';
	@override String get passwordHint => 'Kamida 8 ta belgi';
	@override String get confirmPasswordLabel => 'Parolni tasdiqlang';
	@override String get confirmPasswordHint => 'Parolingizni qayta kiriting';
	@override String get loginButton => 'Kirish';
	@override String get registerButton => 'Ro\'yxatdan o\'tish';
	@override String get orDivider => 'yoki';
	@override String get continueWithGoogle => 'Google orqali davom etish';
	@override String get noAccountPrompt => 'Hisobingiz yo\'qmi?';
	@override String get haveAccountPrompt => 'Hisobingiz bormi?';
	@override String get switchToRegister => 'Ro\'yxatdan o\'tish';
	@override String get switchToLogin => 'Kirish';
}

// Path: authValidation
class _Translations$authValidation$uz implements Translations$authValidation$en {
	_Translations$authValidation$uz._(this._root);

	final TranslationsUz _root; // ignore: unused_field

	// Translations
	@override String get emailRequired => 'Email kiritilishi shart';
	@override String get emailInvalid => 'Email formati noto\'g\'ri';
	@override String get passwordRequired => 'Parol kiritilishi shart';
	@override String get passwordTooShort => 'Parol kamida 8 ta belgi, 1 ta katta harf va 1 ta raqamdan iborat bo\'lishi kerak';
	@override String get passwordMismatch => 'Parollar mos kelmadi';
	@override String get usernameRequired => 'Foydalanuvchi nomi kiritilishi shart';
	@override String get usernameInvalid => 'Foydalanuvchi nomi faqat harflar, raqamlar va pastki chiziqdan iborat bo\'lishi mumkin (3–30 belgi)';
	@override String get usernameTaken => 'Bu foydalanuvchi nomi band';
	@override String get nameRequired => 'Bu maydon to\'ldirilishi shart';
	@override String get nameTooLong => 'Juda uzun (maksimal 50 belgi)';
}

// Path: errors
class _Translations$errors$uz implements Translations$errors$en {
	_Translations$errors$uz._(this._root);

	final TranslationsUz _root; // ignore: unused_field

	// Translations
	@override String get noConnection => 'Internet aloqasi yo\'q. Ulanishingizni tekshirib, qayta urinib ko\'ring.';
	@override String get timeout => 'Server javob bermayapti. Birozdan so\'ng qayta urinib ko\'ring.';
	@override String get server => 'Server xatoligi yuz berdi. Birozdan so\'ng qayta urinib ko\'ring.';
	@override String get unknown => 'Kutilmagan xatolik yuz berdi.';
	@override String get invalidCredentials => 'Email yoki parol noto\'g\'ri.';
	@override String get sessionExpired => 'Sessiyangiz muddati tugadi. Qaytadan tizimga kiring.';
	@override String get googleCancelled => 'Google orqali kirish bekor qilindi.';
}

// Path: aiQuiz
class _Translations$aiQuiz$uz implements Translations$aiQuiz$en {
	_Translations$aiQuiz$uz._(this._root);

	final TranslationsUz _root; // ignore: unused_field

	// Translations
	@override String get entryCardLabel => 'AI orqali hujjatdan quiz yaratish';
	@override String get myQuizzesTitle => 'Mening AI quizlarim';
	@override String get createButton => '+ Yangi AI quiz yaratish';
	@override String get emptyTitle => 'Hali AI quiz yaratmagansiz';
	@override String get emptySubtitle => 'Hujjat (PDF, Word yoki matn) yuklab, undan avtomatik quiz yarating';
	@override String get deleteConfirmTitle => 'Quizni o\'chirish';
	@override String deleteConfirmMessage({required Object name}) => '"${name}" o\'chirilsinmi? Bu amalni ortga qaytarib bo\'lmaydi.';
	@override String get generateTitle => 'AI orqali quiz yaratish';
	@override String get generateSubtitle => 'Hujjatdan yoki mavzudan AI orqali quiz yarating';
	@override String get modeDocumentLabel => 'Hujjat';
	@override String get modeTopicLabel => 'Mavzu';
	@override String get pickFileLabel => 'Hujjat tanlash (PDF, Word, matn)';
	@override String get pickFileFirst => 'Avval hujjat tanlang';
	@override String get instructionLabel => 'Ko\'rsatma (ixtiyoriy)';
	@override String get instructionHint => 'Masalan: 3-bobdan 10 ta savol, yoki hammasidan';
	@override String get topicLabel => 'Mavzu';
	@override String get topicHint => 'Masalan: 2-jahon tarixidan savollar so\'ra o\'rtacha qiyinchilikda, yoki uzbek kinolaridan savol so\'ra';
	@override String get topicRequired => 'Mavzuni yozing';
	@override String get questionCountLabel => 'Savollar soni';
	@override String get generateButton => 'Generatsiya qilish';
	@override String get generated => 'Tayyor! Quiz "Mening AI quizlarim"ga saqlandi';
}

/// The flat map containing all translations for locale <uz>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsUz {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'common.appName' => 'Zukkor',
			'common.appTagline' => 'Bilim musobaqasi',
			'common.ok' => 'OK',
			'common.cancel' => 'Bekor qilish',
			'common.retry' => 'Qayta urinish',
			'common.loading' => 'Yuklanmoqda...',
			'common.delete' => 'O\'chirish',
			'common.dayUnit' => ({required num count}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('uz'))(count, one: 'kun', other: 'kun', ), 
			'common.friendsCount' => ({required num count}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('uz'))(count, one: '${count} do\'stingiz bor', other: '${count} do\'stingiz bor', ), 
			'common.questionCount' => ({required num count}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('uz'))(count, one: '${count} savol', other: '${count} savol', ), 
			'home.greeting' => 'Xayrli tong',
			'home.duelHeroTitle' => 'Bugun kim kuchli?',
			'home.duelHeroSubtitle' => 'Do\'stingizga yoki tasodifiy raqibga chaqiruv tashlang',
			'home.startDuel' => 'Duel boshlash',
			'home.totalXpLabel' => 'Jami XP',
			'home.rankLabel' => 'O\'rin',
			'home.levelLabel' => 'Daraja',
			'home.createRoom' => 'Xona yaratish',
			'home.joinWithCode' => 'Kod bilan qo\'shilish',
			'home.categoriesTitle' => 'Kategoriyalar',
			'home.seeAll' => 'Barchasi',
			'home.challengeToDuel' => 'Duelga chaqirish',
			'categories.title' => 'Kategoriya tanlang',
			'leaderboard.greeting' => 'Reyting',
			'leaderboard.title' => 'Kim eng zo\'r?',
			'leaderboard.segmentWeekly' => 'Haftalik',
			'leaderboard.segmentAllTime' => 'Barcha vaqt',
			'leaderboard.segmentFriends' => 'Do\'stlar',
			'leaderboard.you' => 'Siz',
			'leaderboard.seeFullRanking' => 'To\'liq reytingni ko\'rish',
			'leaderboard.xpValue' => ({required Object xp}) => '${xp} XP',
			'leaderboard.anonymousPlayer' => 'O\'yinchi',
			'fullLeaderboard.title' => 'To\'liq reyting',
			'playerDetail.title' => 'Profil',
			'playerDetail.streakLabel' => 'Seriya',
			'playerDetail.addToFriends' => 'Do\'stlikka qo\'shish',
			'playerDetail.requestSent' => 'Yuborildi',
			'playerDetail.rankedLabel' => ({required Object rank, required Object xp}) => '#${rank} o\'rin · ${xp} XP',
			'playerDetail.alreadyFriends' => 'Siz do\'stsiz',
			'playerDetail.acceptRequest' => 'Qabul qilish',
			'playerDetail.declineRequest' => 'Rad etish',
			'friends.addFriend' => 'Do\'st qo\'shish',
			'friends.searchPlaceholder' => 'Do\'stlarni qidirish',
			'friends.allSection' => 'Barcha do\'stlar',
			'friends.noneFound' => 'Do\'stlar topilmadi',
			'addFriend.searchByUsername' => 'Foydalanuvchi nomi bo\'yicha qidirish',
			'addFriend.orViaInviteLink' => 'Yoki taklif havolasi orqali',
			'addFriend.yourInviteCode' => 'Sizning taklif kodingiz',
			'addFriend.shareLink' => 'Havolani ulashish',
			'addFriend.addButton' => 'Qo\'shish',
			'addFriend.requestedLabel' => 'So\'rov yuborildi',
			'addFriend.noUsersFound' => 'Foydalanuvchilar topilmadi',
			'friendRequests.title' => 'Do\'stlik so\'rovlari',
			'friendRequests.emptyState' => 'Hozircha so\'rovlar yo\'q',
			'duelPick.title' => '1v1 Duel',
			'duelPick.chooseYourFriend' => 'Do\'stingizni tanlang',
			'profile.editProfile' => 'Profilni tahrirlash',
			'profile.settings' => 'Sozlamalar',
			'profile.statTotalGames' => 'Jami o\'yinlar',
			'profile.statWinRate' => 'G\'alaba foizi',
			'profile.statLongestStreak' => 'Eng uzun seriya',
			'profile.gameHistory' => 'O\'yinlar tarixi',
			'profile.settingsAndHelp' => 'Sozlamalar va yordam',
			'profile.levelWithTitle' => ({required Object level, required Object title}) => '${level}-daraja · ${title}',
			'profile.xpProgressLabel' => ({required Object current, required Object target, required Object remaining}) => '${current} / ${target} XP · keyingi darajagacha ${remaining}',
			'settings.groupGeneral' => 'Umumiy',
			'settings.language' => 'Til',
			'settings.notifications' => 'Bildirishnomalar',
			'settings.theme' => 'Mavzu',
			'settings.themeLight' => 'Yorug\'',
			'settings.themeDark' => 'Qorong\'i',
			'settings.soundEffects' => 'Ovoz effektlari',
			'settings.groupAccount' => 'Hisob',
			'settings.privacy' => 'Maxfiylik',
			'settings.helpCenter' => 'Yordam markazi',
			'settings.termsOfUse' => 'Foydalanish shartlari',
			'settings.changePassword' => 'Parolni o\'zgartirish',
			'settings.logOut' => 'Chiqish',
			'settings.groupDangerZone' => 'Xavfli zona',
			'settings.deleteAccount' => 'Akkauntni o\'chirish',
			'changePassword.title' => 'Parolni o\'zgartirish',
			'changePassword.currentPasswordLabel' => 'Joriy parol',
			'changePassword.currentPasswordHint' => 'Joriy parolingizni kiriting',
			'changePassword.newPasswordLabel' => 'Yangi parol',
			'changePassword.newPasswordHint' => 'Kamida 8 ta belgi',
			'changePassword.confirmNewPasswordLabel' => 'Yangi parolni tasdiqlang',
			'changePassword.confirmNewPasswordHint' => 'Yangi parolni qayta kiriting',
			'changePassword.saveButton' => 'Saqlash',
			'changePassword.updated' => 'Parol muvaffaqiyatli o\'zgartirildi',
			'deleteAccount.confirmTitle' => 'Akkauntni o\'chirish',
			'deleteAccount.confirmMessage' => 'Bu amalni ortga qaytarib bo\'lmaydi. Barcha ma\'lumotlaringiz — do\'stlar, tarix, ball — butunlay o\'chiriladi. Davom etish uchun parolingizni kiriting.',
			'deleteAccount.confirmButton' => 'Ha, o\'chirish',
			'history.segmentAll' => 'Barchasi',
			'history.segmentSolo' => 'Yakka',
			'history.segmentDuel' => 'Duel',
			'history.segmentLobby' => 'Xona',
			'history.winBadge' => 'G\'alaba',
			'history.lossBadge' => 'Mag\'lubiyat',
			'history.drawBadge' => 'Durrang',
			'history.today' => 'Bugun',
			'history.yesterday' => 'Kecha',
			'history.daysAgo' => ({required Object days}) => '${days} kun oldin',
			'history.emptyState' => 'Bu turdagi o\'yinlar hali saqlanmaydi',
			'history.noGamesYet' => 'Hali o\'ynalgan o\'yinlar yo\'q',
			'history.lobbyPlayerCount' => ({required Object count}) => '${count} o\'yinchi',
			'quizSetup.title' => 'Nechta savol?',
			'quizSetup.subtitle' => 'Tezkor variantni tanlang yoki o\'zingiz belgilang',
			'quizSetup.customLabel' => 'O\'zi tanlash',
			'quizSetup.startButton' => 'Quizni boshlash',
			'quizIntro.startLabel' => 'Boshlash!',
			'quiz.questionProgress' => ({required Object current, required Object total}) => '${current}/${total}-savol',
			'ballReveal.title' => 'Sizning balingiz',
			'ballReveal.ballLabel' => 'ball',
			'result.label' => 'Natija',
			'result.summary' => ({required Object total, required Object correct}) => '${total} tadan ${correct} tasi to\'g\'ri',
			'result.totalBall' => ({required Object ball}) => '${ball} ball',
			'result.xpEarned' => ({required Object xp}) => '+${xp} XP',
			'result.playAgain' => 'Yana o\'ynash',
			'result.challengeAFriend' => 'Do\'stni chaqirish',
			'result.backToHome' => 'Bosh sahifaga',
			'result.breakdownTitle' => 'Savollar bo\'yicha natija',
			'joinCode.hint' => 'Do\'stingiz yuborgan 6 xonali xona kodini kiriting',
			'joinCode.joinButton' => 'Qo\'shilish',
			'joinCode.codeDigitLabel' => ({required Object position}) => '${position}-raqam',
			'joinCode.roomNotFound' => 'Bunday xona topilmadi',
			'joinCode.roomFull' => 'Xona to\'lgan',
			'joinCode.alreadyStarted' => 'Bu xonada o\'yin allaqachon boshlangan',
			'joinCode.timedOut' => 'Bog\'lanib bo\'lmadi — internetni tekshirib qayta urinib ko\'ring',
			'lobby.title' => 'Ko\'p o\'yinchili xona',
			'lobby.roomCode' => 'Xona kodi',
			'lobby.players' => 'O\'yinchilar',
			'lobby.hostRole' => 'Xost',
			'lobby.guestRole' => 'Mehmon',
			'lobby.startGame' => 'O\'yinni boshlash',
			'lobby.waitingForHost' => 'Xost o\'yinni boshlashini kutmoqda…',
			'lobby.playerCount' => ({required Object current, required Object max}) => '${current}/${max}',
			'lobby.closedMessage' => 'Xost xonani tark etdi, xona yopildi',
			'lobby.creatingRoom' => 'Xona yaratilmoqda…',
			'lobby.createFailed' => 'Xona yaratib bo\'lmadi — internetni tekshirib qayta urinib ko\'ring',
			'lobby.backToHome' => 'Bosh sahifaga',
			'lobbyGame.title' => 'Xona',
			'lobbyGame.waitingForQuestion' => 'Savol tayyorlanmoqda…',
			'lobbyGame.waitingForOthers' => 'Siz barcha savollarga javob berdingiz! Boshqalarni kutmoqdamiz…',
			'lobbyGame.startFailed' => 'O\'yin boshlanmadi — internetni tekshirib qayta urinib ko\'ring',
			'lobbyGame.backToHome' => 'Bosh sahifaga',
			'lobbyResult.title' => 'Xona natijalari',
			'lobbyResult.subtitle' => 'Xonadagi hammaning natijasi shunday',
			'lobbyResult.playAgain' => 'Yana o\'ynash',
			'duelWaiting.title' => 'Duel',
			'duelWaiting.waitingForAccept' => 'Taklif yuborildi, javobni kutmoqda…',
			'duelWaiting.declined' => 'Taklif rad etildi',
			'duelWaiting.expired' => 'Taklif muddati tugadi',
			'duelWaiting.failed' => 'Taklifni yuborib bo\'lmadi',
			'duelWaiting.timedOut' => 'Do\'stingizga ulanib bo\'lmadi — internetni tekshirib qayta urinib ko\'ring',
			'duelWaiting.backToHome' => 'Bosh sahifaga',
			'duelInvite.title' => 'Duelga taklif',
			'duelInvite.challengesYou' => 'sizni duelga chaqirmoqda',
			'duelInvite.accept' => 'Qabul qilish',
			'duelInvite.decline' => 'Rad etish',
			'duelGame.title' => 'Duel',
			'duelGame.waitingForQuestion' => 'Savol tayyorlanmoqda…',
			'duelGame.opponentProgress' => ({required Object index, required Object total}) => 'Raqib: ${index}/${total} savolda',
			'duelGame.waitingForOpponent' => 'Siz barcha savollarga javob berdingiz! Sherigingizni kutmoqdamiz…',
			'duelGame.startFailed' => 'O\'yin boshlanmadi — internetni tekshirib qayta urinib ko\'ring',
			'duelGame.backToHome' => 'Bosh sahifaga',
			'duelResult.won' => 'Siz g\'olib bo\'ldingiz!',
			'duelResult.lost' => 'Siz yutqazdingiz',
			'duelResult.draw' => 'Durrang!',
			'duelResult.yourScoreLabel' => 'Siz',
			'duelResult.opponentScoreLabel' => 'Raqib',
			'notifications.title' => 'Bildirishnomalar',
			'notifications.duelChallenge' => ({required Object name}) => '${name} sizni duelga chaqirdi',
			'notifications.duelChallengeGeneric' => 'Sizni duelga chaqirishdi',
			'notifications.streakReminder' => '5 kunlik seriyangizni yo\'qotmang — bugun o\'ynang!',
			'notifications.top50' => 'Siz haftalik Top 50ga kirdingiz',
			'notifications.friendRequest' => ({required Object name}) => '${name} sizga do\'stlik so\'rovi yubordi',
			'notifications.friendRequestGeneric' => 'Sizga do\'stlik so\'rovi keldi',
			'notifications.welcome' => 'Zukkorga xush kelibsiz! Birinchi viktorinangizni boshlang',
			'notifications.emptyState' => 'Hozircha bildirishnomalar yo\'q',
			'editProfile.save' => 'Saqlash',
			'editProfile.updated' => 'Profil yangilandi',
			'notificationSettings.title' => 'Bildirishnoma sozlamalari',
			'notificationSettings.duelInvites' => 'Duel takliflari',
			'notificationSettings.streakReminders' => 'Seriya eslatmalari',
			'notificationSettings.leaderboardUpdates' => 'Reyting yangilanishlari',
			'notificationSettings.friendRequests' => 'Do\'stlik so\'rovlari',
			'notificationSettings.productUpdates' => 'Yangilanishlar haqida',
			'privacyPolicy.title' => 'Maxfiylik siyosati',
			'privacyPolicy.collectionTitle' => 'Biz to\'playdigan ma\'lumotlar',
			'privacyPolicy.collectionBody' => 'O\'yinni ishga tushirish va rivojlanishingizni ko\'rsatish uchun ismingiz, foydalanuvchi nomingiz va viktorina faoliyatingizni — ballar, o\'ynalgan kategoriyalar va seriyalarni — to\'playmiz.',
			'privacyPolicy.useTitle' => 'Ulardan qanday foydalanamiz',
			'privacyPolicy.useBody' => 'Ma\'lumotlaringiz Zukkorni ishga tushirish uchun ishlatiladi: sizni dueller va xonalarda moslashtirish, XP va reytinglarni hisoblash, hamda statistikangizni sizga ko\'rsatish.',
			'privacyPolicy.sharingTitle' => 'Ulashish',
			'privacyPolicy.sharingBody' => 'Biz ma\'lumotlaringizni sotmaymiz. Ismingiz, avataringiz va ochiq statistikangiz oddiy o\'yin jarayonining bir qismi sifatida boshqa o\'yinchilarga ko\'rinadi — masalan, reyting, do\'stlar ro\'yxati va duellarda.',
			'privacyPolicy.contactTitle' => 'Aloqa',
			'privacyPolicy.contactBody' => 'Ma\'lumotlaringiz haqida savollaringiz bormi? Yordam markazi orqali murojaat qiling, biz siz bilan bog\'lanamiz.',
			'termsOfUse.title' => 'Foydalanish shartlari',
			'termsOfUse.accountTitle' => 'Hisobingiz',
			'termsOfUse.accountBody' => 'Hisobingiz xavfsizligini saqlash va u orqali sodir bo\'ladigan faoliyat uchun siz javobgarsiz.',
			'termsOfUse.conductTitle' => 'Halol o\'yin',
			'termsOfUse.conductBody' => 'Aldash, XP uchun xatolardan foydalanish yoki boshqa o\'yinchilarni bezovta qilish hisobingizning to\'xtatib qo\'yilishiga olib kelishi mumkin.',
			'termsOfUse.contentTitle' => 'Kontent',
			'termsOfUse.contentBody' => 'Viktorina savollari va ilova kontenti Zukkorga tegishli. Ularni ruxsatsiz nusxalash yoki tarqatish mumkin emas.',
			'termsOfUse.changesTitle' => 'O\'zgarishlar',
			'termsOfUse.changesBody' => 'Zukkor rivojlanishi bilan ushbu shartlarni yangilashimiz mumkin. Har qanday muhim o\'zgarish haqida sizga xabar beramiz.',
			'helpCenter.duelQuestion' => 'Duelni qanday boshlayman?',
			'helpCenter.duelAnswer' => 'Do\'stlar bo\'limiga o\'ting, onlayn do\'stni tanlang, so\'ng kategoriyani tanlang. Raqibingizga taklif yuboriladi.',
			'helpCenter.xpQuestion' => 'XP qanday hisoblanadi?',
			'helpCenter.xpAnswer' => 'Har bir to\'g\'ri javob uchun XP olasiz, shuningdek yakka viktorinani tugatgan yoki duelda g\'alaba qozongan uchun bonus beriladi.',
			'helpCenter.streakQuestion' => 'Bir kun o\'tkazib yuborsam nima bo\'ladi?',
			'helpCenter.streakAnswer' => 'Agar butun kun davomida kamida bitta viktorina o\'ynamasangiz, seriyangiz nolga tushadi.',
			'helpCenter.lobbyQuestion' => 'Xonaga nechta o\'yinchi qo\'shilishi mumkin?',
			'helpCenter.lobbyAnswer' => 'Hozircha xonalar 10 tagacha o\'yinchini qo\'llab-quvvatlaydi.',
			'helpCenter.reportQuestion' => 'Xato yoki noto\'g\'ri savol haqida qanday xabar beraman?',
			'helpCenter.reportAnswer' => 'Shu Yordam markazi orqali biz bilan bog\'laning. Biz kichik jamoamiz va har bir xabar Zukkorni yaxshilashga yordam beradi.',
			'bottomNav.home' => 'Bosh sahifa',
			'bottomNav.leaderboard' => 'Reyting',
			'bottomNav.friends' => 'Do\'stlar',
			'bottomNav.profile' => 'Profil',
			'bottomNav.comingSoon' => 'Tez orada',
			'onboarding.stepCount' => 'Bosqich',
			'onboarding.continueButton' => 'Davom etish',
			'onboarding.start' => 'Boshlash',
			'onboarding.avatarTitle' => 'O\'zingizga mos avatar tanlang',
			'onboarding.avatarSubtitle' => 'Uni istalgan vaqtda o\'zgartirishingiz mumkin',
			'onboarding.uploadPhoto' => 'Rasm yuklash',
			'onboarding.profileTitle' => 'Siz bilan tanishib olaylik',
			'onboarding.profileSubtitle' => 'Bu ma\'lumot profilingizda va do\'stlaringizga ko\'rinadi',
			'onboarding.firstNameLabel' => 'Ism',
			'onboarding.firstNameHint' => 'Aziz',
			'onboarding.lastNameLabel' => 'Familiya',
			'onboarding.lastNameHint' => 'Karimov',
			'onboarding.usernameLabel' => 'Foydalanuvchi nomi',
			'onboarding.usernameHint' => 'aziz_karimov',
			'onboarding.directionTitle' => 'Zukkordan nima uchun foydalanyapsiz?',
			'onboarding.directionSubtitle' => 'Sizga mos kontent va kategoriyalarni tavsiya qilamiz',
			'onboarding.directionRequired' => 'Davom etish uchun birini tanlang',
			'onboarding.studentUniTitle' => 'Talaba',
			'onboarding.studentUniSubtitle' => 'Universitet yoki kollejda o\'qiyman',
			'onboarding.studentSchoolTitle' => 'O\'quvchi',
			'onboarding.studentSchoolSubtitle' => 'Maktabda o\'qiyman',
			'onboarding.examPrepTitle' => 'Imtihonga tayyorgarlik',
			'onboarding.examPrepSubtitle' => 'Imtihonga tayyorlanyapman (masalan, IELTS)',
			'onboarding.casualTitle' => 'Shunchaki qiziqib',
			'onboarding.casualSubtitle' => 'O\'ynab, vaqt o\'tkazyapman',
			'introduction.skip' => 'O\'tkazib yuborish',
			'introduction.getStarted' => 'Boshlash',
			'introduction.welcomeTitle' => 'Zukkorga xush kelibsiz!',
			'introduction.welcomeSubtitle' => 'O\'rganish o\'yinga aylangan bilim musobaqasi ilovasi',
			'introduction.languageLabel' => 'Tilingizni tanlang',
			'introduction.soloTitle' => 'O\'zingizni sinang',
			'introduction.soloSubtitle' => 'Kategoriya tanlang va yakka savollarga javob bering — XP to\'plang va o\'z rekordingizni yenging',
			'introduction.duelTitle' => 'Do\'stlaringizga qarshi chiqing',
			'introduction.duelSubtitle' => 'Do\'st bilan yakkama-yakka duel qiling yoki xona yaratib, butun guruh bilan real vaqtda o\'ynang',
			'introduction.leaderboardTitle' => 'Reytingda ko\'tariling',
			'introduction.leaderboardSubtitle' => 'Har bir to\'g\'ri javob XP beradi — do\'stlaringiz va boshqalar orasidagi o\'rningizni kuzating',
			'introduction.interestsTitle' => 'Nimalarga qiziqasiz?',
			'introduction.interestsSubtitle' => 'Bir nechtasini tanlang — ulardan kategoriyalarni tavsiya qilishda foydalanamiz',
			'introduction.studyTitle' => 'Deyarli tayyor!',
			'introduction.studySubtitle' => 'Yana bir nechta qisqa savol',
			'introduction.studyPlaceLabel' => 'Qayerda o\'qiysiz?',
			'introduction.quizLikingLabel' => 'Viktorina va topishmoqlarni yechishni yoqtirasizmi?',
			'introduction.studyPlaceSchool' => 'Maktab',
			'introduction.studyPlaceUniversity' => 'Universitet',
			'introduction.studyPlaceExamPrep' => 'Imtihonga tayyorgarlik',
			'introduction.quizLikingLoveIt' => 'Juda yoqtiraman',
			'introduction.quizLikingItsOk' => 'Yomon emas',
			'introduction.quizLikingNotReally' => 'Unchalik emas',
			'introduction.otherOption' => 'Boshqa',
			'introduction.otherFieldLabel' => 'Batafsilroq ayting',
			'introduction.otherFieldHint' => 'Shu yerga yozing...',
			'auth.loginTitle' => 'Xush kelibsiz!',
			'auth.loginSubtitle' => 'Tizimga kiring va o\'yinni davom ettiring',
			'auth.registerTitle' => 'Hisob yaratish',
			'auth.registerSubtitle' => 'Bir daqiqada ro\'yxatdan o\'ting va boshlang',
			'auth.emailLabel' => 'Email',
			'auth.emailHint' => 'siz@misol.com',
			'auth.passwordLabel' => 'Parol',
			'auth.passwordHint' => 'Kamida 8 ta belgi',
			'auth.confirmPasswordLabel' => 'Parolni tasdiqlang',
			'auth.confirmPasswordHint' => 'Parolingizni qayta kiriting',
			'auth.loginButton' => 'Kirish',
			'auth.registerButton' => 'Ro\'yxatdan o\'tish',
			'auth.orDivider' => 'yoki',
			'auth.continueWithGoogle' => 'Google orqali davom etish',
			'auth.noAccountPrompt' => 'Hisobingiz yo\'qmi?',
			'auth.haveAccountPrompt' => 'Hisobingiz bormi?',
			'auth.switchToRegister' => 'Ro\'yxatdan o\'tish',
			'auth.switchToLogin' => 'Kirish',
			'authValidation.emailRequired' => 'Email kiritilishi shart',
			'authValidation.emailInvalid' => 'Email formati noto\'g\'ri',
			'authValidation.passwordRequired' => 'Parol kiritilishi shart',
			'authValidation.passwordTooShort' => 'Parol kamida 8 ta belgi, 1 ta katta harf va 1 ta raqamdan iborat bo\'lishi kerak',
			'authValidation.passwordMismatch' => 'Parollar mos kelmadi',
			'authValidation.usernameRequired' => 'Foydalanuvchi nomi kiritilishi shart',
			'authValidation.usernameInvalid' => 'Foydalanuvchi nomi faqat harflar, raqamlar va pastki chiziqdan iborat bo\'lishi mumkin (3–30 belgi)',
			'authValidation.usernameTaken' => 'Bu foydalanuvchi nomi band',
			'authValidation.nameRequired' => 'Bu maydon to\'ldirilishi shart',
			'authValidation.nameTooLong' => 'Juda uzun (maksimal 50 belgi)',
			'errors.noConnection' => 'Internet aloqasi yo\'q. Ulanishingizni tekshirib, qayta urinib ko\'ring.',
			'errors.timeout' => 'Server javob bermayapti. Birozdan so\'ng qayta urinib ko\'ring.',
			'errors.server' => 'Server xatoligi yuz berdi. Birozdan so\'ng qayta urinib ko\'ring.',
			'errors.unknown' => 'Kutilmagan xatolik yuz berdi.',
			'errors.invalidCredentials' => 'Email yoki parol noto\'g\'ri.',
			'errors.sessionExpired' => 'Sessiyangiz muddati tugadi. Qaytadan tizimga kiring.',
			'errors.googleCancelled' => 'Google orqali kirish bekor qilindi.',
			'aiQuiz.entryCardLabel' => 'AI orqali hujjatdan quiz yaratish',
			'aiQuiz.myQuizzesTitle' => 'Mening AI quizlarim',
			'aiQuiz.createButton' => '+ Yangi AI quiz yaratish',
			'aiQuiz.emptyTitle' => 'Hali AI quiz yaratmagansiz',
			'aiQuiz.emptySubtitle' => 'Hujjat (PDF, Word yoki matn) yuklab, undan avtomatik quiz yarating',
			'aiQuiz.deleteConfirmTitle' => 'Quizni o\'chirish',
			'aiQuiz.deleteConfirmMessage' => ({required Object name}) => '"${name}" o\'chirilsinmi? Bu amalni ortga qaytarib bo\'lmaydi.',
			'aiQuiz.generateTitle' => 'AI orqali quiz yaratish',
			'aiQuiz.generateSubtitle' => 'Hujjatdan yoki mavzudan AI orqali quiz yarating',
			'aiQuiz.modeDocumentLabel' => 'Hujjat',
			'aiQuiz.modeTopicLabel' => 'Mavzu',
			'aiQuiz.pickFileLabel' => 'Hujjat tanlash (PDF, Word, matn)',
			'aiQuiz.pickFileFirst' => 'Avval hujjat tanlang',
			'aiQuiz.instructionLabel' => 'Ko\'rsatma (ixtiyoriy)',
			'aiQuiz.instructionHint' => 'Masalan: 3-bobdan 10 ta savol, yoki hammasidan',
			'aiQuiz.topicLabel' => 'Mavzu',
			'aiQuiz.topicHint' => 'Masalan: 2-jahon tarixidan savollar so\'ra o\'rtacha qiyinchilikda, yoki uzbek kinolaridan savol so\'ra',
			'aiQuiz.topicRequired' => 'Mavzuni yozing',
			'aiQuiz.questionCountLabel' => 'Savollar soni',
			'aiQuiz.generateButton' => 'Generatsiya qilish',
			'aiQuiz.generated' => 'Tayyor! Quiz "Mening AI quizlarim"ga saqlandi',
			_ => null,
		};
	}
}
