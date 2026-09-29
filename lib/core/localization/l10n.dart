import 'package:flutter/widgets.dart';

/// Single source for every on-screen string.
/// Getter names match the copy they return.
class L10n {
  const L10n(this.locale);

  final Locale locale;

  bool get _ar => locale.languageCode == 'ar';

  String _t(String en, String ar) => _ar ? ar : en;

  static L10n of(BuildContext context) {
    return Localizations.of<L10n>(context, L10n) ?? const L10n(Locale('en'));
  }

  static const supportedLocales = [Locale('en'), Locale('ar')];

  static const delegate = _L10nDelegate();

  // --- Shared ---
  String get appName => _t('Yalla 5roga', 'يلا خروجة');
  String get arabic => _t('العربية', 'العربية');
  String get english => _t('English', 'English');
  String get cancel => _t('Cancel', 'إلغاء');
  String get confirm => _t('Confirm', 'تأكيد');
  String get ok => _t('OK', 'حسناً');
  String get share => _t('Share', 'مشاركة');
  String get search => _t('Search', 'بحث');
  String get searchGroups => _t('Search groups', 'ابحث عن مجموعة');
  String get back => _t('Back', 'رجوع');
  String get edit => _t('Edit', 'تعديل');
  String get change => _t('Change', 'تغيير');
  String get today => _t('Today', 'اليوم');
  String get all => _t('All', 'الكل');
  String get owner => _t('Owner', 'المالك');
  String get admin => _t('Admin', 'مشرف');
  String get member => _t('Member', 'عضو');
  String get members => _t('Members', 'الأعضاء');
  String get date => _t('Date', 'التاريخ');
  String get time => _t('Time', 'الوقت');

  // --- Splash ---
  String get plansMadeSimple => _t('Plans made simple', 'خطط أسهل');
  String get splashHeadline1 => _t('Less “where?”', 'أقل «هنروح فين؟»');
  String get splashHeadline2 => _t('More “we’re there.”', 'أكثر «يلا بينا».');
  String get splashBody => _t(
        'Create a group, vote on the plan, and make the outing actually happen.',
        'كوّن مجموعة، صوّتوا على الخطة، وخلّوا الخروجة تحصل بجد.',
      );
  String get getStarted => _t('Get Started', 'ابدأ الآن');
  String get alreadyHaveAccount => _t('I already have an account · Log in', 'لدي حساب بالفعل · تسجيل الدخول');
  String get fridayPlan => _t('FRIDAY PLAN', 'خطة الجمعة');
  String get zedParkPicnic => _t('ZED Park Picnic', 'نزهة في حديقة زد');
  String get friendsAreIn => _t('7 friends are in', '٧ أصدقاء مشاركون');
  String get votedAll => _t('8/8 voted ✓', 'صوّت ٨/٨ ✓');
  String get seeYouThere => _t('See you there!', 'نشوفك هناك!');

  // --- Auth ---
  String get login => _t('Log In', 'تسجيل الدخول');
  String get register => _t('Sign Up', 'إنشاء حساب');
  String get createAccount => _t('Create Account', 'إنشاء حساب');
  String get password => _t('Password', 'كلمة المرور');
  String get name => _t('Full name', 'الاسم الكامل');
  String get phone => _t('Phone number', 'رقم الهاتف');
  String get phoneHint => _t('100 123 4567', '100 123 4567');
  String get email => _t('Email', 'البريد الإلكتروني');
  String get passwordHint => _t('At least 8 characters', '٨ أحرف على الأقل');
  String get nameHint => _t('Ahmed Hassan', 'أحمد حسن');
  String get forgotPassword => _t('Forgot password?', 'نسيت كلمة المرور؟');
  String get otp => _t('OTP code', 'رمز التحقق');
  String get otpHint => _t('6-digit code', 'رمز من ٦ أرقام');
  String get invalidOtp => _t('Enter the 6-digit code sent to your phone', 'أدخل الرمز المكوّن من ٦ أرقام المرسل إلى هاتفك');
  String otpSent(String phone) => _t('OTP sent to $phone', 'تم إرسال رمز التحقق إلى $phone');
  String get resendOtp => _t('Resend code', 'إعادة إرسال الرمز');
  String get sendOtp => _t('Send OTP', 'إرسال رمز التحقق');
  String get requiredField => _t('This field is required', 'هذا الحقل مطلوب');
  String get invalidPhone => _t('Enter a valid Egyptian phone number', 'أدخل رقم هاتف مصري صالح');
  String get passwordTooShort => _t('Password must be at least 8 characters', 'كلمة المرور يجب أن تكون ٨ أحرف على الأقل');
  String get loginFailed => _t('Login failed', 'فشل تسجيل الدخول');
  String get registerFailed => _t('Registration failed', 'فشل إنشاء الحساب');
  String get welcomeBack => _t('Welcome back', 'أهلاً بعودتك');
  String get welcomeNew => _t('Welcome', 'أهلاً بك');
  String get demoUserName => _t('Ahmed Hassan', 'أحمد حسن');
  String get demoFirstName => _t('Ahmed', 'أحمد');
  String get demoPhone => _t('+20 100 123 4567', '+20 100 123 4567');
  String get noInternet => _t('No internet connection', 'لا يوجد اتصال بالإنترنت');
  String get unexpectedError => _t('Something went wrong. Please try again.', 'حدث خطأ. حاول مرة أخرى.');
  String get letsGetYouOut => _t('Let’s get you out.', 'يلا نخرج.');
  String get joinTheFun => _t('Join the fun.', 'انضم للمتعة.');
  String get authLoginSubtitle => _t(
        'Your next favorite memory is already being planned.',
        'ذكرياتك المفضلة القادمة يتم التخطيط لها الآن.',
      );
  String get authSignupSubtitle => _t(
        'Create an account and start making plans together.',
        'أنشئ حساباً وابدأ التخطيط مع أصحابك.',
      );
  String get newHere => _t('New here?', 'جديد هنا؟');
  String get createYourAccount => _t('Create your account', 'أنشئ حسابك');
  String get alreadyMember => _t('Already a member?', 'لديك حساب بالفعل؟');
  String get agreeTerms => _t('I agree to the Terms and Privacy Policy.', 'أوافق على الشروط وسياسة الخصوصية.');
  String get resetLinkSent => _t('A reset code will be sent to your phone', 'سيتم إرسال رمز الاستعادة إلى هاتفك');
  String welcomeBackName(String name) => _t('Welcome back, $name!', 'أهلاً بعودتك، $name!');
  String get accountCreated => _t('Account created successfully!', 'تم إنشاء الحساب بنجاح!');
  String get termsRequired => _t('Please agree to the Terms first', 'وافق على الشروط أولاً');

  // --- Navigation ---
  String get navHome => _t('Home', 'الرئيسية');
  String get navGroups => _t('Groups', 'المجموعات');
  String get navOutings => _t('Outings', 'الخروجات');
  String get navProfile => _t('Profile', 'الملف الشخصي');
  String get navSettings => _t('Settings', 'الإعدادات');
  String get settings => _t('Settings', 'الإعدادات');

  // --- Home ---
  String get goodMorning => _t('Good morning,', 'صباح الخير،');
  String get goodAfternoon => _t('Good afternoon,', 'مساء الخير،');
  String get goodEvening => _t('Good evening,', 'مساء الخير،');
  String greetingForHour(int hour) {
    if (hour < 12) return goodMorning;
    if (hour < 17) return goodAfternoon;
    return goodEvening;
  }
  String get nextUp => _t('Next up', 'الخروجة القادمة');
  String get quickActions => _t('Quick actions', 'إجراءات سريعة');
  String get makeItHappen => _t('Make it happen', 'خلّيها تحصل');
  String get newOuting => _t('New outing', 'خروجة جديدة');
  String get createSpecialEvent => _t('Create a special event', 'إنشاء مناسبة خاصة');
  String get specialEventSubtitle => _t('Plan a birthday, wedding, or celebration', 'خطط لعيد ميلاد أو فرح أو احتفال');
  String get newGroup => _t('New group', 'مجموعة جديدة');
  String get discover => _t('Discover', 'استكشف');
  String get invite => _t('Invite', 'ادعُ أصدقاءك');
  String get happeningNow => _t('Happening now', 'يحدث الآن');
  String get seeAll => _t('See all', 'عرض الكل');
  String get twoHoursLeft => _t('2h left', 'متبقي ساعتان');
  String get exploreNearby => _t('Explore nearby places', 'استكشف الأماكن القريبة');
  String get inviteFriends => _t('Invite your friends', 'ادعُ أصدقاءك');
  String inviteDownloadMessage(String url) => _t(
        'Hey! Come plan outings with me on Yalla 5roga. Download the app: $url',
        'تعالى نخطط خروجتنا مع بعض على يلا خروجة. نزّل التطبيق من هنا: $url',
      );
  String get couldNotOpenWhatsApp => _t('Could not open WhatsApp', 'تعذّر فتح واتساب');
  String get tryThis => _t('Try this', 'جرّب دي');
  String get suggestedForYou => _t('Suggested for you', 'مقترحة لك');
  String get discoverSubtitle => _t('Browse places with vibes, prices, and hours', 'تصفح أماكن بأجواء وأسعار ومواعيد');
  String get nearbyPlaces => _t('Nearby places', 'أماكن قريبة');
  String get featuredPlaces => _t('Featured places', 'أماكن مميزة');
  String get allPlaces => _t('All places', 'كل الأماكن');
  String get aboutPlace => _t('About', 'عن المكان');
  String get prices => _t('Prices', 'الأسعار');
  String get workingHours => _t('Working hours', 'مواعيد العمل');
  String get closed => _t('Closed', 'مغلق');
  String get planOutingHere => _t('Plan an outing here', 'خطط خروجة هنا');
  String get otpSendFailed => _t('Could not send verification code', 'تعذّر إرسال رمز التحقق');
  String get useThisIdea => _t('Use this idea', 'استخدم الفكرة');
  String get planThisOuting => _t('Plan this outing', 'خطط الخروجة');
  String get allVibes => _t('All vibes', 'كل الأجواء');
  String outingAtPlace(String place, String time) => _t('$place · $time', '$place · $time');

  String priceLevelLabel(String level) => switch (level) {
        'free' => _t('Free', 'مجاني'),
        'budget' => _t('Budget', 'اقتصادي'),
        'moderate' => _t('Moderate', 'متوسط'),
        'expensive' => _t('Expensive', 'مرتفع'),
        'luxury' => _t('Luxury', 'فاخر'),
        _ => level,
      };

  String weekdayLabel(String day) => switch (day) {
        'monday' => _t('Monday', 'الاثنين'),
        'tuesday' => _t('Tuesday', 'الثلاثاء'),
        'wednesday' => _t('Wednesday', 'الأربعاء'),
        'thursday' => _t('Thursday', 'الخميس'),
        'friday' => _t('Friday', 'الجمعة'),
        'saturday' => _t('Saturday', 'السبت'),
        'sunday' => _t('Sunday', 'الأحد'),
        _ => day,
      };

  String discoverPriceLabel(String key) => switch (key) {
        'entry' => _t('Entry', 'دخول'),
        'parking' => _t('Parking', 'انتظار'),
        'brunch_set' => _t('Brunch set', 'وجبة برانش'),
        'coffee' => _t('Coffee', 'قهوة'),
        'games' => _t('Games', 'ألعاب'),
        'drinks' => _t('Drinks', 'مشروبات'),
        'bowling' => _t('Bowling', 'بولينج'),
        'food' => _t('Food', 'أكل'),
        'ticket' => _t('Ticket', 'تذكرة'),
        'combo' => _t('Combo', 'كومبو'),
        'dinner' => _t('Dinner', 'عشاء'),
        _ => key,
      };

  String discoverPlaceDescription(String key) => switch (key) {
        'zed-park' => _t(
              'Open lawns and picnic spots for sunset hangouts.',
              'مساحات خضراء وأماكن نزهة مناسبة لغروب الشمس.',
            ),
        'brunch-room' => _t(
              'Relaxed Maadi brunch spot with coffee and long tables.',
              'مكان برانش هادي في المعادي بقهوة وطاولات طويلة.',
            ),
        'tap-east' => _t(
              'Games, rounds, and a lively Heliopolis crowd.',
              'ألعاب وأجواء حيوية في مصر الجديدة.',
            ),
        'cfc' => _t(
              'Mall hub for bowling, food, and evening plans.',
              'مول فيه بولينج وأكل وخطط مسائية.',
            ),
        'vox-cfc' => _t(
              'Cinema nights with easy parking and food nearby.',
              'ليالي سينما مع باركينج سهل وأكل قريب.',
            ),
        'sequoia' => _t(
              'Nile-side dinner when you want something special.',
              'عشاء على النيل لما تحبوا حاجة مميزة.',
            ),
        'azhar-park' => _t(
              'Green views over Islamic Cairo for easy walks.',
              'مساحات خضراء مطلة على القاهرة الإسلامية للنزهة.',
            ),
        'zawya' => _t(
              'Indie screenings downtown with talks after the film.',
              'عروض مستقلة في وسط البلد ونقاش بعد الفيلم.',
            ),
        _ => '',
      };

  String vibeLabel(String vibe) => switch (vibe) {
        'food' => food,
        'activity' => activity,
        'outdoor' => outdoor,
        'movie' => movie,
        _ => all,
      };

  String suggestedArea(String area) => switch (area) {
        'New Cairo' => _t('New Cairo', 'القاهرة الجديدة'),
        'Maadi' => _t('Maadi', 'المعادي'),
        'Zamalek' => _t('Zamalek', 'الزمالك'),
        'Heliopolis' => _t('Heliopolis', 'مصر الجديدة'),
        'Islamic Cairo' => _t('Islamic Cairo', 'القاهرة الإسلامية'),
        'Garden City' => _t('Garden City', 'جاردن سيتي'),
        'Downtown' => _t('Downtown', 'وسط البلد'),
        'Cairo Festival City' => _t('Cairo Festival City', 'كايرو فستيفال سيتي'),
        _ => area,
      };

  String suggestedPlaceName(String id) => switch (id) {
        'zed-park' => _t('ZED Park', 'حديقة زد'),
        'brunch-room' => _t('The Brunch Room', 'ذا برانش روم'),
        'lucilles' => _t("Lucille's", 'لوسيل'),
        'tap-east' => _t('The Tap East', 'ذا تاب إيست'),
        'cfc' => _t('Cairo Festival City', 'كايرو فستيفال سيتي'),
        'left-bank' => _t('Left Bank', 'ليفت بانك'),
        'sequoia' => _t('Sequoia', 'سيكويا'),
        'os-pasta' => _t("O's Pasta", 'أوز باستا'),
        'azhar-park' => _t('Al Azhar Park', 'حديقة الأزهر'),
        'felucca' => _t('Felucca Dock', 'مرسى الفلوكة'),
        'wadi-degla' => _t('Wadi Degla Protectorate', 'محمية وادي دجلة'),
        'vox-cfc' => _t('VOX Cinemas', 'فوكس سينما'),
        'zawya' => _t('Zawya', 'زاوية'),
        _ => id,
      };

  String suggestedOutingTitle(String id) => switch (id) {
        'sunset-picnic' => _t('Sunset Picnic', 'نزهة الغروب'),
        'weekend-brunch' => _t('Weekend Brunch', 'فطار الويك إند'),
        'game-night' => _t('Game Night', 'ليلة الألعاب'),
        'bowling-night' => _t('Bowling Night', 'ليلة البولينج'),
        'cinema-night' => _t('Cinema Night', 'ليلة السينما'),
        'nile-felucca' => _t('Nile Felucca', 'فلوكة على النيل'),
        'pasta-night' => _t('Maadi Pasta Night', 'ليلة باستا في المعادي'),
        'wadi-walk' => _t('Wadi Degla Walk', 'مشي في وادي دجلة'),
        'indie-screening' => _t('Indie Screening', 'عرض فيلم مستقل'),
        'zamalek-dinner' => _t('Zamalek Dinner', 'عشاء الزمالك'),
        _ => id,
      };

  String suggestedOutingBlurb(String id) => switch (id) {
        'sunset-picnic' => _t('Blankets, snacks, and golden hour.', 'بطانيات ووجبات خفيفة وضوء الغروب.'),
        'weekend-brunch' => _t('Late start. Good coffee. No agenda.', 'بداية متأخرة. قهوة حلوة. من غير خطة.'),
        'game-night' => _t('Boards, rounds, and a long table.', 'ألعاب وطاولات طويلة.'),
        'bowling-night' => _t('Lanes booked. Trash talk optional.', 'الممرات محجوزة. الهزار اختياري.'),
        'cinema-night' => _t('Pick the film in the group vote.', 'اختاروا الفيلم بتصويت المجموعة.'),
        'nile-felucca' => _t('Slow sail before sunset.', 'فسحة هادية قبل الغروب.'),
        'pasta-night' => _t('One long table in Maadi.', 'ترابيزة طويلة في المعادي.'),
        'wadi-walk' => _t('Early hike, breakfast after.', 'مشي بدري والفطار بعدين.'),
        'indie-screening' => _t('Small room, big opinions after.', 'قاعة صغيرة ونقاش كبير بعد الفيلم.'),
        'zamalek-dinner' => _t('Nile view if you book ahead.', 'على النيل لو حجزتوا بدري.'),
        _ => '',
      };
  String get maadiCrewIsVoting => _t('Maadi Crew is voting', 'شلة المعادي بتصوّت');
  String get brunchSpotVoted => _t('Brunch spot · 5 of 8 voted', 'مكان الفطار · صوّت ٥ من ٨');
  String get cinemaSquadPickedPlan => _t('Cinema Squad picked a plan', 'سينما سكواد اختارت خطة');
  String get voxCinemasTomorrow => _t('VOX Cinemas · Tomorrow, 8:00 PM', 'فوكس سينما · بكرة ٨:٠٠ م');

  // --- Groups ---
  String get yourCircles => _t('Your circles', 'دوائرك');
  String get groupsTitle => _t('Groups', 'المجموعات');
  String get activeGroupsFriends => _t('3 active groups · 18 friends', '٣ مجموعات نشطة · ١٨ صديقاً');
  String get allGroups => _t('All groups', 'كل المجموعات');
  String get mostActive => _t('Most active', 'الأكثر نشاطاً');
  String get recentlyAdded => _t('Recently added', 'المضافة حديثاً');
  String get activeNow => _t('ACTIVE NOW', 'نشطة الآن');
  String get currentDecision => _t('CURRENT DECISION', 'القرار الحالي');
  String get whereBrunch => _t('Where should we brunch?', 'نفطر فين؟');
  String votedCount(int voted, int total) => _t('$voted/$total voted', 'صوّت $voted/$total');
  String get voteNow => _t('Vote now', 'صوّت الآن');
  String get startNewCircle => _t('Start a new circle', 'ابدأ مجموعة جديدة');
  String get inviteWithLink => _t('Invite friends with one link', 'ادعُ أصدقاءك برابط واحد');
  String membersOutings(int members, int outings) =>
      _t('$members members · $outings outings', '$members أعضاء · $outings خروجة');
  String get createGroup => _t('Create a group', 'إنشاء مجموعة');
  String get groupName => _t('Group name', 'اسم المجموعة');
  String get groupNameHint => _t('Friday friends', 'أصدقاء الجمعة');
  String get invitePeople => _t('Invite people', 'دعوة أشخاص');
  String get addPeople => _t('Add people', 'إضافة أشخاص');
  String get addByPhone => _t('Add people by phone number', 'إضافة أشخاص برقم الهاتف');
  String get addPhone => _t('Add', 'إضافة');
  String get phoneAlreadyAdded => _t('This number is already added', 'هذا الرقم مضاف بالفعل');
  String get changeGroupImage => _t('Choose a group photo', 'اختر صورة المجموعة');
  String get groupImageUpdated => _t('Group photo updated', 'تم تحديث صورة المجموعة');
  String memberAdded(String name) => _t('$name added to the group', 'تمت إضافة $name إلى المجموعة');
  String memberRemoved(String name) => _t('$name removed from the group', 'تمت إزالة $name من المجموعة');
  String get noMorePeople => _t('Everyone you know is already in this group', 'كل من تعرفه موجود بالفعل في هذه المجموعة');
  String get groupCreated => _t('Group created', 'تم إنشاء المجموعة');
  String get groupOutings => _t('Group outings', 'خروجات المجموعة');
  String get noGroupOutings => _t('No outings yet. Create the first one.', 'لا توجد خروجات بعد. أنشئ الأولى.');
  String get chooseGroup => _t('Choose a group', 'اختر مجموعة');

  // --- Outings ---
  String get makeAMemory => _t('Make a memory', 'اصنع ذكرى');
  String get outingsTitle => _t('Outings', 'الخروجات');
  String get plan => _t('New plan', 'خطّط جديدة');
  String get upcoming => _t('Upcoming', 'القادمة');
  String get voting => _t('Voting', 'التصويت');
  String get past => _t('Past', 'السابقة');
  String get thisWeekend => _t('This weekend', 'نهاية هذا الأسبوع');
  String get confirmed => _t('CONFIRMED', 'مؤكدة');
  String get youreIn => _t("You're in", 'أنت مشارك');
  String get viewPlan => _t('View plan', 'عرض الخطة');
  String get viewLocation => _t('View location', 'عرض الموقع');
  String get needsYourVote => _t('Needs your vote', 'تحتاج تصويتك');
  String get endsIn => _t('Ends in 2h 18m', 'ينتهي خلال ساعتين و١٨ دقيقة');
  String get fridayBrunchCrew => _t('Friday brunch with Maadi Crew', 'فطور الجمعة مع شلة المعادي');
  String get pickFavoritePlace => _t('Pick your favorite place', 'اختر مكانك المفضل');
  String votesPercent(int votes, int percent) => _t('$votes votes · $percent%', '$votes أصوات · $percent٪');
  String get createOuting => _t('Create an outing', 'إنشاء خروجة');
  String get funStartsHere => _t('The fun starts here', 'المتعة تبدأ هنا');
  String get saveDraft => _t('Save draft', 'حفظ المسودة');
  String stepOf(int current, int total) => _t('$current of $total', '$current من $total');
  String get theBasics => _t('The basics', 'الأساسيات');
  String get whatAreWeDoing => _t('What are we doing?', 'هنعمل إيه؟');
  String get addEssentials => _t(
        'Add the essentials now. Your group can vote on the details next.',
        'أضف الأساسيات الآن، وبعدها المجموعة تصوّت على التفاصيل.',
      );
  String get outingName => _t('Outing name', 'اسم الخروجة');
  String get defaultOutingName => _t('Friday brunch', 'فطار الجمعة');
  String get you => _t('You', 'أنت');
  String get now => _t('Now', 'الآن');
  String get lookingUpLocation => _t('Finding this place…', 'جارٍ التعرف على المكان…');
  String get shareStarted => _t('Opening share…', 'جارٍ فتح المشاركة…');
  String get pickAVibe => _t('Pick a vibe', 'اختر الجو');
  String get food => _t('Food', 'أكل');
  String get activity => _t('Activity', 'نشاط');
  String get outdoor => _t('Outdoor', 'في الخارج');
  String get movie => _t('Movie', 'سينما');
  String get inviteAGroup => _t('Invite a group', 'ادعُ مجموعة');
  String membersWillBeInvited(int count) => _t('$count members will be invited', 'سيتم دعوة $count أعضاء');
  String get saturday => _t('Saturday', 'السبت');
  String get startsAt => _t('Starts at', 'تبدأ الساعة');
  String get letGroupVote => _t('Let the group vote on the place', 'دع المجموعة تصوّت على المكان');
  String get everyoneCanSuggest => _t(
        'Everyone can suggest and vote before the deadline.',
        'يمكن للجميع الاقتراح والتصويت قبل الموعد.',
      );
  String get continueToLocation => _t('Continue to location', 'متابعة لاختيار المكان');
  String get draftSaved => _t('Draft saved', 'تم حفظ المسودة');
  String get outingSaved => _t('Outing saved', 'تم حفظ الخروجة');
  String get outingRemoved => _t('Removed from saved', 'تمت الإزالة من المحفوظات');
  String get draftRemoved => _t('Draft deleted', 'تم حذف المسودة');
  String get mySaved => _t('My saved', 'محفوظاتي');
  String get mySavedSubtitle => _t('Reuse a saved outing as a new plan', 'استخدم خروجة محفوظة كخطة جديدة');
  String savedCount(int count) => _t('$count saved', '$count محفوظ');
  String get noSavedOutings => _t('No saved outings yet. Bookmark one to reuse it later.', 'لا توجد خروجات محفوظة. احفظ واحدة لتعيد استخدامها لاحقاً.');
  String get drafts => _t('Drafts', 'المسودات');
  String get noDrafts => _t('No drafts yet. Save a plan from the review step.', 'لا توجد مسودات. احفظ خطة من خطوة المراجعة.');
  String get specialEvent => _t('Special event', 'مناسبة خاصة');
  String get specialEventHint => _t('Pick the occasion, then invite people from your groups.', 'اختر المناسبة ثم ادعُ أشخاصاً من مجموعاتك.');
  String get regularOuting => _t('Outing', 'خروجة');
  String get birthday => _t('Birthday', 'عيد ميلاد');
  String get wedding => _t('Wedding', 'فرح');
  String get eventName => _t('Event name', 'اسم المناسبة');
  String get invitePeopleHint => _t('Choose people from your groups', 'اختر أشخاصاً من مجموعاتك');
  String get selectAll => _t('Select all', 'تحديد الكل');
  String get clearSelection => _t('Clear', 'مسح');
  String guestsInvited(int count) => _t('$count guests invited', 'تمت دعوة $count ضيوف');
  String get guestsRequired => _t('Please invite at least one person', 'ادعُ شخصاً واحداً على الأقل');
  String get searchPlace => _t('Search for a place', 'ابحث عن مكان');
  String get searchPlaceHint => _t('Café, park, street…', 'كافيه، حديقة، شارع…');
  String get noPlaceResults => _t('No places found', 'لا توجد أماكن');
  String get currentLocation => _t('Use current location', 'استخدم موقعي الحالي');
  String get locationPermissionDenied => _t('Location permission is needed to pin where you are', 'نحتاج إذن الموقع لتحديد مكانك');
  String get locationDisabled => _t('Turn on location services to use your current place', 'فعّل خدمات الموقع لاستخدام مكانك الحالي');
  String get couldNotGetLocation => _t('Could not get your current location', 'تعذّر تحديد موقعك الحالي');
  String get locationAccessTitle => _t('Allow location access?', 'السماح بالوصول للموقع؟');
  String get locationAccessBody => _t(
        'Yalla 5roga uses your location to pin where you are on the map when you pick a place.',
        'يلا خروجة تستخدم موقعك لتحديد مكانك على الخريطة عند اختيار المكان.',
      );
  String get allow => _t('Allow', 'السماح');
  String get allowLocation => _t('Allow', 'السماح');
  String get notNow => _t('Not now', 'ليس الآن');
  String get openAppSettings => _t('Open settings', 'فتح الإعدادات');
  String get permissionNeededTitle => _t('Permission required', 'إذن مطلوب');
  String get notificationAccessTitle => _t('Allow notifications?', 'السماح بالإشعارات؟');
  String get notificationAccessBody => _t(
        'Yalla 5roga sends updates about outings, votes, and group activity. Allow notifications so you don’t miss anything.',
        'يلا خروجة ترسل تحديثات عن الخروجات والتصويت ونشاط المجموعات. اسمح بالإشعارات حتى لا يفوتك شيء.',
      );
  String get locationOpenSettingsBody => _t(
        'Location access is turned off. Open app settings and enable location to pin where you are.',
        'إذن الموقع مغلق. افتح إعدادات التطبيق وفعّل الموقع لتحديد مكانك.',
      );
  String get useSavedOuting => _t('Use this outing', 'استخدم هذه الخروجة');
  String get whoIsGoing => _t("Who's going", 'من سيذهب');
  String votedFor(String place) => _t('Voted for $place', 'صوّت لـ $place');
  String get votedGoing => _t('Going', 'سيذهب');
  String get notVotedYet => _t('Not voted yet', 'لم يصوّت بعد');
  String get openingChat => _t('Opening outing chat', 'فتح محادثة الخروجة');
  String get voteUpdated => _t('Your vote has been updated', 'تم تحديث تصويتك');
  String get chooseLocationNext => _t('Great! Let’s choose the location', 'رائع! لنختار المكان الآن');
  String get outingChat => _t('Outing chat', 'محادثة الخروجة');
  String get writeMessage => _t('Write a message', 'اكتب رسالة');
  String get chooseLocation => _t('Choose a location', 'اختر المكان');
  String get pickAPlace => _t('Where should we meet?', 'هنتقابل فين؟');
  String get locationHint => _t('Pick a custom place on the map', 'اختر مكاناً خاصاً من الخريطة');
  String get customPlace => _t('Custom place', 'مكان خاص');
  String get continueToReview => _t('Continue to review', 'متابعة للمراجعة');
  String get reviewOuting => _t('Review & create', 'مراجعة وإنشاء');
  String get almostThere => _t('Check the plan, then publish it to the group.', 'راجع الخطة ثم انشرها للمجموعة.');
  String get createAndGo => _t('Create outing', 'إنشاء الخروجة');
  String get outingCreated => _t('Outing created', 'تم إنشاء الخروجة');
  String get photoRequired => _t('Please upload an outing photo', 'ارفع صورة للخروجة');
  String get nameRequired => _t('Please add an outing name', 'أضف اسم الخروجة');
  String get locationRequired => _t('Please choose a location', 'اختر مكاناً');
  String get pickLocation => _t('Pick location', 'تحديد الموقع');
  String get pickOnMap => _t('Pick this place on the map', 'حدّد المكان على الخريطة');
  String get locationPinned => _t('Location set', 'تم تحديد الموقع');
  String get changeMapLocation => _t('Tap to change the pin', 'اضغط لتغيير العلامة');
  String get pickLocationRequired => _t('Please pin this new place on the map', 'حدّد المكان الجديد على الخريطة');
  String get tapToPin => _t('Tap the map to drop a pin', 'اضغط على الخريطة لوضع العلامة');
  String get confirmLocation => _t('Confirm location', 'تأكيد الموقع');
  String get groupRequired => _t('Please choose a group', 'اختر مجموعة');
  String hoursLeft(int hours) => _t('${hours}h left', 'متبقي $hours س');
  String goingCount(int count) => _t('$count going', '$count مشاركون');

  // --- Notifications ---
  String get notifications => _t('Notifications', 'الإشعارات');
  String unreadUpdates(int count) => _t('$count unread updates', '$count إشعارات غير مقروءة');
  String get markAllRead => _t('Mark all read', 'تعليم الكل كمقروء');
  String get allRead => _t('All read', 'تمت القراءة');
  String get unread => _t('Unread', 'غير المقروءة');
  String get earlier => _t('Earlier', 'سابقاً');
  String get allNotificationsRead => _t('All notifications marked as read', 'تم تعليم كل الإشعارات كمقروءة');

  // --- Profile ---
  String get yourSpace => _t('Your space', 'مساحتك');
  String get profile => _t('Profile', 'الملف الشخصي');
  String get outingsStat => _t('Outings', 'الخروجات');
  String get groupsStat => _t('Groups', 'المجموعات');
  String get showUp => _t('Show-up', 'الحضور');
  String get about => _t('About', 'حول');
  String get activityTab => _t('Activity', 'النشاط');
  String get personalDetails => _t('Personal details', 'البيانات الشخصية');
  String get accountSettings => _t('Account setting', 'إعدادات الحساب');
  String get language => _t('Language', 'اللغة');
  String get support => _t('Support', 'الدعم');
  String get helpAndFaq => _t('Help & FAQ', 'المساعدة والأسئلة');
  String get contactUs => _t('Contact Us', 'تواصل معنا');
  String get aboutYalla5roga => _t('About Yalla 5roga', 'عن يلا خروجة');
  String get privacyPolicy => _t('Privacy Policy', 'سياسة الخصوصية');
  String get termsAndConditions => _t('Terms & Conditions', 'الشروط والأحكام');
  String get developer => _t('Developer', 'المطوّر');
  String get faqCreateOuting => _t('How do I create an outing?', 'إزاي أعمل خروجة؟');
  String get faqCreateOutingAnswer => _t(
        'Open Outings or a group, tap Plan or Create outing, then add a photo, place, date, and invite your group.',
        'افتح الخروجات أو مجموعة، اضغط خطّط أو إنشاء خروجة، ثم أضف صورة ومكان وتاريخ وادعُ مجموعتك.',
      );
  String get faqGroups => _t('How do groups work?', 'المجموعات بتشتغل إزاي؟');
  String get faqGroupsAnswer => _t(
        'Create a group, add people by phone, then plan outings together and vote on the details.',
        'أنشئ مجموعة، أضف الناس برقم الهاتف، ثم خططوا الخروجات مع بعض وصوّتوا على التفاصيل.',
      );
  String get faqInvite => _t('How do I invite friends?', 'إزاي أدعو أصحابي؟');
  String get faqInviteAnswer => _t(
        'From a group, tap Add people and enter an Egyptian phone number. They will be invited to that group.',
        'من صفحة المجموعة اضغط إضافة أشخاص وأدخل رقم هاتف مصري. هيتضافوا للمجموعة.',
      );
  String get aboutAppBody => _t(
        'Yalla 5roga helps friends plan real outings. Create a group, vote on the place and time, and make the plan actually happen.',
        'يلا خروجة بتساعد الأصحاب يخططوا خروجات بجد. كوّنوا مجموعة، صوّتوا على المكان والوقت، وخلّوا الخطة تحصل.',
      );
  String get privacyPolicyBody => _t(
        'We store your name, phone number, and the photos you choose to upload so you can sign in and plan outings with your groups. We do not sell your personal data. You can delete your account from Profile at any time.',
        'بنحفظ اسمك ورقم هاتفك والصور اللي ترفعها عشان تسجّل وتخطط الخروجات مع مجموعاتك. مش بنبيع بياناتك. تقدر تحذف حسابك من الملف الشخصي في أي وقت.',
      );
  String get termsBody => _t(
        'By using Yalla 5roga you agree to use the app respectfully, invite only people you know, and keep group chats and photos appropriate. Plans and votes are for coordinating outings, not for commercial spam.',
        'باستخدام يلا خروجة بتوافق تستخدم التطبيق باحترام، وتدعو ناس تعرفهم، وتحافظ على المحادثات والصور بشكل لائق. الخطط والتصويت للتنسيق على الخروجات مش للإعلانات.',
      );
  String get memberSince => _t('Member since', 'عضو منذ');
  String get memberSinceDate => _t('March 2026', 'مارس ٢٠٢٦');
  String get preferences => _t('Preferences', 'التفضيلات');
  String get pushNotifications => _t('Push notifications', 'الإشعارات');
  String get votesPlansReminders => _t('Votes, plans, reminders', 'التصويتات والخطط والتذكيرات');
  String get locationSuggestions => _t('Location suggestions', 'اقتراحات الأماكن');
  String get betterNearby => _t('Better nearby recommendations', 'اقتراحات أفضل بالقرب منك');
  String get darkTheme => _t('Dark theme', 'الوضع الداكن');
  String get useDarkColors => _t('Use dark colors across the app', 'استخدام الألوان الداكنة في التطبيق');
  String get appLanguage => _t('App language', 'لغة التطبيق');
  String get englishUS => _t('English (US)', 'الإنجليزية (US)');
  String get themeChanged => _t('Theme updated', 'تم تحديث المظهر');
  String get languageChanged => _t('Language updated', 'تم تحديث اللغة');
  String get logOut => _t('Log out', 'تسجيل الخروج');
  String get signedOut => _t('Signed out safely', 'تم تسجيل الخروج بأمان');
  String get editProfile => _t('Edit profile', 'تعديل الملف');
  String get profileSettings => _t('Profile settings', 'إعدادات الملف');
  String get logoutConfirmTitle => _t('Log out?', 'تسجيل الخروج؟');
  String get logoutConfirmBody => _t(
        'You can sign back in anytime with your phone number.',
        'يمكنك العودة في أي وقت برقم هاتفك.',
      );
  String get changeProfileImage => _t('Choose a profile photo', 'اختر صورة الملف');
  String get saveChanges => _t('Save changes', 'حفظ التغييرات');
  String get profileUpdated => _t('Profile updated', 'تم تحديث الملف');
  String get deleteAccount => _t('Delete account', 'حذف الحساب');
  String get deleteAccountTitle => _t('Delete account?', 'حذف الحساب؟');
  String get deleteAccountBody => _t(
        'This will remove your account from this device. You can create a new one anytime.',
        'سيتم حذف حسابك من هذا الجهاز. يمكنك إنشاء حساب جديد في أي وقت.',
      );
  String get accountDeleted => _t('Account deleted', 'تم حذف الحساب');
  String get aboutDeveloper => _t('About Developer', 'عن المطوّر');
  String get developerName => _t('Mohamed Mohamed Salah', 'محمد محمد صلاح');
  String get developerInitials => _t('MS', 'مس');
  String get demoShowUpRate => _t('86%', '٨٦٪');
  String get developerTitle => _t('Full-Stack Mobile App Developer', 'مطوّر تطبيقات موبايل متكامل');
  String get developerTagline => _t(
        'Building complete mobile experiences from frontend to backend.',
        'بناء تجارب موبايل كاملة من الواجهة إلى الخادم.',
      );
  String get developerDescription => _t(
        'Yalla 5roga is designed and developed by Mohamed Salah, a Full-Stack Mobile App Developer focused on building modern mobile applications, robust backend APIs, and scalable database systems.',
        'يلا خروجة صمّمها وطوّرها محمد صلاح، مطوّر تطبيقات موبايل متكامل يركّز على بناء تطبيقات حديثة وواجهات برمجية قوية وأنظمة قواعد بيانات قابلة للتوسّع.',
      );
  String get developerShortDescription => _t(
        'Yalla 5roga is designed and developed by Mohamed Salah, a Flutter Developer focused on building modern mobile applications and scalable backend systems.',
        'يلا خروجة صمّمها وطوّرها محمد صلاح، مطوّر فلاتر يركّز على بناء تطبيقات موبايل حديثة وأنظمة خلفية قابلة للتوسّع.',
      );
  String get github => _t('GitHub', 'GitHub');
  String get viewMyProjects => _t('View my projects', 'عرض مشاريعي');
  String get portfolio => _t('Portfolio', 'معرض الأعمال');
  String get viewMyPortfolio => _t('View my portfolio', 'عرض معرض أعمالي');
  String get contactDeveloper => _t('Contact Developer', 'تواصل مع المطوّر');
  String get getInTouch => _t('Get in touch', 'تواصل معي');
  String get couldNotOpenLink => _t('Could not open this link', 'تعذّر فتح هذا الرابط');

  // --- Images ---
  String get uploadPhoto => _t('Upload photo from device', 'رفع صورة من الجهاز');
  String get chooseFromGallery => _t('Choose from gallery', 'اختيار من المعرض');
  String get takePhoto => _t('Take a photo', 'التقاط صورة');
}

class _L10nDelegate extends LocalizationsDelegate<L10n> {
  const _L10nDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<L10n> load(Locale locale) async => L10n(locale);

  @override
  bool shouldReload(_L10nDelegate old) => false;
}
