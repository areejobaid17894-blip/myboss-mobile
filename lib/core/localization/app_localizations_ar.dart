// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'my boss app';

  @override
  String get signInTitle => 'سجّل الدخول ببريدك الإلكتروني';

  @override
  String get signInSubtitle =>
      'استخدم البريد الذي أُرسلت إليه الدعوة. سنرسل لك رمزاً من 6 أرقام — بدون كلمة مرور.';

  @override
  String get signInFooterHelp => 'لم تصلك دعوة؟ تواصل مع فريق المبادرة.';

  @override
  String get demoAccountLabel => 'حساب تجريبي';

  @override
  String get demoAccountHint => 'يُعبأ الرمز تلقائياً في الوضع التجريبي.';

  @override
  String get otherTestAccountsTitle => 'حسابات أخرى للاختبار';

  @override
  String get otherTestAccountsDescription =>
      'اضغط أي بريد @orange.com أدناه لتجربة ملف شخصي مختلف:';

  @override
  String get sendMyCode => 'أرسل الرمز';

  @override
  String get emailHint => 'demo@orange.com';

  @override
  String get contactEmail => 'theboss@company.com';

  @override
  String get otpTitle => 'تحقق من بريدك';

  @override
  String otpSubtitle(String email) {
    return 'أرسلنا رمزاً إلى $email. ينتهي خلال 10 دقائق.';
  }

  @override
  String get verifyAndContinue => 'تحقق وتابع';

  @override
  String get termsTitle => 'الشروط والأحكام';

  @override
  String get termsBody =>
      'باستخدامك تطبيق my boss app فإنك توافق على الالتزام بسياسات Orange في العمل الميداني، وحماية بيانات العملاء والزملاء، واستخدام التطبيق فقط لأعمال المبادرة المصرح بها، والامتثال لإرشادات الفريق والاستبيانات الصادرة عن فريق المبادرة.';

  @override
  String get termsAcceptLabel => 'أوافق على جميع الشروط والأحكام';

  @override
  String get termsContinue => 'متابعة';

  @override
  String resendCodeIn(String time) {
    return 'إعادة الإرسال خلال $time';
  }

  @override
  String get resendCode => 'إعادة إرسال الرمز';

  @override
  String get retry => 'حاول مرة أخرى';

  @override
  String get language => 'اللغة';

  @override
  String get back => 'رجوع';

  @override
  String get continueLabel => 'متابعة';

  @override
  String get close => 'إغلاق';

  @override
  String get next => 'التالي';

  @override
  String get submit => 'إرسال';

  @override
  String get done => 'تم';

  @override
  String showMore(int count) {
    return 'عرض المزيد ($count)';
  }

  @override
  String get showLess => 'عرض أقل';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navReports => 'التقارير';

  @override
  String get navMySquad => 'فريقي';

  @override
  String get navGallery => 'المعرض';

  @override
  String get navProfile => 'الملف الشخصي';

  @override
  String homeWelcome(String name) {
    return 'مرحباً $name 👋';
  }

  @override
  String get serviceTemplates => 'قوالب الخدمة';

  @override
  String get serviceTemplatesDesc =>
      'اختر قالباً لبدء زيارة عميل أو جلسة ملاحظات.';

  @override
  String get noSquadYet =>
      'لست في فريق بعد. اضغط لإنشاء فريق أو الانضمام لواحد.';

  @override
  String get surveyProgress => 'تقدم الاستبيان';

  @override
  String get governorateInsights => 'رؤى المحافظة';

  @override
  String get responses => 'الردود';

  @override
  String get avgSatisfaction => 'متوسط الرضا';

  @override
  String get perHour => 'في الساعة';

  @override
  String get segmentConsumer => 'مستهلك';

  @override
  String get segmentBusiness => 'أعمال';

  @override
  String get segmentEmployee => 'موظف';

  @override
  String get profileTitle => 'الملف الشخصي';

  @override
  String get vestSize => 'مقاس السترة';

  @override
  String get openToTravel => 'متاح للتنقل';

  @override
  String get openToTravelDesc => 'مستعد للعمل خارج محافظتك';

  @override
  String get saveChanges => 'حفظ التغييرات';

  @override
  String profileEditsRemaining(int count) {
    return '$count تعديلات متبقية للملف';
  }

  @override
  String get profileEditsRemainingOne => 'تعديل واحد متبقٍ للملف';

  @override
  String get noProfileEditsRemaining => 'لا توجد تعديلات متبقية للملف';

  @override
  String get employeeFeedbackSurvey => 'استبيان ملاحظات الموظف';

  @override
  String get reports => 'التقارير';

  @override
  String get logOut => 'تسجيل الخروج';

  @override
  String get logOutConfirmTitle => 'تسجيل الخروج؟';

  @override
  String get logOutConfirmMessage =>
      'ستحتاج لتسجيل الدخول مرة أخرى للوصول إلى التطبيق.';

  @override
  String get logOutConfirmYes => 'تسجيل الخروج';

  @override
  String get logOutConfirmNo => 'إلغاء';

  @override
  String get loadProfileError => 'تعذر تحميل الملف الشخصي.';

  @override
  String get vestSizeTitle => 'اختر مقاس سترتك';

  @override
  String get vestSizeSubtitle =>
      'تتضمن حقيبتك سترة الفريق وقبعة وهدايا للعملاء الذين ستزورهم.';

  @override
  String get vestSizeHint =>
      'المقاسات مطابقة للمقاس الفعلي. تُسلَّم الحقائب في مبناك صباح يوم الفعالية.';

  @override
  String get step1Tag => 'الخطوة 1 من 3 · حقيبتك';

  @override
  String get step2Tag => 'الخطوة 2 من 3 · مقر العمل';

  @override
  String get step3Tag => 'الخطوة 3 من 3 · فريقك';

  @override
  String get buildingTitle => 'أين تعمل؟';

  @override
  String get buildingSubtitle =>
      'نستخدم هذا لوضع فريقك بالقرب منك قدر الإمكان.';

  @override
  String get selectBuilding => 'اختر مبناك';

  @override
  String get governorate => 'المحافظة';

  @override
  String get finishSetup => 'إنهاء الإعداد';

  @override
  String get formYourSquad => 'خمسة أشخاص.\nمهمة واحدة.';

  @override
  String get formYourSquadDesc =>
      'كل فريق يضم 5 أعضاء بالضبط. قُده أو انضم إلى زملائك.';

  @override
  String squadsFormedProgress(int formed, int max) {
    return '$formed / $max فريقاً حتى الآن';
  }

  @override
  String get takeMeHome => 'إلى الرئيسية →';

  @override
  String get destinationIncomingTitle => 'الوجهة قادمة.';

  @override
  String get destinationIncomingBody =>
      'ستظهر مواقع زيارة فريقك هنا قريباً — سنُعلمك فور تحديدها.';

  @override
  String get addCustomer => '＋ إضافة عميل';

  @override
  String get addCustomerDesc => 'يفتح استبيان الزيارة';

  @override
  String get travelPrefTitle => 'رائع! أي محافظات تهمك؟';

  @override
  String get totalSquads => 'إجمالي الفرق';

  @override
  String get slotsLeft => 'أماكن متبقية';

  @override
  String get maxSquads => 'الحد الأقصى';

  @override
  String get createSquad => 'إنشاء فريق';

  @override
  String get createSquadDesc =>
      'ابدأ من جديد، اختر اسماً وشارة، وادعُ الآخرين.';

  @override
  String get createSquadNameTitle => 'سمِّ فريقك';

  @override
  String get createSquadNameDesc =>
      'اختر اسماً مميزاً — يظهر في لوحة المتصدرين للشركة.';

  @override
  String get squadNameHint => 'مثال: صقور الصحراء';

  @override
  String get squadIdAutoGenerated => 'رمز الفريق: يُنشأ تلقائياً';

  @override
  String get createSquadLeaderHint =>
      'إنشاء الفريق يجعلك قائده. ستقبل طلبات الانضمام حتى يكتمل (5/5).';

  @override
  String get findYourSquad => 'ابحث عن فريقك';

  @override
  String get joinSquadDemoHint => 'تجريبي: تُقبل الطلبات تلقائياً بعد لحظات.';

  @override
  String get joinSquad => 'الانضمام لفريق';

  @override
  String get joinSquadDesc => 'تصفح الفرق المفتوحة واطلب الانضمام.';

  @override
  String get joinSquadBrowseAllDesc =>
      'جميع الفرق المفتوحة مدرجة أدناه. رشّح حسب المحافظة أو ابحث بالاسم والرمز.';

  @override
  String get filterByGovernorate => 'تصفية حسب المحافظة';

  @override
  String get filterAllGovernorates => 'الكل';

  @override
  String get clearFilters => 'مسح التصفية';

  @override
  String squadsFilteredCount(int visible, int total) {
    return 'عرض $visible من $total فرق';
  }

  @override
  String get noSquadsAvailable =>
      'لا توجد فرق متاحة حالياً. اسحب للأسفل للتحديث.';

  @override
  String get squadName => 'اسم الفريق';

  @override
  String get pickBadge => 'اختر شارة';

  @override
  String get create => 'إنشاء';

  @override
  String get searchSquads => 'ابحث باسم الفريق أو الرمز';

  @override
  String squadsFoundCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تم العثور على $count فرق',
      one: 'تم العثور على فريق واحد',
    );
    return '$_temp0';
  }

  @override
  String get joinSquadSearchHint =>
      'جرّب البحث عن \"Orange\" أو \"Amman\"، أو اسحب للأسفل لتحديث القائمة.';

  @override
  String get join => 'انضم';

  @override
  String get full => 'مكتمل';

  @override
  String members(int count) {
    return 'الأعضاء ($count/5)';
  }

  @override
  String get leader => 'القائد';

  @override
  String joinRequests(int count) {
    return 'طلبات الانضمام ($count)';
  }

  @override
  String get noJoinRequests => 'لا توجد طلبات انضمام معلقة';

  @override
  String get noSquadTitle => 'لا يوجد فريق بعد';

  @override
  String get noSquadDesc => 'أنشئ أو انضم لفريق لرؤية الأعضاء والتقدم هنا.';

  @override
  String get browseSquads => 'تصفح الفرق';

  @override
  String get squadCreated => 'تم إنشاء الفريق!';

  @override
  String get squadCreatedBody => 'فريقك جاهز. شارك رمز الفريق مع زملائك.';

  @override
  String get requestSent => 'تم إرسال الطلب';

  @override
  String get requestSentBody =>
      'تم إرسال طلب الانضمام. سيراجعه قائد الفريق قريباً.';

  @override
  String get goToMySquad => 'اذهب إلى فريقي';

  @override
  String get goToHome => 'اذهب إلى الرئيسية';

  @override
  String get galleryTitle => 'المعرض';

  @override
  String get upload => 'رفع';

  @override
  String get galleryAddPost => 'إضافة منشور';

  @override
  String get galleryPost => 'نشر';

  @override
  String get galleryCaptionHint => 'اكتب تعليقاً على لحظتك الميدانية…';

  @override
  String get gallerySkipCaption => 'تخطي';

  @override
  String get galleryLockedDesc =>
      'انضم إلى فريق لرفع الصور ومشاركة المنشورات مع فريقك.';

  @override
  String get galleryUploadHint =>
      'استخدم بطاقة مشاركة صورة أدناه لإضافة صورة مع تعليق اختياري.';

  @override
  String get galleryViewOnlyHint =>
      'تصفح لحظات الفريق. انضم لفريق لرفع منشوراتك.';

  @override
  String get galleryEmptyCanPost =>
      'لا توجد منشورات بعد. اضغط مشاركة صورة لإضافة أول لحظة ميدانية.';

  @override
  String get galleryPostSuccess => 'تمت مشاركة الصورة مع فريقك!';

  @override
  String get gallerySharePhotoTitle => 'شارك لحظة ميدانية';

  @override
  String gallerySharePhotoDesc(String squadName) {
    return 'اختر صورة من معرضك، أضف تعليقاً، وشاركها مع $squadName.';
  }

  @override
  String get gallerySharePhotoButton => 'مشاركة صورة';

  @override
  String get gallerySharePost => 'مشاركة';

  @override
  String get galleryShareCopied =>
      'تم نسخ التعليق — الصقه في تطبيقك المفضل للمشاركة.';

  @override
  String get galleryShareDefault =>
      'لحظة ميدانية رائعة مع #theBOSS! #Orange #MCMB2026';

  @override
  String gallerySquadBanner(String squadName) {
    return 'النشر كعضو في $squadName';
  }

  @override
  String get fieldMoments => 'لحظات ميدانية';

  @override
  String get noPhotosYet => 'لا توجد صور بعد. ارفع أول لحظة ميدانية.';

  @override
  String get maxUploadsReached => 'تم الوصول للحد الأقصى للرفع';

  @override
  String get employeeFeedback => 'ملاحظات الموظف';

  @override
  String get customerSurvey => 'استبيان العميل';

  @override
  String questionProgress(int current, int total) {
    return 'السؤال $current من $total';
  }

  @override
  String get optional => 'اختياري';

  @override
  String get typeAnswer => 'اكتب إجابتك…';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get nationalId => 'رقم الهوية';

  @override
  String get signHere => 'وقّع هنا';

  @override
  String get clear => 'مسح';

  @override
  String get reportsTitle => 'التقارير';

  @override
  String get reportsSquadRequiredTitle => 'التقارير تتطلب فريقاً';

  @override
  String get reportsSquadRequiredDesc =>
      'انضم أو أنشئ فريقاً لعرض تقارير الاستبيانات ورؤى الأداء.';

  @override
  String get scopeCompany => 'الشركة';

  @override
  String get scopeMySquad => 'فريقي';

  @override
  String get scopeMyGovernorate => 'محافظتي';

  @override
  String get totalResponses => 'إجمالي الردود';

  @override
  String get surveysPerHour => 'استبيانات/ساعة';

  @override
  String get topPriorities => 'أهم الأولويات';

  @override
  String get noPriorityData => 'لا توجد بيانات أولويات بعد.';

  @override
  String get demoOtpHint => 'وضع تجريبي: تم تعبئة الرمز تلقائياً';

  @override
  String get noSurveyQuestions => 'لا توجد أسئلة متاحة لهذا الاستبيان.';

  @override
  String get surveySuccessTitle => 'شكراً لك!';

  @override
  String get surveySuccessBody => 'تم إرسال إجابة الاستبيان بنجاح.';

  @override
  String get errorGeneric => 'حدث خطأ ما. يرجى المحاولة مرة أخرى.';

  @override
  String get errorNetwork => 'خطأ في الشبكة. يرجى التحقق من اتصالك.';

  @override
  String get errorUnauthorized =>
      'يلزم تسجيل الدخول. يرجى تسجيل الدخول مرة أخرى.';

  @override
  String get errorForbidden => 'غير مسموح لك بتنفيذ هذا الإجراء.';

  @override
  String get errorNotFound => 'العنصر المطلوب غير موجود.';

  @override
  String get errorValidation => 'بعض الحقول غير صالحة. يرجى مراجعة المدخلات.';

  @override
  String get errorInvalidNationalId => 'رقم الهوية غير صالح.';

  @override
  String get errorInvalidPhone => 'رقم الهاتف غير صالح.';

  @override
  String get errorNotEligible => 'أنت غير مؤهل للمشاركة.';

  @override
  String get errorInvalidDomain => 'يرجى استخدام بريدك الإلكتروني @orange.com.';

  @override
  String get errorAuthInvalidOtp => 'رمز التحقق غير صالح أو منتهي الصلاحية.';

  @override
  String get errorAuthSessionInvalid =>
      'جلستك غير صالحة. يرجى تسجيل الدخول مرة أخرى.';

  @override
  String get errorAuthSessionExpired =>
      'انتهت جلستك. يرجى تسجيل الدخول مرة أخرى.';

  @override
  String get errorUserNotFound => 'المستخدم غير موجود.';

  @override
  String get errorProfileEditLimit =>
      'تم الوصول إلى الحد الأقصى لتعديل الملف الشخصي.';

  @override
  String get errorConfigNotFound => 'الإعداد غير موجود.';

  @override
  String get errorBuildingNotFound => 'المبنى غير موجود.';

  @override
  String get errorSquadNotFound => 'الفريق غير موجود.';

  @override
  String get errorSquadLimitReached =>
      'تم الوصول إلى الحد الأقصى للفرق. يرجى الانضمام إلى فريق موجود.';

  @override
  String get errorSquadNameTaken => 'اسم الفريق مستخدم بالفعل.';

  @override
  String get errorSquadAlreadyMember => 'أنت بالفعل في فريق.';

  @override
  String get errorSquadFull => 'هذا الفريق مكتمل.';

  @override
  String get errorSquadJoinRequestExists => 'تم إرسال طلب الانضمام مسبقاً.';

  @override
  String get errorSquadJoinRequestNotFound => 'طلب الانضمام غير موجود.';

  @override
  String get errorSquadLeaderOnly => 'يمكن لقائد الفريق فقط تنفيذ هذا الإجراء.';

  @override
  String get errorSquadLeaderCannotLeave =>
      'يجب نقل القيادة قبل مغادرة الفريق.';

  @override
  String get errorSquadLeaderCannotRemoveSelf =>
      'يجب نقل القيادة قبل إزالة نفسك.';

  @override
  String get errorSquadMemberNotFound => 'العضو غير موجود في هذا الفريق.';

  @override
  String get errorSurveyNotFound => 'الاستبيان غير موجود.';

  @override
  String get errorSurveySegmentNotFound => 'لا يوجد استبيان نشط لهذا القطاع.';

  @override
  String get errorGalleryUploadLimit =>
      'تم الوصول إلى الحد الأقصى للرفع لهذا الموظف.';

  @override
  String get errorBackendUnavailable =>
      'تعذر الوصول إلى الخادم. تأكد من تشغيل خدمات my boss app وأن المنفذ 3001 متاح.';

  @override
  String get errorInvalidOtp => 'رمز التحقق غير صالح أو منتهي الصلاحية';

  @override
  String get noSquadsFound => 'لم يتم العثور على فرق. جرّب بحثاً مختلفاً.';

  @override
  String uploadedCount(int current, int max) {
    return '$current/$max مرفوع';
  }

  @override
  String squadTarget(int count) {
    return 'الهدف: $count استبيان';
  }

  @override
  String get noSquadWaitingDesc =>
      'إذا أرسلت طلب انضمام للتو، فهو بانتظار موافقة قائد الفريق. اسحب للتحديث بعد قبولك.';

  @override
  String get servicesLockedTitle => 'الخدمات مقفلة';

  @override
  String get servicesLockedDesc =>
      'انضم إلى فريق لفتح الاستبيانات وخدمات الميدان. يجب أن تكون جزءاً من مجموعة قبل تعبئة الاستبيانات.';

  @override
  String get pendingJoinRequestTitle => 'طلب انضمام قيد الانتظار';

  @override
  String pendingJoinRequestBody(String squadName) {
    return 'طلبك للانضمام إلى \"$squadName\" بانتظار موافقة قائد الفريق.';
  }

  @override
  String get pendingJoinRequestHubNote =>
      'لديك طلب انضمام معلق بالفعل. انتظر الموافقة أو حدّث حالتك.';

  @override
  String get leaveSquad => 'مغادرة الفريق';

  @override
  String get leaveSquadConfirmTitle => 'مغادرة هذا الفريق؟';

  @override
  String get leaveSquadConfirmMessage =>
      'ستفقد الوصول إلى استبيانات الفريق والدردشة والمعرض حتى تنضم لفريق آخر.';

  @override
  String get leaveSquadConfirmYes => 'مغادرة الفريق';

  @override
  String get transferLeaderTitle => 'اختر قائد الفريق الجديد';

  @override
  String get transferLeaderMessage =>
      'قبل المغادرة، عيّن عضواً آخر قائداً للفريق.';

  @override
  String get transferLeaderConfirm => 'نقل القيادة والمغادرة';

  @override
  String get transferLeaderNoMembers =>
      'أضف عضواً واحداً على الأقل قبل نقل القيادة والمغادرة.';

  @override
  String get removeMember => 'إزالة';

  @override
  String get removeMemberConfirmTitle => 'إزالة العضو؟';

  @override
  String removeMemberConfirmMessage(String memberName) {
    return 'إزالة $memberName من هذا الفريق؟ سيفقد الوصول إلى استبيانات الفريق والدردشة والمعرض.';
  }

  @override
  String get removeMemberConfirmYes => 'إزالة العضو';

  @override
  String vestSizeEditWindow(String start, String end) {
    return 'تعديل مقاس السترة التالي: $start – $end';
  }

  @override
  String get vestSizeChangePolicyTitle => 'سياسة تغيير مقاس السترة';

  @override
  String vestSizeChangePolicyNote(String start, String end) {
    return 'يمكنك تغيير مقاس السترة بين $start و $end. بعد $end، سيُحظر تغيير المقاس حتى يفتح المسؤول نافذة جديدة.';
  }

  @override
  String get vestSizeChangePolicyNoWindow =>
      'تتطلب تغييرات مقاس السترة الإضافية نافذة تواريخ يحددها المسؤول. تواصل مع فريق المبادرة إذا احتجت تحديث مقاسك.';

  @override
  String get vestSizeEditOutsideWindow =>
      'يمكن تغيير مقاس السترة فقط خلال فترة التعديل المحددة.';

  @override
  String get errorProfileEditOutsideWindow =>
      'يمكن تغيير مقاس السترة فقط خلال فترة التعديل المحددة.';

  @override
  String get refresh => 'تحديث';

  @override
  String get notLikely => 'غير محتمل';

  @override
  String get veryLikely => 'محتمل جداً';

  @override
  String squadCreatedBodyNamed(String name, String code) {
    return '\"$name\" جاهز. شارك رمز الفريق $code مع زملائك لدعوتهم.';
  }

  @override
  String get mySquadTitle => 'فريقي';

  @override
  String get liveChat => 'دردشة مباشرة';

  @override
  String get liveChatTitle => 'دردشة مباشرة';

  @override
  String get liveChatDesc => 'راسل زملاء فريقك فقط.';

  @override
  String get liveChatUnavailable =>
      'الدردشة المباشرة غير مهيأة بعد. راسل theboss@company.com للمساعدة.';

  @override
  String get liveChatBanner => 'اختر زميلاً في الفريق لمراسلته.';

  @override
  String get chatSelectRecipient => 'الرسالة إلى';

  @override
  String get chatSelectRecipientHint => 'اختر زميلاً قبل إرسال الرسالة.';

  @override
  String get chatSelectRecipientPlaceholder => 'اختر من تريد مراسلته…';

  @override
  String get chatNoContactSelected => 'اختر المستلم أولاً';

  @override
  String get chatTapToMessage =>
      'استخدم القائمة أعلاه، أو اضغط على أحد جهات الاتصال أدناه لبدء المحادثة.';

  @override
  String get chatQuickPick => 'اختيار سريع';

  @override
  String get chatSupportSubtitle => 'مكتب دعم الفعالية';

  @override
  String get chatTeammateSubtitle => 'زميل في الفريق';

  @override
  String get chatChooseContact => 'من تريد مراسلته؟';

  @override
  String get chatChooseContactDesc =>
      'اختر زميلاً في الفريق. انضم لفريق لرؤية زملائك.';

  @override
  String get chatSquadLockedTitle => 'دردشة الفريق فقط';

  @override
  String get chatSquadLockedDesc =>
      'انضم إلى فريق لمراسلة زملائك. الدردشة متاحة فقط لأعضاء الفريق.';

  @override
  String chatSquadOnlyHint(String squadName) {
    return 'دردشة الفريق · $squadName — مراسلة الزملاء فقط.';
  }

  @override
  String get chatSquadMembersOnly =>
      'يظهر هنا أعضاء الفريق فقط. الدعم غير متاح في هذه الدردشة.';

  @override
  String get chatNoTeammatesYet =>
      'لا يوجد زملاء آخرون في فريقك بعد. ادعُ زملاءك برمز الفريق.';

  @override
  String chatDirectBanner(String name) {
    return 'محادثة مباشرة مع $name. تُحدَّث الرسائل مباشرة.';
  }

  @override
  String get chatLoading => 'جاري الاتصال…';

  @override
  String get chatEmptyHint => 'أرسل رسالة لبدء المحادثة.';

  @override
  String chatEmptyHintDirect(String name) {
    return 'قل مرحباً لـ $name. سيتم تسليم رسالتك فوراً.';
  }

  @override
  String get noSquadUnlockTitle => 'انضم لفريق للفتح';

  @override
  String get noSquadUnlockDesc =>
      'أنشئ أو انضم لفريق لاستخدام الدردشة ومشاركة الصور وتعبئة الاستبيانات. يمكنك تصفح المعرض وتعديل ملفك الشخصي.';

  @override
  String get noSquadLockedFeaturesTitle => 'يُفتح عند الانضمام:';

  @override
  String get noSquadFeatureChat => 'مراسلة الزملاء';

  @override
  String get noSquadFeatureGalleryUpload => 'مشاركة صور ميدانية';

  @override
  String get noSquadFeatureSurveys => 'استبيانات وخدمات الميدان';

  @override
  String get continueWithoutSquad => 'المتابعة بدون فريق';

  @override
  String get continueWithoutSquadHint =>
      'تصفح المعرض والتقارير والملف. انضم لفريق في أي وقت لفتح الدردشة والاستبيانات والرفع.';

  @override
  String get noSquadBrowseGalleryHint =>
      'وضع تصفح فقط — انضم لفريق لمشاركة صورك.';

  @override
  String get noSquadChatLockedHint => 'انضم لفريق لمراسلة الزملاء';

  @override
  String get noSquadSurveyLockedHint => 'انضم لفريق لتعبئة استبيانات الميدان';

  @override
  String get chatTypeMessage => 'اكتب رسالة…';
}
