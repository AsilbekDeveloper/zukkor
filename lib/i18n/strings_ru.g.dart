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
class TranslationsRu with BaseTranslations<AppLocale, Translations> implements Translations {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsRu({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.ru,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <ru>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key);

	late final TranslationsRu _root = this; // ignore: unused_field

	@override 
	TranslationsRu $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsRu(meta: meta ?? this.$meta);

	// Translations
	@override late final _Translations$common$ru common = _Translations$common$ru._(_root);
	@override late final _Translations$home$ru home = _Translations$home$ru._(_root);
	@override late final _Translations$categories$ru categories = _Translations$categories$ru._(_root);
	@override late final _Translations$leaderboard$ru leaderboard = _Translations$leaderboard$ru._(_root);
	@override late final _Translations$fullLeaderboard$ru fullLeaderboard = _Translations$fullLeaderboard$ru._(_root);
	@override late final _Translations$playerDetail$ru playerDetail = _Translations$playerDetail$ru._(_root);
	@override late final _Translations$friends$ru friends = _Translations$friends$ru._(_root);
	@override late final _Translations$addFriend$ru addFriend = _Translations$addFriend$ru._(_root);
	@override late final _Translations$friendRequests$ru friendRequests = _Translations$friendRequests$ru._(_root);
	@override late final _Translations$duelPick$ru duelPick = _Translations$duelPick$ru._(_root);
	@override late final _Translations$profile$ru profile = _Translations$profile$ru._(_root);
	@override late final _Translations$settings$ru settings = _Translations$settings$ru._(_root);
	@override late final _Translations$changePassword$ru changePassword = _Translations$changePassword$ru._(_root);
	@override late final _Translations$deleteAccount$ru deleteAccount = _Translations$deleteAccount$ru._(_root);
	@override late final _Translations$history$ru history = _Translations$history$ru._(_root);
	@override late final _Translations$quizSetup$ru quizSetup = _Translations$quizSetup$ru._(_root);
	@override late final _Translations$quizIntro$ru quizIntro = _Translations$quizIntro$ru._(_root);
	@override late final _Translations$quiz$ru quiz = _Translations$quiz$ru._(_root);
	@override late final _Translations$ballReveal$ru ballReveal = _Translations$ballReveal$ru._(_root);
	@override late final _Translations$result$ru result = _Translations$result$ru._(_root);
	@override late final _Translations$joinCode$ru joinCode = _Translations$joinCode$ru._(_root);
	@override late final _Translations$lobby$ru lobby = _Translations$lobby$ru._(_root);
	@override late final _Translations$lobbyGame$ru lobbyGame = _Translations$lobbyGame$ru._(_root);
	@override late final _Translations$lobbyResult$ru lobbyResult = _Translations$lobbyResult$ru._(_root);
	@override late final _Translations$duelWaiting$ru duelWaiting = _Translations$duelWaiting$ru._(_root);
	@override late final _Translations$duelInvite$ru duelInvite = _Translations$duelInvite$ru._(_root);
	@override late final _Translations$duelGame$ru duelGame = _Translations$duelGame$ru._(_root);
	@override late final _Translations$duelResult$ru duelResult = _Translations$duelResult$ru._(_root);
	@override late final _Translations$notifications$ru notifications = _Translations$notifications$ru._(_root);
	@override late final _Translations$editProfile$ru editProfile = _Translations$editProfile$ru._(_root);
	@override late final _Translations$notificationSettings$ru notificationSettings = _Translations$notificationSettings$ru._(_root);
	@override late final _Translations$privacyPolicy$ru privacyPolicy = _Translations$privacyPolicy$ru._(_root);
	@override late final _Translations$termsOfUse$ru termsOfUse = _Translations$termsOfUse$ru._(_root);
	@override late final _Translations$helpCenter$ru helpCenter = _Translations$helpCenter$ru._(_root);
	@override late final _Translations$bottomNav$ru bottomNav = _Translations$bottomNav$ru._(_root);
	@override late final _Translations$onboarding$ru onboarding = _Translations$onboarding$ru._(_root);
	@override late final _Translations$introduction$ru introduction = _Translations$introduction$ru._(_root);
	@override late final _Translations$auth$ru auth = _Translations$auth$ru._(_root);
	@override late final _Translations$authValidation$ru authValidation = _Translations$authValidation$ru._(_root);
	@override late final _Translations$errors$ru errors = _Translations$errors$ru._(_root);
	@override late final _Translations$aiQuiz$ru aiQuiz = _Translations$aiQuiz$ru._(_root);
}

// Path: common
class _Translations$common$ru implements Translations$common$en {
	_Translations$common$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get appName => 'Zukkor';
	@override String get appTagline => 'Соревнование знаний';
	@override String get ok => 'ОК';
	@override String get cancel => 'Отмена';
	@override String get retry => 'Повторить';
	@override String get loading => 'Загрузка...';
	@override String get delete => 'Удалить';
	@override String dayUnit({required num count}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('ru'))(count,
		one: 'день',
		few: 'дня',
		many: 'дней',
		other: 'дня',
	);
	@override String friendsCount({required num count}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('ru'))(count,
		one: '${count} друг',
		few: '${count} друга',
		many: '${count} друзей',
		other: '${count} друга',
	);
	@override String questionCount({required num count}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('ru'))(count,
		one: '${count} вопрос',
		few: '${count} вопроса',
		many: '${count} вопросов',
		other: '${count} вопроса',
	);
}

// Path: home
class _Translations$home$ru implements Translations$home$en {
	_Translations$home$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get greeting => 'Доброе утро';
	@override String get duelHeroTitle => 'Кто сильнее сегодня?';
	@override String get duelHeroSubtitle => 'Бросьте вызов другу или случайному сопернику';
	@override String get startDuel => 'Начать дуэль';
	@override String get totalXpLabel => 'Всего XP';
	@override String get rankLabel => 'Ранг';
	@override String get levelLabel => 'Уровень';
	@override String get createRoom => 'Создать комнату';
	@override String get joinWithCode => 'Присоединиться по коду';
	@override String get categoriesTitle => 'Категории';
	@override String get seeAll => 'Все';
	@override String get challengeToDuel => 'Вызвать на дуэль';
}

// Path: categories
class _Translations$categories$ru implements Translations$categories$en {
	_Translations$categories$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Выберите категорию';
}

// Path: leaderboard
class _Translations$leaderboard$ru implements Translations$leaderboard$en {
	_Translations$leaderboard$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get greeting => 'Рейтинг';
	@override String get title => 'Кто лучший?';
	@override String get segmentWeekly => 'За неделю';
	@override String get segmentAllTime => 'За всё время';
	@override String get segmentFriends => 'Друзья';
	@override String get you => 'Вы';
	@override String get seeFullRanking => 'Смотреть полный рейтинг';
	@override String xpValue({required Object xp}) => '${xp} XP';
	@override String get anonymousPlayer => 'Игрок';
}

// Path: fullLeaderboard
class _Translations$fullLeaderboard$ru implements Translations$fullLeaderboard$en {
	_Translations$fullLeaderboard$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Полный рейтинг';
}

// Path: playerDetail
class _Translations$playerDetail$ru implements Translations$playerDetail$en {
	_Translations$playerDetail$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Профиль';
	@override String get streakLabel => 'Серия';
	@override String get addToFriends => 'Добавить в друзья';
	@override String get requestSent => 'Отправлено';
	@override String rankedLabel({required Object rank, required Object xp}) => '#${rank} место · ${xp} XP';
	@override String get alreadyFriends => 'Вы друзья';
	@override String get acceptRequest => 'Принять';
	@override String get declineRequest => 'Отклонить';
	@override String get aiQuizzesTitle => 'Викторины';
}

// Path: friends
class _Translations$friends$ru implements Translations$friends$en {
	_Translations$friends$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get addFriend => 'Добавить друга';
	@override String get searchPlaceholder => 'Поиск друзей';
	@override String get allSection => 'Все друзья';
	@override String get noneFound => 'Друзья не найдены';
}

// Path: addFriend
class _Translations$addFriend$ru implements Translations$addFriend$en {
	_Translations$addFriend$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get searchByUsername => 'Поиск по имени пользователя';
	@override String get orViaInviteLink => 'Или по пригласительной ссылке';
	@override String get yourInviteCode => 'Ваш код приглашения';
	@override String get shareLink => 'Поделиться ссылкой';
	@override String get addButton => 'Добавить';
	@override String get requestedLabel => 'Запрос отправлен';
	@override String get noUsersFound => 'Пользователи не найдены';
}

// Path: friendRequests
class _Translations$friendRequests$ru implements Translations$friendRequests$en {
	_Translations$friendRequests$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Запросы в друзья';
	@override String get emptyState => 'Пока нет запросов';
}

// Path: duelPick
class _Translations$duelPick$ru implements Translations$duelPick$en {
	_Translations$duelPick$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Дуэль 1×1';
	@override String get chooseYourFriend => 'Выберите друга';
}

// Path: profile
class _Translations$profile$ru implements Translations$profile$en {
	_Translations$profile$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get editProfile => 'Редактировать профиль';
	@override String get settings => 'Настройки';
	@override String get statTotalGames => 'Всего игр';
	@override String get statWinRate => 'Процент побед';
	@override String get statLongestStreak => 'Самая длинная серия';
	@override String get gameHistory => 'История игр';
	@override String get settingsAndHelp => 'Настройки и помощь';
	@override String levelWithTitle({required Object level, required Object title}) => 'Уровень ${level} · ${title}';
	@override String xpProgressLabel({required Object current, required Object target, required Object remaining}) => '${current} / ${target} XP · до следующего уровня ${remaining}';
}

// Path: settings
class _Translations$settings$ru implements Translations$settings$en {
	_Translations$settings$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get groupGeneral => 'Общее';
	@override String get language => 'Язык';
	@override String get notifications => 'Уведомления';
	@override String get theme => 'Тема';
	@override String get themeLight => 'Светлая';
	@override String get themeDark => 'Тёмная';
	@override String get soundEffects => 'Звуковые эффекты';
	@override String get groupAccount => 'Аккаунт';
	@override String get privacy => 'Конфиденциальность';
	@override String get helpCenter => 'Центр помощи';
	@override String get termsOfUse => 'Условия использования';
	@override String get changePassword => 'Изменить пароль';
	@override String get logOut => 'Выйти';
	@override String get groupDangerZone => 'Опасная зона';
	@override String get deleteAccount => 'Удалить аккаунт';
}

// Path: changePassword
class _Translations$changePassword$ru implements Translations$changePassword$en {
	_Translations$changePassword$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Изменить пароль';
	@override String get currentPasswordLabel => 'Текущий пароль';
	@override String get currentPasswordHint => 'Введите текущий пароль';
	@override String get newPasswordLabel => 'Новый пароль';
	@override String get newPasswordHint => 'Минимум 8 символов';
	@override String get confirmNewPasswordLabel => 'Подтвердите новый пароль';
	@override String get confirmNewPasswordHint => 'Введите новый пароль ещё раз';
	@override String get saveButton => 'Сохранить';
	@override String get updated => 'Пароль успешно изменён';
}

// Path: deleteAccount
class _Translations$deleteAccount$ru implements Translations$deleteAccount$en {
	_Translations$deleteAccount$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get confirmTitle => 'Удалить аккаунт';
	@override String get confirmMessage => 'Это действие нельзя отменить. Все ваши данные — друзья, история, баллы — будут безвозвратно удалены. Введите пароль, чтобы продолжить.';
	@override String get confirmButton => 'Да, удалить';
}

// Path: history
class _Translations$history$ru implements Translations$history$en {
	_Translations$history$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get segmentAll => 'Все';
	@override String get segmentSolo => 'Соло';
	@override String get segmentDuel => 'Дуэль';
	@override String get segmentLobby => 'Комната';
	@override String get winBadge => 'Победа';
	@override String get lossBadge => 'Поражение';
	@override String get drawBadge => 'Ничья';
	@override String get today => 'Сегодня';
	@override String get yesterday => 'Вчера';
	@override String daysAgo({required Object days}) => '${days} дней назад';
	@override String get emptyState => 'Игры этого типа пока не сохраняются';
	@override String get noGamesYet => 'Пока нет сыгранных игр';
	@override String lobbyPlayerCount({required Object count}) => '${count} игроков';
}

// Path: quizSetup
class _Translations$quizSetup$ru implements Translations$quizSetup$en {
	_Translations$quizSetup$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Сколько вопросов?';
	@override String get subtitle => 'Выберите готовый вариант или укажите своё число';
	@override String get customLabel => 'Свой вариант';
	@override String get startButton => 'Начать викторину';
}

// Path: quizIntro
class _Translations$quizIntro$ru implements Translations$quizIntro$en {
	_Translations$quizIntro$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get startLabel => 'Старт!';
}

// Path: quiz
class _Translations$quiz$ru implements Translations$quiz$en {
	_Translations$quiz$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String questionProgress({required Object current, required Object total}) => 'Вопрос ${current} из ${total}';
}

// Path: ballReveal
class _Translations$ballReveal$ru implements Translations$ballReveal$en {
	_Translations$ballReveal$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Ваши баллы';
	@override String get ballLabel => 'баллов';
}

// Path: result
class _Translations$result$ru implements Translations$result$en {
	_Translations$result$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get label => 'Результат';
	@override String summary({required Object correct, required Object total}) => '${correct} из ${total} правильно';
	@override String totalBall({required Object ball}) => '${ball} баллов';
	@override String xpEarned({required Object xp}) => '+${xp} XP';
	@override String get playAgain => 'Играть снова';
	@override String get challengeAFriend => 'Вызвать друга';
	@override String get backToHome => 'На главную';
	@override String get breakdownTitle => 'Результаты по вопросам';
}

// Path: joinCode
class _Translations$joinCode$ru implements Translations$joinCode$en {
	_Translations$joinCode$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get hint => 'Введите 6-значный код комнаты, который прислал друг';
	@override String get joinButton => 'Присоединиться';
	@override String codeDigitLabel({required Object position}) => 'Цифра кода ${position}';
	@override String get roomNotFound => 'Комната с таким кодом не найдена';
	@override String get roomFull => 'Эта комната заполнена';
	@override String get alreadyStarted => 'Игра в этой комнате уже началась';
	@override String get timedOut => 'Не удалось подключиться — проверьте соединение и попробуйте снова';
}

// Path: lobby
class _Translations$lobby$ru implements Translations$lobby$en {
	_Translations$lobby$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Комната для нескольких игроков';
	@override String get roomCode => 'Код комнаты';
	@override String get players => 'Игроки';
	@override String get hostRole => 'Хост';
	@override String get guestRole => 'Гость';
	@override String get startGame => 'Начать игру';
	@override String get waitingForHost => 'Ожидание, пока хост начнёт игру…';
	@override String playerCount({required Object current, required Object max}) => '${current}/${max}';
	@override String get closedMessage => 'Хост покинул комнату, комната закрыта';
	@override String get creatingRoom => 'Создание комнаты…';
	@override String get createFailed => 'Не удалось создать комнату — проверьте соединение и попробуйте снова';
	@override String get backToHome => 'На главную';
}

// Path: lobbyGame
class _Translations$lobbyGame$ru implements Translations$lobbyGame$en {
	_Translations$lobbyGame$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Комната';
	@override String get waitingForQuestion => 'Подготовка вопроса…';
	@override String get waitingForOthers => 'Вы ответили на все вопросы! Ждём остальных…';
	@override String get startFailed => 'Игра не началась — проверьте соединение и попробуйте снова';
	@override String get backToHome => 'На главную';
}

// Path: lobbyResult
class _Translations$lobbyResult$ru implements Translations$lobbyResult$en {
	_Translations$lobbyResult$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Результаты комнаты';
	@override String get subtitle => 'Вот как сыграли все в комнате';
	@override String get playAgain => 'Играть снова';
}

// Path: duelWaiting
class _Translations$duelWaiting$ru implements Translations$duelWaiting$en {
	_Translations$duelWaiting$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Дуэль';
	@override String get waitingForAccept => 'Приглашение отправлено, ожидание ответа…';
	@override String get declined => 'Приглашение отклонено';
	@override String get expired => 'Срок приглашения истёк';
	@override String get failed => 'Не удалось отправить приглашение';
	@override String get timedOut => 'Не удалось связаться с другом — проверьте соединение и попробуйте снова';
	@override String get backToHome => 'На главную';
}

// Path: duelInvite
class _Translations$duelInvite$ru implements Translations$duelInvite$en {
	_Translations$duelInvite$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Приглашение на дуэль';
	@override String get challengesYou => 'вызывает вас на дуэль';
	@override String get accept => 'Принять';
	@override String get decline => 'Отклонить';
}

// Path: duelGame
class _Translations$duelGame$ru implements Translations$duelGame$en {
	_Translations$duelGame$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Дуэль';
	@override String get waitingForQuestion => 'Подготовка вопроса…';
	@override String opponentProgress({required Object index, required Object total}) => 'Соперник: вопрос ${index}/${total}';
	@override String get waitingForOpponent => 'Вы ответили на все вопросы! Ждём соперника…';
	@override String get startFailed => 'Игра не началась — проверьте соединение и попробуйте снова';
	@override String get backToHome => 'На главную';
}

// Path: duelResult
class _Translations$duelResult$ru implements Translations$duelResult$en {
	_Translations$duelResult$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get won => 'Вы победили!';
	@override String get lost => 'Вы проиграли';
	@override String get draw => 'Ничья!';
	@override String get yourScoreLabel => 'Вы';
	@override String get opponentScoreLabel => 'Соперник';
}

// Path: notifications
class _Translations$notifications$ru implements Translations$notifications$en {
	_Translations$notifications$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Уведомления';
	@override String duelChallenge({required Object name}) => '${name} вызвал(а) вас на дуэль';
	@override String get duelChallengeGeneric => 'Вас вызвали на дуэль';
	@override String get streakReminder => 'Не теряйте серию из 5 дней — играйте сегодня!';
	@override String get top50 => 'Вы попали в топ-50 недели';
	@override String friendRequest({required Object name}) => '${name} отправил(а) вам запрос в друзья';
	@override String get friendRequestGeneric => 'Вам пришёл новый запрос в друзья';
	@override String get welcome => 'Добро пожаловать в Zukkor! Начните свою первую викторину';
	@override String get emptyState => 'Пока нет уведомлений';
}

// Path: editProfile
class _Translations$editProfile$ru implements Translations$editProfile$en {
	_Translations$editProfile$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get save => 'Сохранить';
	@override String get updated => 'Профиль обновлён';
}

// Path: notificationSettings
class _Translations$notificationSettings$ru implements Translations$notificationSettings$en {
	_Translations$notificationSettings$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Настройки уведомлений';
	@override String get duelInvites => 'Приглашения на дуэль';
	@override String get streakReminders => 'Напоминания о серии';
	@override String get leaderboardUpdates => 'Обновления рейтинга';
	@override String get friendRequests => 'Запросы в друзья';
	@override String get productUpdates => 'Новости о продукте';
}

// Path: privacyPolicy
class _Translations$privacyPolicy$ru implements Translations$privacyPolicy$en {
	_Translations$privacyPolicy$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Политика конфиденциальности';
	@override String get collectionTitle => 'Какие данные мы собираем';
	@override String get collectionBody => 'Мы собираем ваше имя, имя пользователя и активность в викторинах — очки, сыгранные категории и серии — чтобы обеспечивать работу игры и показывать ваш прогресс.';
	@override String get useTitle => 'Как мы их используем';
	@override String get useBody => 'Ваши данные используются для работы Zukkor: подбора соперников в дуэлях и комнатах, расчёта XP и рейтингов, а также отображения вашей статистики.';
	@override String get sharingTitle => 'Передача данных';
	@override String get sharingBody => 'Мы не продаём ваши данные. Ваше имя, аватар и публичная статистика видны другим игрокам как часть обычного игрового процесса — например, в рейтинге, списке друзей и дуэлях.';
	@override String get contactTitle => 'Контакты';
	@override String get contactBody => 'Есть вопросы о своих данных? Обратитесь через Центр помощи, и мы свяжемся с вами.';
}

// Path: termsOfUse
class _Translations$termsOfUse$ru implements Translations$termsOfUse$en {
	_Translations$termsOfUse$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Условия использования';
	@override String get accountTitle => 'Ваш аккаунт';
	@override String get accountBody => 'Вы несёте ответственность за безопасность своего аккаунта и за действия, совершённые под ним.';
	@override String get conductTitle => 'Честная игра';
	@override String get conductBody => 'Обман, использование багов ради XP или преследование других игроков может привести к блокировке.';
	@override String get contentTitle => 'Контент';
	@override String get contentBody => 'Вопросы викторины и контент приложения принадлежат Zukkor. Их нельзя копировать или распространять без разрешения.';
	@override String get changesTitle => 'Изменения';
	@override String get changesBody => 'Мы можем обновлять эти условия по мере развития Zukkor. О любых важных изменениях мы вас уведомим.';
}

// Path: helpCenter
class _Translations$helpCenter$ru implements Translations$helpCenter$en {
	_Translations$helpCenter$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get duelQuestion => 'Как начать дуэль?';
	@override String get duelAnswer => 'Перейдите в раздел «Друзья», выберите друга онлайн, затем категорию. Сопернику придёт приглашение.';
	@override String get xpQuestion => 'Как начисляется XP?';
	@override String get xpAnswer => 'Вы получаете XP за каждый правильный ответ, а также бонус за завершение соло-викторины или победу в дуэли.';
	@override String get streakQuestion => 'Что будет, если я пропущу день?';
	@override String get streakAnswer => 'Ваша серия обнуляется, если вы пропустите целый день без хотя бы одной сыгранной викторины.';
	@override String get lobbyQuestion => 'Сколько игроков может присоединиться к комнате?';
	@override String get lobbyAnswer => 'Сейчас комнаты поддерживают до 10 игроков.';
	@override String get reportQuestion => 'Как сообщить об ошибке или некорректном вопросе?';
	@override String get reportAnswer => 'Свяжитесь с нами через этот Центр помощи. Мы небольшая команда, и каждое сообщение помогает нам улучшать Zukkor.';
}

// Path: bottomNav
class _Translations$bottomNav$ru implements Translations$bottomNav$en {
	_Translations$bottomNav$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get home => 'Главная';
	@override String get leaderboard => 'Рейтинг';
	@override String get friends => 'Друзья';
	@override String get profile => 'Профиль';
	@override String get comingSoon => 'Скоро';
}

// Path: onboarding
class _Translations$onboarding$ru implements Translations$onboarding$en {
	_Translations$onboarding$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get stepCount => 'Шаг';
	@override String get continueButton => 'Продолжить';
	@override String get start => 'Начать';
	@override String get avatarTitle => 'Выберите подходящий аватар';
	@override String get avatarSubtitle => 'Вы всегда сможете изменить его позже';
	@override String get uploadPhoto => 'Загрузить фото';
	@override String get profileTitle => 'Давайте познакомимся';
	@override String get profileSubtitle => 'Эта информация будет видна в вашем профиле и вашим друзьям';
	@override String get firstNameLabel => 'Имя';
	@override String get firstNameHint => 'Азиз';
	@override String get lastNameLabel => 'Фамилия';
	@override String get lastNameHint => 'Каримов';
	@override String get usernameLabel => 'Имя пользователя';
	@override String get usernameHint => 'aziz_karimov';
	@override String get directionTitle => 'Зачем вы используете Zukkor?';
	@override String get directionSubtitle => 'Мы порекомендуем подходящий контент и категории';
	@override String get directionRequired => 'Выберите один вариант, чтобы продолжить';
	@override String get studentUniTitle => 'Студент';
	@override String get studentUniSubtitle => 'Учусь в университете или колледже';
	@override String get studentSchoolTitle => 'Школьник';
	@override String get studentSchoolSubtitle => 'Учусь в школе';
	@override String get examPrepTitle => 'Подготовка к экзамену';
	@override String get examPrepSubtitle => 'Готовлюсь к экзамену (например, IELTS)';
	@override String get casualTitle => 'Просто для удовольствия';
	@override String get casualSubtitle => 'Играю, провожу время';
}

// Path: introduction
class _Translations$introduction$ru implements Translations$introduction$en {
	_Translations$introduction$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get skip => 'Пропустить';
	@override String get getStarted => 'Начать';
	@override String get welcomeTitle => 'Добро пожаловать в Zukkor!';
	@override String get welcomeSubtitle => 'Приложение-соревнование знаний, где обучение похоже на игру';
	@override String get languageLabel => 'Выберите язык';
	@override String get soloTitle => 'Проверьте себя';
	@override String get soloSubtitle => 'Выберите категорию и отвечайте на вопросы соло — зарабатывайте XP и побеждайте свой лучший результат';
	@override String get duelTitle => 'Бросьте вызов друзьям';
	@override String get duelSubtitle => 'Сразитесь с другом один на один или создайте комнату и играйте с целой группой в реальном времени';
	@override String get leaderboardTitle => 'Поднимайтесь в рейтинге';
	@override String get leaderboardSubtitle => 'Каждый правильный ответ приносит XP — следите за своим местом среди друзей и всех остальных';
	@override String get interestsTitle => 'Что вам интересно?';
	@override String get interestsSubtitle => 'Выберите несколько вариантов — мы используем их для рекомендации категорий';
	@override String get studyTitle => 'Почти готово!';
	@override String get studySubtitle => 'Ещё пара быстрых вопросов';
	@override String get studyPlaceLabel => 'Где вы учитесь?';
	@override String get quizLikingLabel => 'Вам нравится решать викторины и головоломки?';
	@override String get studyPlaceSchool => 'Школа';
	@override String get studyPlaceUniversity => 'Университет';
	@override String get studyPlaceExamPrep => 'Подготовка к экзамену';
	@override String get quizLikingLoveIt => 'Очень нравится';
	@override String get quizLikingItsOk => 'Нормально';
	@override String get quizLikingNotReally => 'Не особо';
	@override String get otherOption => 'Другое';
	@override String get otherFieldLabel => 'Расскажите подробнее';
	@override String get otherFieldHint => 'Введите здесь...';
}

// Path: auth
class _Translations$auth$ru implements Translations$auth$en {
	_Translations$auth$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get loginTitle => 'С возвращением!';
	@override String get loginSubtitle => 'Войдите и продолжите игру';
	@override String get registerTitle => 'Создать аккаунт';
	@override String get registerSubtitle => 'Зарегистрируйтесь за минуту и начните';
	@override String get emailLabel => 'Email';
	@override String get emailHint => 'you@example.com';
	@override String get passwordLabel => 'Пароль';
	@override String get passwordHint => 'Минимум 8 символов';
	@override String get confirmPasswordLabel => 'Подтвердите пароль';
	@override String get confirmPasswordHint => 'Введите пароль ещё раз';
	@override String get loginButton => 'Войти';
	@override String get registerButton => 'Зарегистрироваться';
	@override String get orDivider => 'или';
	@override String get continueWithGoogle => 'Продолжить через Google';
	@override String get noAccountPrompt => 'Нет аккаунта?';
	@override String get haveAccountPrompt => 'Уже есть аккаунт?';
	@override String get switchToRegister => 'Зарегистрироваться';
	@override String get switchToLogin => 'Войти';
}

// Path: authValidation
class _Translations$authValidation$ru implements Translations$authValidation$en {
	_Translations$authValidation$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get emailRequired => 'Введите email';
	@override String get emailInvalid => 'Неверный формат email';
	@override String get passwordRequired => 'Введите пароль';
	@override String get passwordTooShort => 'Пароль должен содержать минимум 8 символов, 1 заглавную букву и 1 цифру';
	@override String get passwordMismatch => 'Пароли не совпадают';
	@override String get usernameRequired => 'Введите имя пользователя';
	@override String get usernameInvalid => 'Имя пользователя может содержать только буквы, цифры и нижнее подчёркивание (3–30 символов)';
	@override String get usernameTaken => 'Это имя пользователя уже занято';
	@override String get nameRequired => 'Это поле обязательно';
	@override String get nameTooLong => 'Слишком длинно (максимум 50 символов)';
}

// Path: errors
class _Translations$errors$ru implements Translations$errors$en {
	_Translations$errors$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get noConnection => 'Нет подключения к интернету. Проверьте соединение и попробуйте снова.';
	@override String get timeout => 'Сервер не отвечает. Попробуйте ещё раз чуть позже.';
	@override String get server => 'Произошла ошибка сервера. Попробуйте ещё раз чуть позже.';
	@override String get unknown => 'Произошла непредвиденная ошибка.';
	@override String get invalidCredentials => 'Неверный email или пароль.';
	@override String get sessionExpired => 'Сессия истекла. Пожалуйста, войдите снова.';
	@override String get googleCancelled => 'Вход через Google отменён.';
}

// Path: aiQuiz
class _Translations$aiQuiz$ru implements Translations$aiQuiz$en {
	_Translations$aiQuiz$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get entryCardLabel => 'Создать викторину из документа с помощью AI';
	@override String get myQuizzesTitle => 'Мои AI-викторины';
	@override String get createButton => '+ Создать новую AI-викторину';
	@override String get emptyTitle => 'У вас пока нет AI-викторин';
	@override String get emptySubtitle => 'Загрузите документ (PDF, Word или текст), и мы создадим викторину на его основе';
	@override String get deleteConfirmTitle => 'Удалить викторину';
	@override String deleteConfirmMessage({required Object name}) => 'Удалить «${name}»? Это действие необратимо.';
	@override String get generateTitle => 'Создать викторину с AI';
	@override String get generateSubtitle => 'Создайте викторину с помощью AI из документа или темы';
	@override String get modeDocumentLabel => 'Документ';
	@override String get modeTopicLabel => 'Тема';
	@override String get pickFileLabel => 'Выбрать документ (PDF, Word, текст)';
	@override String get pickFileFirst => 'Сначала выберите документ';
	@override String get instructionLabel => 'Инструкция (необязательно)';
	@override String get instructionHint => 'Например: 10 вопросов по 3 главе, или по всему документу';
	@override String get topicLabel => 'Тема квиза';
	@override String get topicHint => 'Например: история Второй мировой войны, или узбекские фильмы';
	@override String get topicRequired => 'Введите тему';
	@override String get questionCountLabel => 'Количество вопросов';
	@override String get generateButton => 'Сгенерировать';
	@override String get generated => 'Готово! Сохранено в «Мои AI-викторины»';
	@override String get generatingTitle => 'AI генерирует вопросы...';
	@override String get generatingSubtitle => 'Это может занять некоторое время, пожалуйста подождите';
	@override String get sourceAi => 'AI';
	@override String get sourceManual => 'Вручную';
	@override String get visibilityPrivate => 'Никто';
	@override String get visibilityFriends => 'Друзья';
	@override String get visibilityPublic => 'Все';
	@override String get visibilityDialogTitle => 'Кто может видеть?';
	@override String get visibilityUpdated => 'Видимость изменена';
	@override String get createChooseTitle => 'Как хотите создать?';
	@override String get createViaAi => 'С помощью AI';
	@override String get createManually => 'Вручную';
	@override String get createManualTitle => 'Создать викторину вручную';
	@override String get manualNameLabel => 'Название викторины';
	@override String get manualNameHint => 'Например: Мой тест по географии';
	@override String get manualNameRequired => 'Введите название';
	@override String manualQuestionLabel({required Object number}) => 'Вопрос ${number}';
	@override String get manualQuestionTextLabel => 'Текст вопроса';
	@override String manualOptionLabel({required Object number}) => 'Вариант ${number}';
	@override String get manualFillAllFields => 'Заполните все поля';
	@override String get manualAddQuestion => '+ Добавить вопрос';
	@override String get manualSubmit => 'Создать';
	@override String get opponentQuizzesEntryLabel => 'Викторины соперника';
	@override String get noSharedQuizzes => 'Этот пользователь пока не поделился викторинами';
}

/// The flat map containing all translations for locale <ru>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsRu {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'common.appName' => 'Zukkor',
			'common.appTagline' => 'Соревнование знаний',
			'common.ok' => 'ОК',
			'common.cancel' => 'Отмена',
			'common.retry' => 'Повторить',
			'common.loading' => 'Загрузка...',
			'common.delete' => 'Удалить',
			'common.dayUnit' => ({required num count}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('ru'))(count, one: 'день', few: 'дня', many: 'дней', other: 'дня', ), 
			'common.friendsCount' => ({required num count}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('ru'))(count, one: '${count} друг', few: '${count} друга', many: '${count} друзей', other: '${count} друга', ), 
			'common.questionCount' => ({required num count}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('ru'))(count, one: '${count} вопрос', few: '${count} вопроса', many: '${count} вопросов', other: '${count} вопроса', ), 
			'home.greeting' => 'Доброе утро',
			'home.duelHeroTitle' => 'Кто сильнее сегодня?',
			'home.duelHeroSubtitle' => 'Бросьте вызов другу или случайному сопернику',
			'home.startDuel' => 'Начать дуэль',
			'home.totalXpLabel' => 'Всего XP',
			'home.rankLabel' => 'Ранг',
			'home.levelLabel' => 'Уровень',
			'home.createRoom' => 'Создать комнату',
			'home.joinWithCode' => 'Присоединиться по коду',
			'home.categoriesTitle' => 'Категории',
			'home.seeAll' => 'Все',
			'home.challengeToDuel' => 'Вызвать на дуэль',
			'categories.title' => 'Выберите категорию',
			'leaderboard.greeting' => 'Рейтинг',
			'leaderboard.title' => 'Кто лучший?',
			'leaderboard.segmentWeekly' => 'За неделю',
			'leaderboard.segmentAllTime' => 'За всё время',
			'leaderboard.segmentFriends' => 'Друзья',
			'leaderboard.you' => 'Вы',
			'leaderboard.seeFullRanking' => 'Смотреть полный рейтинг',
			'leaderboard.xpValue' => ({required Object xp}) => '${xp} XP',
			'leaderboard.anonymousPlayer' => 'Игрок',
			'fullLeaderboard.title' => 'Полный рейтинг',
			'playerDetail.title' => 'Профиль',
			'playerDetail.streakLabel' => 'Серия',
			'playerDetail.addToFriends' => 'Добавить в друзья',
			'playerDetail.requestSent' => 'Отправлено',
			'playerDetail.rankedLabel' => ({required Object rank, required Object xp}) => '#${rank} место · ${xp} XP',
			'playerDetail.alreadyFriends' => 'Вы друзья',
			'playerDetail.acceptRequest' => 'Принять',
			'playerDetail.declineRequest' => 'Отклонить',
			'playerDetail.aiQuizzesTitle' => 'Викторины',
			'friends.addFriend' => 'Добавить друга',
			'friends.searchPlaceholder' => 'Поиск друзей',
			'friends.allSection' => 'Все друзья',
			'friends.noneFound' => 'Друзья не найдены',
			'addFriend.searchByUsername' => 'Поиск по имени пользователя',
			'addFriend.orViaInviteLink' => 'Или по пригласительной ссылке',
			'addFriend.yourInviteCode' => 'Ваш код приглашения',
			'addFriend.shareLink' => 'Поделиться ссылкой',
			'addFriend.addButton' => 'Добавить',
			'addFriend.requestedLabel' => 'Запрос отправлен',
			'addFriend.noUsersFound' => 'Пользователи не найдены',
			'friendRequests.title' => 'Запросы в друзья',
			'friendRequests.emptyState' => 'Пока нет запросов',
			'duelPick.title' => 'Дуэль 1×1',
			'duelPick.chooseYourFriend' => 'Выберите друга',
			'profile.editProfile' => 'Редактировать профиль',
			'profile.settings' => 'Настройки',
			'profile.statTotalGames' => 'Всего игр',
			'profile.statWinRate' => 'Процент побед',
			'profile.statLongestStreak' => 'Самая длинная серия',
			'profile.gameHistory' => 'История игр',
			'profile.settingsAndHelp' => 'Настройки и помощь',
			'profile.levelWithTitle' => ({required Object level, required Object title}) => 'Уровень ${level} · ${title}',
			'profile.xpProgressLabel' => ({required Object current, required Object target, required Object remaining}) => '${current} / ${target} XP · до следующего уровня ${remaining}',
			'settings.groupGeneral' => 'Общее',
			'settings.language' => 'Язык',
			'settings.notifications' => 'Уведомления',
			'settings.theme' => 'Тема',
			'settings.themeLight' => 'Светлая',
			'settings.themeDark' => 'Тёмная',
			'settings.soundEffects' => 'Звуковые эффекты',
			'settings.groupAccount' => 'Аккаунт',
			'settings.privacy' => 'Конфиденциальность',
			'settings.helpCenter' => 'Центр помощи',
			'settings.termsOfUse' => 'Условия использования',
			'settings.changePassword' => 'Изменить пароль',
			'settings.logOut' => 'Выйти',
			'settings.groupDangerZone' => 'Опасная зона',
			'settings.deleteAccount' => 'Удалить аккаунт',
			'changePassword.title' => 'Изменить пароль',
			'changePassword.currentPasswordLabel' => 'Текущий пароль',
			'changePassword.currentPasswordHint' => 'Введите текущий пароль',
			'changePassword.newPasswordLabel' => 'Новый пароль',
			'changePassword.newPasswordHint' => 'Минимум 8 символов',
			'changePassword.confirmNewPasswordLabel' => 'Подтвердите новый пароль',
			'changePassword.confirmNewPasswordHint' => 'Введите новый пароль ещё раз',
			'changePassword.saveButton' => 'Сохранить',
			'changePassword.updated' => 'Пароль успешно изменён',
			'deleteAccount.confirmTitle' => 'Удалить аккаунт',
			'deleteAccount.confirmMessage' => 'Это действие нельзя отменить. Все ваши данные — друзья, история, баллы — будут безвозвратно удалены. Введите пароль, чтобы продолжить.',
			'deleteAccount.confirmButton' => 'Да, удалить',
			'history.segmentAll' => 'Все',
			'history.segmentSolo' => 'Соло',
			'history.segmentDuel' => 'Дуэль',
			'history.segmentLobby' => 'Комната',
			'history.winBadge' => 'Победа',
			'history.lossBadge' => 'Поражение',
			'history.drawBadge' => 'Ничья',
			'history.today' => 'Сегодня',
			'history.yesterday' => 'Вчера',
			'history.daysAgo' => ({required Object days}) => '${days} дней назад',
			'history.emptyState' => 'Игры этого типа пока не сохраняются',
			'history.noGamesYet' => 'Пока нет сыгранных игр',
			'history.lobbyPlayerCount' => ({required Object count}) => '${count} игроков',
			'quizSetup.title' => 'Сколько вопросов?',
			'quizSetup.subtitle' => 'Выберите готовый вариант или укажите своё число',
			'quizSetup.customLabel' => 'Свой вариант',
			'quizSetup.startButton' => 'Начать викторину',
			'quizIntro.startLabel' => 'Старт!',
			'quiz.questionProgress' => ({required Object current, required Object total}) => 'Вопрос ${current} из ${total}',
			'ballReveal.title' => 'Ваши баллы',
			'ballReveal.ballLabel' => 'баллов',
			'result.label' => 'Результат',
			'result.summary' => ({required Object correct, required Object total}) => '${correct} из ${total} правильно',
			'result.totalBall' => ({required Object ball}) => '${ball} баллов',
			'result.xpEarned' => ({required Object xp}) => '+${xp} XP',
			'result.playAgain' => 'Играть снова',
			'result.challengeAFriend' => 'Вызвать друга',
			'result.backToHome' => 'На главную',
			'result.breakdownTitle' => 'Результаты по вопросам',
			'joinCode.hint' => 'Введите 6-значный код комнаты, который прислал друг',
			'joinCode.joinButton' => 'Присоединиться',
			'joinCode.codeDigitLabel' => ({required Object position}) => 'Цифра кода ${position}',
			'joinCode.roomNotFound' => 'Комната с таким кодом не найдена',
			'joinCode.roomFull' => 'Эта комната заполнена',
			'joinCode.alreadyStarted' => 'Игра в этой комнате уже началась',
			'joinCode.timedOut' => 'Не удалось подключиться — проверьте соединение и попробуйте снова',
			'lobby.title' => 'Комната для нескольких игроков',
			'lobby.roomCode' => 'Код комнаты',
			'lobby.players' => 'Игроки',
			'lobby.hostRole' => 'Хост',
			'lobby.guestRole' => 'Гость',
			'lobby.startGame' => 'Начать игру',
			'lobby.waitingForHost' => 'Ожидание, пока хост начнёт игру…',
			'lobby.playerCount' => ({required Object current, required Object max}) => '${current}/${max}',
			'lobby.closedMessage' => 'Хост покинул комнату, комната закрыта',
			'lobby.creatingRoom' => 'Создание комнаты…',
			'lobby.createFailed' => 'Не удалось создать комнату — проверьте соединение и попробуйте снова',
			'lobby.backToHome' => 'На главную',
			'lobbyGame.title' => 'Комната',
			'lobbyGame.waitingForQuestion' => 'Подготовка вопроса…',
			'lobbyGame.waitingForOthers' => 'Вы ответили на все вопросы! Ждём остальных…',
			'lobbyGame.startFailed' => 'Игра не началась — проверьте соединение и попробуйте снова',
			'lobbyGame.backToHome' => 'На главную',
			'lobbyResult.title' => 'Результаты комнаты',
			'lobbyResult.subtitle' => 'Вот как сыграли все в комнате',
			'lobbyResult.playAgain' => 'Играть снова',
			'duelWaiting.title' => 'Дуэль',
			'duelWaiting.waitingForAccept' => 'Приглашение отправлено, ожидание ответа…',
			'duelWaiting.declined' => 'Приглашение отклонено',
			'duelWaiting.expired' => 'Срок приглашения истёк',
			'duelWaiting.failed' => 'Не удалось отправить приглашение',
			'duelWaiting.timedOut' => 'Не удалось связаться с другом — проверьте соединение и попробуйте снова',
			'duelWaiting.backToHome' => 'На главную',
			'duelInvite.title' => 'Приглашение на дуэль',
			'duelInvite.challengesYou' => 'вызывает вас на дуэль',
			'duelInvite.accept' => 'Принять',
			'duelInvite.decline' => 'Отклонить',
			'duelGame.title' => 'Дуэль',
			'duelGame.waitingForQuestion' => 'Подготовка вопроса…',
			'duelGame.opponentProgress' => ({required Object index, required Object total}) => 'Соперник: вопрос ${index}/${total}',
			'duelGame.waitingForOpponent' => 'Вы ответили на все вопросы! Ждём соперника…',
			'duelGame.startFailed' => 'Игра не началась — проверьте соединение и попробуйте снова',
			'duelGame.backToHome' => 'На главную',
			'duelResult.won' => 'Вы победили!',
			'duelResult.lost' => 'Вы проиграли',
			'duelResult.draw' => 'Ничья!',
			'duelResult.yourScoreLabel' => 'Вы',
			'duelResult.opponentScoreLabel' => 'Соперник',
			'notifications.title' => 'Уведомления',
			'notifications.duelChallenge' => ({required Object name}) => '${name} вызвал(а) вас на дуэль',
			'notifications.duelChallengeGeneric' => 'Вас вызвали на дуэль',
			'notifications.streakReminder' => 'Не теряйте серию из 5 дней — играйте сегодня!',
			'notifications.top50' => 'Вы попали в топ-50 недели',
			'notifications.friendRequest' => ({required Object name}) => '${name} отправил(а) вам запрос в друзья',
			'notifications.friendRequestGeneric' => 'Вам пришёл новый запрос в друзья',
			'notifications.welcome' => 'Добро пожаловать в Zukkor! Начните свою первую викторину',
			'notifications.emptyState' => 'Пока нет уведомлений',
			'editProfile.save' => 'Сохранить',
			'editProfile.updated' => 'Профиль обновлён',
			'notificationSettings.title' => 'Настройки уведомлений',
			'notificationSettings.duelInvites' => 'Приглашения на дуэль',
			'notificationSettings.streakReminders' => 'Напоминания о серии',
			'notificationSettings.leaderboardUpdates' => 'Обновления рейтинга',
			'notificationSettings.friendRequests' => 'Запросы в друзья',
			'notificationSettings.productUpdates' => 'Новости о продукте',
			'privacyPolicy.title' => 'Политика конфиденциальности',
			'privacyPolicy.collectionTitle' => 'Какие данные мы собираем',
			'privacyPolicy.collectionBody' => 'Мы собираем ваше имя, имя пользователя и активность в викторинах — очки, сыгранные категории и серии — чтобы обеспечивать работу игры и показывать ваш прогресс.',
			'privacyPolicy.useTitle' => 'Как мы их используем',
			'privacyPolicy.useBody' => 'Ваши данные используются для работы Zukkor: подбора соперников в дуэлях и комнатах, расчёта XP и рейтингов, а также отображения вашей статистики.',
			'privacyPolicy.sharingTitle' => 'Передача данных',
			'privacyPolicy.sharingBody' => 'Мы не продаём ваши данные. Ваше имя, аватар и публичная статистика видны другим игрокам как часть обычного игрового процесса — например, в рейтинге, списке друзей и дуэлях.',
			'privacyPolicy.contactTitle' => 'Контакты',
			'privacyPolicy.contactBody' => 'Есть вопросы о своих данных? Обратитесь через Центр помощи, и мы свяжемся с вами.',
			'termsOfUse.title' => 'Условия использования',
			'termsOfUse.accountTitle' => 'Ваш аккаунт',
			'termsOfUse.accountBody' => 'Вы несёте ответственность за безопасность своего аккаунта и за действия, совершённые под ним.',
			'termsOfUse.conductTitle' => 'Честная игра',
			'termsOfUse.conductBody' => 'Обман, использование багов ради XP или преследование других игроков может привести к блокировке.',
			'termsOfUse.contentTitle' => 'Контент',
			'termsOfUse.contentBody' => 'Вопросы викторины и контент приложения принадлежат Zukkor. Их нельзя копировать или распространять без разрешения.',
			'termsOfUse.changesTitle' => 'Изменения',
			'termsOfUse.changesBody' => 'Мы можем обновлять эти условия по мере развития Zukkor. О любых важных изменениях мы вас уведомим.',
			'helpCenter.duelQuestion' => 'Как начать дуэль?',
			'helpCenter.duelAnswer' => 'Перейдите в раздел «Друзья», выберите друга онлайн, затем категорию. Сопернику придёт приглашение.',
			'helpCenter.xpQuestion' => 'Как начисляется XP?',
			'helpCenter.xpAnswer' => 'Вы получаете XP за каждый правильный ответ, а также бонус за завершение соло-викторины или победу в дуэли.',
			'helpCenter.streakQuestion' => 'Что будет, если я пропущу день?',
			'helpCenter.streakAnswer' => 'Ваша серия обнуляется, если вы пропустите целый день без хотя бы одной сыгранной викторины.',
			'helpCenter.lobbyQuestion' => 'Сколько игроков может присоединиться к комнате?',
			'helpCenter.lobbyAnswer' => 'Сейчас комнаты поддерживают до 10 игроков.',
			'helpCenter.reportQuestion' => 'Как сообщить об ошибке или некорректном вопросе?',
			'helpCenter.reportAnswer' => 'Свяжитесь с нами через этот Центр помощи. Мы небольшая команда, и каждое сообщение помогает нам улучшать Zukkor.',
			'bottomNav.home' => 'Главная',
			'bottomNav.leaderboard' => 'Рейтинг',
			'bottomNav.friends' => 'Друзья',
			'bottomNav.profile' => 'Профиль',
			'bottomNav.comingSoon' => 'Скоро',
			'onboarding.stepCount' => 'Шаг',
			'onboarding.continueButton' => 'Продолжить',
			'onboarding.start' => 'Начать',
			'onboarding.avatarTitle' => 'Выберите подходящий аватар',
			'onboarding.avatarSubtitle' => 'Вы всегда сможете изменить его позже',
			'onboarding.uploadPhoto' => 'Загрузить фото',
			'onboarding.profileTitle' => 'Давайте познакомимся',
			'onboarding.profileSubtitle' => 'Эта информация будет видна в вашем профиле и вашим друзьям',
			'onboarding.firstNameLabel' => 'Имя',
			'onboarding.firstNameHint' => 'Азиз',
			'onboarding.lastNameLabel' => 'Фамилия',
			'onboarding.lastNameHint' => 'Каримов',
			'onboarding.usernameLabel' => 'Имя пользователя',
			'onboarding.usernameHint' => 'aziz_karimov',
			'onboarding.directionTitle' => 'Зачем вы используете Zukkor?',
			'onboarding.directionSubtitle' => 'Мы порекомендуем подходящий контент и категории',
			'onboarding.directionRequired' => 'Выберите один вариант, чтобы продолжить',
			'onboarding.studentUniTitle' => 'Студент',
			'onboarding.studentUniSubtitle' => 'Учусь в университете или колледже',
			'onboarding.studentSchoolTitle' => 'Школьник',
			'onboarding.studentSchoolSubtitle' => 'Учусь в школе',
			'onboarding.examPrepTitle' => 'Подготовка к экзамену',
			'onboarding.examPrepSubtitle' => 'Готовлюсь к экзамену (например, IELTS)',
			'onboarding.casualTitle' => 'Просто для удовольствия',
			'onboarding.casualSubtitle' => 'Играю, провожу время',
			'introduction.skip' => 'Пропустить',
			'introduction.getStarted' => 'Начать',
			'introduction.welcomeTitle' => 'Добро пожаловать в Zukkor!',
			'introduction.welcomeSubtitle' => 'Приложение-соревнование знаний, где обучение похоже на игру',
			'introduction.languageLabel' => 'Выберите язык',
			'introduction.soloTitle' => 'Проверьте себя',
			'introduction.soloSubtitle' => 'Выберите категорию и отвечайте на вопросы соло — зарабатывайте XP и побеждайте свой лучший результат',
			'introduction.duelTitle' => 'Бросьте вызов друзьям',
			'introduction.duelSubtitle' => 'Сразитесь с другом один на один или создайте комнату и играйте с целой группой в реальном времени',
			'introduction.leaderboardTitle' => 'Поднимайтесь в рейтинге',
			'introduction.leaderboardSubtitle' => 'Каждый правильный ответ приносит XP — следите за своим местом среди друзей и всех остальных',
			'introduction.interestsTitle' => 'Что вам интересно?',
			'introduction.interestsSubtitle' => 'Выберите несколько вариантов — мы используем их для рекомендации категорий',
			'introduction.studyTitle' => 'Почти готово!',
			'introduction.studySubtitle' => 'Ещё пара быстрых вопросов',
			'introduction.studyPlaceLabel' => 'Где вы учитесь?',
			'introduction.quizLikingLabel' => 'Вам нравится решать викторины и головоломки?',
			'introduction.studyPlaceSchool' => 'Школа',
			'introduction.studyPlaceUniversity' => 'Университет',
			'introduction.studyPlaceExamPrep' => 'Подготовка к экзамену',
			'introduction.quizLikingLoveIt' => 'Очень нравится',
			'introduction.quizLikingItsOk' => 'Нормально',
			'introduction.quizLikingNotReally' => 'Не особо',
			'introduction.otherOption' => 'Другое',
			'introduction.otherFieldLabel' => 'Расскажите подробнее',
			'introduction.otherFieldHint' => 'Введите здесь...',
			'auth.loginTitle' => 'С возвращением!',
			'auth.loginSubtitle' => 'Войдите и продолжите игру',
			'auth.registerTitle' => 'Создать аккаунт',
			'auth.registerSubtitle' => 'Зарегистрируйтесь за минуту и начните',
			'auth.emailLabel' => 'Email',
			'auth.emailHint' => 'you@example.com',
			'auth.passwordLabel' => 'Пароль',
			'auth.passwordHint' => 'Минимум 8 символов',
			'auth.confirmPasswordLabel' => 'Подтвердите пароль',
			'auth.confirmPasswordHint' => 'Введите пароль ещё раз',
			'auth.loginButton' => 'Войти',
			'auth.registerButton' => 'Зарегистрироваться',
			'auth.orDivider' => 'или',
			'auth.continueWithGoogle' => 'Продолжить через Google',
			'auth.noAccountPrompt' => 'Нет аккаунта?',
			'auth.haveAccountPrompt' => 'Уже есть аккаунт?',
			'auth.switchToRegister' => 'Зарегистрироваться',
			'auth.switchToLogin' => 'Войти',
			'authValidation.emailRequired' => 'Введите email',
			'authValidation.emailInvalid' => 'Неверный формат email',
			'authValidation.passwordRequired' => 'Введите пароль',
			'authValidation.passwordTooShort' => 'Пароль должен содержать минимум 8 символов, 1 заглавную букву и 1 цифру',
			'authValidation.passwordMismatch' => 'Пароли не совпадают',
			'authValidation.usernameRequired' => 'Введите имя пользователя',
			'authValidation.usernameInvalid' => 'Имя пользователя может содержать только буквы, цифры и нижнее подчёркивание (3–30 символов)',
			'authValidation.usernameTaken' => 'Это имя пользователя уже занято',
			'authValidation.nameRequired' => 'Это поле обязательно',
			'authValidation.nameTooLong' => 'Слишком длинно (максимум 50 символов)',
			'errors.noConnection' => 'Нет подключения к интернету. Проверьте соединение и попробуйте снова.',
			'errors.timeout' => 'Сервер не отвечает. Попробуйте ещё раз чуть позже.',
			'errors.server' => 'Произошла ошибка сервера. Попробуйте ещё раз чуть позже.',
			'errors.unknown' => 'Произошла непредвиденная ошибка.',
			'errors.invalidCredentials' => 'Неверный email или пароль.',
			'errors.sessionExpired' => 'Сессия истекла. Пожалуйста, войдите снова.',
			'errors.googleCancelled' => 'Вход через Google отменён.',
			'aiQuiz.entryCardLabel' => 'Создать викторину из документа с помощью AI',
			'aiQuiz.myQuizzesTitle' => 'Мои AI-викторины',
			'aiQuiz.createButton' => '+ Создать новую AI-викторину',
			'aiQuiz.emptyTitle' => 'У вас пока нет AI-викторин',
			'aiQuiz.emptySubtitle' => 'Загрузите документ (PDF, Word или текст), и мы создадим викторину на его основе',
			'aiQuiz.deleteConfirmTitle' => 'Удалить викторину',
			'aiQuiz.deleteConfirmMessage' => ({required Object name}) => 'Удалить «${name}»? Это действие необратимо.',
			'aiQuiz.generateTitle' => 'Создать викторину с AI',
			'aiQuiz.generateSubtitle' => 'Создайте викторину с помощью AI из документа или темы',
			'aiQuiz.modeDocumentLabel' => 'Документ',
			'aiQuiz.modeTopicLabel' => 'Тема',
			'aiQuiz.pickFileLabel' => 'Выбрать документ (PDF, Word, текст)',
			'aiQuiz.pickFileFirst' => 'Сначала выберите документ',
			'aiQuiz.instructionLabel' => 'Инструкция (необязательно)',
			'aiQuiz.instructionHint' => 'Например: 10 вопросов по 3 главе, или по всему документу',
			'aiQuiz.topicLabel' => 'Тема квиза',
			'aiQuiz.topicHint' => 'Например: история Второй мировой войны, или узбекские фильмы',
			'aiQuiz.topicRequired' => 'Введите тему',
			'aiQuiz.questionCountLabel' => 'Количество вопросов',
			'aiQuiz.generateButton' => 'Сгенерировать',
			'aiQuiz.generated' => 'Готово! Сохранено в «Мои AI-викторины»',
			'aiQuiz.generatingTitle' => 'AI генерирует вопросы...',
			'aiQuiz.generatingSubtitle' => 'Это может занять некоторое время, пожалуйста подождите',
			'aiQuiz.sourceAi' => 'AI',
			'aiQuiz.sourceManual' => 'Вручную',
			'aiQuiz.visibilityPrivate' => 'Никто',
			'aiQuiz.visibilityFriends' => 'Друзья',
			'aiQuiz.visibilityPublic' => 'Все',
			'aiQuiz.visibilityDialogTitle' => 'Кто может видеть?',
			'aiQuiz.visibilityUpdated' => 'Видимость изменена',
			'aiQuiz.createChooseTitle' => 'Как хотите создать?',
			'aiQuiz.createViaAi' => 'С помощью AI',
			'aiQuiz.createManually' => 'Вручную',
			'aiQuiz.createManualTitle' => 'Создать викторину вручную',
			'aiQuiz.manualNameLabel' => 'Название викторины',
			'aiQuiz.manualNameHint' => 'Например: Мой тест по географии',
			'aiQuiz.manualNameRequired' => 'Введите название',
			'aiQuiz.manualQuestionLabel' => ({required Object number}) => 'Вопрос ${number}',
			'aiQuiz.manualQuestionTextLabel' => 'Текст вопроса',
			'aiQuiz.manualOptionLabel' => ({required Object number}) => 'Вариант ${number}',
			'aiQuiz.manualFillAllFields' => 'Заполните все поля',
			'aiQuiz.manualAddQuestion' => '+ Добавить вопрос',
			'aiQuiz.manualSubmit' => 'Создать',
			'aiQuiz.opponentQuizzesEntryLabel' => 'Викторины соперника',
			'aiQuiz.noSharedQuizzes' => 'Этот пользователь пока не поделился викторинами',
			_ => null,
		};
	}
}
