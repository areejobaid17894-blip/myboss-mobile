import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'localization/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'my boss app'**
  String get appTitle;

  /// No description provided for @signInTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with your work email'**
  String get signInTitle;

  /// No description provided for @signInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your Orange work email. We\'ll send you a 6-digit code — no password needed.'**
  String get signInSubtitle;

  /// No description provided for @signInFooterHelp.
  ///
  /// In en, this message translates to:
  /// **'Need help signing in? Contact the initiative team.'**
  String get signInFooterHelp;

  /// No description provided for @demoAccountLabel.
  ///
  /// In en, this message translates to:
  /// **'Demo account'**
  String get demoAccountLabel;

  /// No description provided for @demoAccountHint.
  ///
  /// In en, this message translates to:
  /// **'OTP auto-fills in demo mode.'**
  String get demoAccountHint;

  /// No description provided for @otherTestAccountsTitle.
  ///
  /// In en, this message translates to:
  /// **'Other accounts for testing'**
  String get otherTestAccountsTitle;

  /// No description provided for @otherTestAccountsDescription.
  ///
  /// In en, this message translates to:
  /// **'Tap any eligible @orange.com email below to try a different profile:'**
  String get otherTestAccountsDescription;

  /// No description provided for @sendMyCode.
  ///
  /// In en, this message translates to:
  /// **'Send my code'**
  String get sendMyCode;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'demo@orange.com'**
  String get emailHint;

  /// No description provided for @contactEmail.
  ///
  /// In en, this message translates to:
  /// **'theboss@company.com'**
  String get contactEmail;

  /// No description provided for @otpTitle.
  ///
  /// In en, this message translates to:
  /// **'Check your inbox'**
  String get otpTitle;

  /// No description provided for @otpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We sent a code to {email}. It expires in 10 minutes.'**
  String otpSubtitle(String email);

  /// No description provided for @verifyAndContinue.
  ///
  /// In en, this message translates to:
  /// **'Verify & continue'**
  String get verifyAndContinue;

  /// No description provided for @termsTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms & conditions'**
  String get termsTitle;

  /// No description provided for @termsBody.
  ///
  /// In en, this message translates to:
  /// **'By using my boss app you agree to follow Orange workplace policies during field activities, protect customer and colleague data, use the app only for authorized initiative work, and comply with squad and survey guidelines issued by the initiative team.'**
  String get termsBody;

  /// No description provided for @termsAcceptLabel.
  ///
  /// In en, this message translates to:
  /// **'I accept all terms and conditions'**
  String get termsAcceptLabel;

  /// No description provided for @termsContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get termsContinue;

  /// No description provided for @resendCodeIn.
  ///
  /// In en, this message translates to:
  /// **'Resend code in {time}'**
  String resendCodeIn(String time);

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get resendCode;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @showMore.
  ///
  /// In en, this message translates to:
  /// **'Show more ({count})'**
  String showMore(int count);

  /// No description provided for @showLess.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get showLess;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get navReports;

  /// No description provided for @navMySquad.
  ///
  /// In en, this message translates to:
  /// **'My Squad'**
  String get navMySquad;

  /// No description provided for @navGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get navGallery;

  /// No description provided for @navNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get navNotifications;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @notificationsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get notificationsEmptyTitle;

  /// No description provided for @notificationsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Admin announcements and squad alerts will appear here.'**
  String get notificationsEmptyBody;

  /// No description provided for @notificationsEnableTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications'**
  String get notificationsEnableTitle;

  /// No description provided for @notificationsEnableBody.
  ///
  /// In en, this message translates to:
  /// **'Turn on notifications to get live alerts when the initiative team sends updates — even when the app is in the background.'**
  String get notificationsEnableBody;

  /// No description provided for @notificationsEnableAction.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get notificationsEnableAction;

  /// No description provided for @notificationsEnableLater.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notificationsEnableLater;

  /// No description provided for @homeWelcome.
  ///
  /// In en, this message translates to:
  /// **'Hey {name} 👋'**
  String homeWelcome(String name);

  /// No description provided for @serviceTemplates.
  ///
  /// In en, this message translates to:
  /// **'Service templates'**
  String get serviceTemplates;

  /// No description provided for @serviceTemplatesDesc.
  ///
  /// In en, this message translates to:
  /// **'Pick a template to start a customer visit or feedback session.'**
  String get serviceTemplatesDesc;

  /// No description provided for @noSquadYet.
  ///
  /// In en, this message translates to:
  /// **'You\'re not in a squad yet. Tap to create or join one.'**
  String get noSquadYet;

  /// No description provided for @surveyProgress.
  ///
  /// In en, this message translates to:
  /// **'Survey progress'**
  String get surveyProgress;

  /// No description provided for @governorateInsights.
  ///
  /// In en, this message translates to:
  /// **'Governorate insights'**
  String get governorateInsights;

  /// No description provided for @responses.
  ///
  /// In en, this message translates to:
  /// **'Responses'**
  String get responses;

  /// No description provided for @avgSatisfaction.
  ///
  /// In en, this message translates to:
  /// **'Avg. satisfaction'**
  String get avgSatisfaction;

  /// No description provided for @perHour.
  ///
  /// In en, this message translates to:
  /// **'Per hour'**
  String get perHour;

  /// No description provided for @segmentConsumer.
  ///
  /// In en, this message translates to:
  /// **'Consumer'**
  String get segmentConsumer;

  /// No description provided for @segmentBusiness.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get segmentBusiness;

  /// No description provided for @segmentEmployee.
  ///
  /// In en, this message translates to:
  /// **'Employee'**
  String get segmentEmployee;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @vestSize.
  ///
  /// In en, this message translates to:
  /// **'Vest size'**
  String get vestSize;

  /// No description provided for @openToTravel.
  ///
  /// In en, this message translates to:
  /// **'Open to travel'**
  String get openToTravel;

  /// No description provided for @openToTravelDesc.
  ///
  /// In en, this message translates to:
  /// **'Willing to be assigned outside your governorate'**
  String get openToTravelDesc;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @profileEditsRemaining.
  ///
  /// In en, this message translates to:
  /// **'{count} profile edits remaining'**
  String profileEditsRemaining(int count);

  /// No description provided for @profileEditsRemainingOne.
  ///
  /// In en, this message translates to:
  /// **'1 profile edit remaining'**
  String get profileEditsRemainingOne;

  /// No description provided for @noProfileEditsRemaining.
  ///
  /// In en, this message translates to:
  /// **'No profile edits remaining'**
  String get noProfileEditsRemaining;

  /// No description provided for @employeeFeedbackSurvey.
  ///
  /// In en, this message translates to:
  /// **'Employee feedback survey'**
  String get employeeFeedbackSurvey;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOut;

  /// No description provided for @logOutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Log out?'**
  String get logOutConfirmTitle;

  /// No description provided for @logOutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'You will need to sign in again to access the app.'**
  String get logOutConfirmMessage;

  /// No description provided for @logOutConfirmYes.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOutConfirmYes;

  /// No description provided for @logOutConfirmNo.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get logOutConfirmNo;

  /// No description provided for @loadProfileError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load profile.'**
  String get loadProfileError;

  /// No description provided for @vestSizeTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick your vest size'**
  String get vestSizeTitle;

  /// No description provided for @vestSizeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your tool-kit includes a squad vest, a cap, and giveaways for the customers you\'ll visit.'**
  String get vestSizeSubtitle;

  /// No description provided for @vestSizeHint.
  ///
  /// In en, this message translates to:
  /// **'Sizes run true to fit. Kits are handed out at your building on the morning of the event.'**
  String get vestSizeHint;

  /// No description provided for @step1Tag.
  ///
  /// In en, this message translates to:
  /// **'STEP 1 OF 3 · YOUR KIT'**
  String get step1Tag;

  /// No description provided for @step2Tag.
  ///
  /// In en, this message translates to:
  /// **'STEP 2 OF 3 · HOME BASE'**
  String get step2Tag;

  /// No description provided for @step3Tag.
  ///
  /// In en, this message translates to:
  /// **'STEP 3 OF 3 · YOUR SQUAD'**
  String get step3Tag;

  /// No description provided for @buildingTitle.
  ///
  /// In en, this message translates to:
  /// **'Where do you work?'**
  String get buildingTitle;

  /// No description provided for @buildingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We use this to place your squad near you whenever possible.'**
  String get buildingSubtitle;

  /// No description provided for @selectBuilding.
  ///
  /// In en, this message translates to:
  /// **'Select your building'**
  String get selectBuilding;

  /// No description provided for @governorate.
  ///
  /// In en, this message translates to:
  /// **'Governorate'**
  String get governorate;

  /// No description provided for @finishSetup.
  ///
  /// In en, this message translates to:
  /// **'Finish setup'**
  String get finishSetup;

  /// No description provided for @formYourSquad.
  ///
  /// In en, this message translates to:
  /// **'Five people.\nOne mission.'**
  String get formYourSquad;

  /// No description provided for @formYourSquadDesc.
  ///
  /// In en, this message translates to:
  /// **'Every squad has exactly 5 members. Lead one, or join colleagues who\'ve already started.'**
  String get formYourSquadDesc;

  /// No description provided for @squadsFormedProgress.
  ///
  /// In en, this message translates to:
  /// **'{formed} / {max} squads formed so far'**
  String squadsFormedProgress(int formed, int max);

  /// No description provided for @takeMeHome.
  ///
  /// In en, this message translates to:
  /// **'Take me home →'**
  String get takeMeHome;

  /// No description provided for @destinationIncomingTitle.
  ///
  /// In en, this message translates to:
  /// **'Destination incoming.'**
  String get destinationIncomingTitle;

  /// No description provided for @destinationIncomingBody.
  ///
  /// In en, this message translates to:
  /// **'Your squad\'s visit locations will land here soon — we\'ll ping you the moment they do.'**
  String get destinationIncomingBody;

  /// No description provided for @addCustomer.
  ///
  /// In en, this message translates to:
  /// **'＋ Add a customer'**
  String get addCustomer;

  /// No description provided for @addCustomerDesc.
  ///
  /// In en, this message translates to:
  /// **'Opens the visit survey'**
  String get addCustomerDesc;

  /// No description provided for @travelPrefTitle.
  ///
  /// In en, this message translates to:
  /// **'GREAT! WHICH GOVERNORATES INTEREST YOU?'**
  String get travelPrefTitle;

  /// No description provided for @totalSquads.
  ///
  /// In en, this message translates to:
  /// **'Total squads'**
  String get totalSquads;

  /// No description provided for @slotsLeft.
  ///
  /// In en, this message translates to:
  /// **'Slots left'**
  String get slotsLeft;

  /// No description provided for @maxSquads.
  ///
  /// In en, this message translates to:
  /// **'Max squads'**
  String get maxSquads;

  /// No description provided for @createSquad.
  ///
  /// In en, this message translates to:
  /// **'Create a squad'**
  String get createSquad;

  /// No description provided for @createSquadDesc.
  ///
  /// In en, this message translates to:
  /// **'Start fresh, pick a name and badge, and invite others to join you.'**
  String get createSquadDesc;

  /// No description provided for @createSquadNameTitle.
  ///
  /// In en, this message translates to:
  /// **'Name your squad'**
  String get createSquadNameTitle;

  /// No description provided for @createSquadNameDesc.
  ///
  /// In en, this message translates to:
  /// **'Make it memorable — it shows up on the leaderboard for the whole company.'**
  String get createSquadNameDesc;

  /// No description provided for @squadNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Desert Falcons'**
  String get squadNameHint;

  /// No description provided for @squadIdAutoGenerated.
  ///
  /// In en, this message translates to:
  /// **'Squad ID: auto-generated on create'**
  String get squadIdAutoGenerated;

  /// No description provided for @createSquadLeaderHint.
  ///
  /// In en, this message translates to:
  /// **'Creating a squad makes you its leader. You\'ll approve join requests until the squad is full (5/5).'**
  String get createSquadLeaderHint;

  /// No description provided for @findYourSquad.
  ///
  /// In en, this message translates to:
  /// **'Find your squad'**
  String get findYourSquad;

  /// No description provided for @joinSquadDemoHint.
  ///
  /// In en, this message translates to:
  /// **'Demo: requests are auto-accepted after a moment.'**
  String get joinSquadDemoHint;

  /// No description provided for @joinSquad.
  ///
  /// In en, this message translates to:
  /// **'Join a squad'**
  String get joinSquad;

  /// No description provided for @joinSquadDesc.
  ///
  /// In en, this message translates to:
  /// **'Browse open squads and request to join.'**
  String get joinSquadDesc;

  /// No description provided for @joinSquadBrowseAllDesc.
  ///
  /// In en, this message translates to:
  /// **'All open squads are listed below. Filter by governorate or search by name and code.'**
  String get joinSquadBrowseAllDesc;

  /// No description provided for @filterByGovernorate.
  ///
  /// In en, this message translates to:
  /// **'Filter by governorate'**
  String get filterByGovernorate;

  /// No description provided for @filterAllGovernorates.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAllGovernorates;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get clearFilters;

  /// No description provided for @squadsFilteredCount.
  ///
  /// In en, this message translates to:
  /// **'Showing {visible} of {total} squads'**
  String squadsFilteredCount(int visible, int total);

  /// No description provided for @noSquadsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No squads are available right now. Pull down to refresh.'**
  String get noSquadsAvailable;

  /// No description provided for @squadName.
  ///
  /// In en, this message translates to:
  /// **'Squad name'**
  String get squadName;

  /// No description provided for @pickBadge.
  ///
  /// In en, this message translates to:
  /// **'Pick a badge'**
  String get pickBadge;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @searchSquads.
  ///
  /// In en, this message translates to:
  /// **'Search by squad name or code'**
  String get searchSquads;

  /// No description provided for @squadsFoundCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 squad found} other{{count} squads found}}'**
  String squadsFoundCount(int count);

  /// No description provided for @joinSquadSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Try searching \"Orange\" or \"Amman\", or pull down to refresh the list.'**
  String get joinSquadSearchHint;

  /// No description provided for @join.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get join;

  /// No description provided for @full.
  ///
  /// In en, this message translates to:
  /// **'Full'**
  String get full;

  /// No description provided for @members.
  ///
  /// In en, this message translates to:
  /// **'Members ({count}/5)'**
  String members(int count);

  /// No description provided for @leader.
  ///
  /// In en, this message translates to:
  /// **'Leader'**
  String get leader;

  /// No description provided for @joinRequests.
  ///
  /// In en, this message translates to:
  /// **'Join requests ({count})'**
  String joinRequests(int count);

  /// No description provided for @noJoinRequests.
  ///
  /// In en, this message translates to:
  /// **'No pending join requests'**
  String get noJoinRequests;

  /// No description provided for @noSquadTitle.
  ///
  /// In en, this message translates to:
  /// **'No squad yet'**
  String get noSquadTitle;

  /// No description provided for @noSquadDesc.
  ///
  /// In en, this message translates to:
  /// **'Create or join a squad to see members and progress here.'**
  String get noSquadDesc;

  /// No description provided for @browseSquads.
  ///
  /// In en, this message translates to:
  /// **'Browse squads'**
  String get browseSquads;

  /// No description provided for @squadCreated.
  ///
  /// In en, this message translates to:
  /// **'Squad created!'**
  String get squadCreated;

  /// No description provided for @squadCreatedBody.
  ///
  /// In en, this message translates to:
  /// **'Your squad is ready. Share the squad code with teammates.'**
  String get squadCreatedBody;

  /// No description provided for @requestSent.
  ///
  /// In en, this message translates to:
  /// **'Request sent'**
  String get requestSent;

  /// No description provided for @requestSentBody.
  ///
  /// In en, this message translates to:
  /// **'Your join request was sent. The squad leader will review it shortly.'**
  String get requestSentBody;

  /// No description provided for @goToMySquad.
  ///
  /// In en, this message translates to:
  /// **'Go to My Squad'**
  String get goToMySquad;

  /// No description provided for @goToHome.
  ///
  /// In en, this message translates to:
  /// **'Go to Home'**
  String get goToHome;

  /// No description provided for @galleryTitle.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get galleryTitle;

  /// No description provided for @upload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get upload;

  /// No description provided for @galleryAddPost.
  ///
  /// In en, this message translates to:
  /// **'Add post'**
  String get galleryAddPost;

  /// No description provided for @galleryPost.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get galleryPost;

  /// No description provided for @galleryCaptionHint.
  ///
  /// In en, this message translates to:
  /// **'Write a caption for your field moment…'**
  String get galleryCaptionHint;

  /// No description provided for @gallerySkipCaption.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get gallerySkipCaption;

  /// No description provided for @galleryLockedDesc.
  ///
  /// In en, this message translates to:
  /// **'Join a squad to upload photos and share posts with your team.'**
  String get galleryLockedDesc;

  /// No description provided for @galleryUploadHint.
  ///
  /// In en, this message translates to:
  /// **'Use the Share photo card below to add an image with an optional caption.'**
  String get galleryUploadHint;

  /// No description provided for @galleryViewOnlyHint.
  ///
  /// In en, this message translates to:
  /// **'Browse squad field moments. Join a squad to upload your own posts.'**
  String get galleryViewOnlyHint;

  /// No description provided for @galleryEmptyCanPost.
  ///
  /// In en, this message translates to:
  /// **'No posts yet. Tap Share photo to add your first field moment.'**
  String get galleryEmptyCanPost;

  /// No description provided for @galleryPostSuccess.
  ///
  /// In en, this message translates to:
  /// **'Photo shared with your squad!'**
  String get galleryPostSuccess;

  /// No description provided for @gallerySharePhotoTitle.
  ///
  /// In en, this message translates to:
  /// **'Share a field moment'**
  String get gallerySharePhotoTitle;

  /// No description provided for @gallerySharePhotoDesc.
  ///
  /// In en, this message translates to:
  /// **'Pick a photo from your gallery, add a caption, and share it with {squadName}.'**
  String gallerySharePhotoDesc(String squadName);

  /// No description provided for @gallerySharePhotoButton.
  ///
  /// In en, this message translates to:
  /// **'Share photo'**
  String get gallerySharePhotoButton;

  /// No description provided for @gallerySharePost.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get gallerySharePost;

  /// No description provided for @galleryShareCopied.
  ///
  /// In en, this message translates to:
  /// **'Caption copied — paste it in your favorite app to share.'**
  String get galleryShareCopied;

  /// No description provided for @galleryShareDefault.
  ///
  /// In en, this message translates to:
  /// **'Amazing field moment with #theBOSS! #Orange #MCMB2026'**
  String get galleryShareDefault;

  /// No description provided for @gallerySquadBanner.
  ///
  /// In en, this message translates to:
  /// **'Posting as {squadName}'**
  String gallerySquadBanner(String squadName);

  /// No description provided for @fieldMoments.
  ///
  /// In en, this message translates to:
  /// **'Field moments'**
  String get fieldMoments;

  /// No description provided for @noPhotosYet.
  ///
  /// In en, this message translates to:
  /// **'No photos yet. Upload your first field moment.'**
  String get noPhotosYet;

  /// No description provided for @maxUploadsReached.
  ///
  /// In en, this message translates to:
  /// **'Maximum uploads reached'**
  String get maxUploadsReached;

  /// No description provided for @employeeFeedback.
  ///
  /// In en, this message translates to:
  /// **'Employee Feedback'**
  String get employeeFeedback;

  /// No description provided for @customerSurvey.
  ///
  /// In en, this message translates to:
  /// **'Customer Survey'**
  String get customerSurvey;

  /// No description provided for @questionProgress.
  ///
  /// In en, this message translates to:
  /// **'Question {current} of {total}'**
  String questionProgress(int current, int total);

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @typeAnswer.
  ///
  /// In en, this message translates to:
  /// **'Type your answer…'**
  String get typeAnswer;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @nationalId.
  ///
  /// In en, this message translates to:
  /// **'National ID number'**
  String get nationalId;

  /// No description provided for @signHere.
  ///
  /// In en, this message translates to:
  /// **'Sign here'**
  String get signHere;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @reportsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reportsTitle;

  /// No description provided for @reportsSquadRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Reports need a squad'**
  String get reportsSquadRequiredTitle;

  /// No description provided for @reportsSquadRequiredDesc.
  ///
  /// In en, this message translates to:
  /// **'Join or create a squad to view survey reports and performance insights.'**
  String get reportsSquadRequiredDesc;

  /// No description provided for @scopeCompany.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get scopeCompany;

  /// No description provided for @scopeMySquad.
  ///
  /// In en, this message translates to:
  /// **'My Squad'**
  String get scopeMySquad;

  /// No description provided for @scopeMyGovernorate.
  ///
  /// In en, this message translates to:
  /// **'My Governorate'**
  String get scopeMyGovernorate;

  /// No description provided for @totalResponses.
  ///
  /// In en, this message translates to:
  /// **'Total responses'**
  String get totalResponses;

  /// No description provided for @surveysPerHour.
  ///
  /// In en, this message translates to:
  /// **'Surveys per hour'**
  String get surveysPerHour;

  /// No description provided for @topPriorities.
  ///
  /// In en, this message translates to:
  /// **'Top priorities'**
  String get topPriorities;

  /// No description provided for @noPriorityData.
  ///
  /// In en, this message translates to:
  /// **'No priority data yet.'**
  String get noPriorityData;

  /// No description provided for @demoOtpHint.
  ///
  /// In en, this message translates to:
  /// **'Demo mode: OTP auto-filled'**
  String get demoOtpHint;

  /// No description provided for @noSurveyQuestions.
  ///
  /// In en, this message translates to:
  /// **'No questions available for this survey.'**
  String get noSurveyQuestions;

  /// No description provided for @surveySuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Thank you!'**
  String get surveySuccessTitle;

  /// No description provided for @surveySuccessBody.
  ///
  /// In en, this message translates to:
  /// **'The survey response has been submitted successfully.'**
  String get surveySuccessBody;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection.'**
  String get errorNetwork;

  /// No description provided for @errorUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'Authentication required. Please sign in again.'**
  String get errorUnauthorized;

  /// No description provided for @errorForbidden.
  ///
  /// In en, this message translates to:
  /// **'You are not allowed to perform this action.'**
  String get errorForbidden;

  /// No description provided for @errorNotFound.
  ///
  /// In en, this message translates to:
  /// **'The requested item was not found.'**
  String get errorNotFound;

  /// No description provided for @errorValidation.
  ///
  /// In en, this message translates to:
  /// **'Some fields are invalid. Please review your input.'**
  String get errorValidation;

  /// No description provided for @errorInvalidNationalId.
  ///
  /// In en, this message translates to:
  /// **'Invalid national ID.'**
  String get errorInvalidNationalId;

  /// No description provided for @errorInvalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone number.'**
  String get errorInvalidPhone;

  /// No description provided for @errorNotEligible.
  ///
  /// In en, this message translates to:
  /// **'You are not eligible to participate.'**
  String get errorNotEligible;

  /// No description provided for @errorInvalidDomain.
  ///
  /// In en, this message translates to:
  /// **'Please use your @orange.com work email address.'**
  String get errorInvalidDomain;

  /// No description provided for @errorAuthInvalidOtp.
  ///
  /// In en, this message translates to:
  /// **'Invalid or expired verification code.'**
  String get errorAuthInvalidOtp;

  /// No description provided for @errorAuthSessionInvalid.
  ///
  /// In en, this message translates to:
  /// **'Your session is invalid. Please sign in again.'**
  String get errorAuthSessionInvalid;

  /// No description provided for @errorAuthSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session expired. Please sign in again.'**
  String get errorAuthSessionExpired;

  /// No description provided for @errorUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'User not found.'**
  String get errorUserNotFound;

  /// No description provided for @errorProfileEditLimit.
  ///
  /// In en, this message translates to:
  /// **'Maximum profile edits reached.'**
  String get errorProfileEditLimit;

  /// No description provided for @errorConfigNotFound.
  ///
  /// In en, this message translates to:
  /// **'Configuration not found.'**
  String get errorConfigNotFound;

  /// No description provided for @errorBuildingNotFound.
  ///
  /// In en, this message translates to:
  /// **'Building not found.'**
  String get errorBuildingNotFound;

  /// No description provided for @errorSquadNotFound.
  ///
  /// In en, this message translates to:
  /// **'Squad not found.'**
  String get errorSquadNotFound;

  /// No description provided for @errorSquadLimitReached.
  ///
  /// In en, this message translates to:
  /// **'Maximum squad limit reached. Please join an existing squad.'**
  String get errorSquadLimitReached;

  /// No description provided for @errorSquadNameTaken.
  ///
  /// In en, this message translates to:
  /// **'Squad name is already taken.'**
  String get errorSquadNameTaken;

  /// No description provided for @errorSquadAlreadyMember.
  ///
  /// In en, this message translates to:
  /// **'You are already in a squad.'**
  String get errorSquadAlreadyMember;

  /// No description provided for @errorSquadFull.
  ///
  /// In en, this message translates to:
  /// **'This squad is full.'**
  String get errorSquadFull;

  /// No description provided for @errorSquadJoinRequestExists.
  ///
  /// In en, this message translates to:
  /// **'Join request already sent.'**
  String get errorSquadJoinRequestExists;

  /// No description provided for @errorSquadJoinRequestNotFound.
  ///
  /// In en, this message translates to:
  /// **'Join request not found.'**
  String get errorSquadJoinRequestNotFound;

  /// No description provided for @errorSquadLeaderOnly.
  ///
  /// In en, this message translates to:
  /// **'Only the squad leader can perform this action.'**
  String get errorSquadLeaderOnly;

  /// No description provided for @errorSquadLeaderCannotLeave.
  ///
  /// In en, this message translates to:
  /// **'Transfer leadership before leaving the squad.'**
  String get errorSquadLeaderCannotLeave;

  /// No description provided for @errorSquadLeaderCannotRemoveSelf.
  ///
  /// In en, this message translates to:
  /// **'Transfer leadership before removing yourself.'**
  String get errorSquadLeaderCannotRemoveSelf;

  /// No description provided for @errorSquadMemberNotFound.
  ///
  /// In en, this message translates to:
  /// **'Member not found in this squad.'**
  String get errorSquadMemberNotFound;

  /// No description provided for @errorSurveyNotFound.
  ///
  /// In en, this message translates to:
  /// **'Survey not found.'**
  String get errorSurveyNotFound;

  /// No description provided for @errorSurveySegmentNotFound.
  ///
  /// In en, this message translates to:
  /// **'No active survey for this segment.'**
  String get errorSurveySegmentNotFound;

  /// No description provided for @errorGalleryUploadLimit.
  ///
  /// In en, this message translates to:
  /// **'Maximum uploads reached for this employee.'**
  String get errorGalleryUploadLimit;

  /// No description provided for @errorBackendUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Cannot reach the backend. Ensure my boss app services are running and port 3001 is free.'**
  String get errorBackendUnavailable;

  /// No description provided for @errorInvalidOtp.
  ///
  /// In en, this message translates to:
  /// **'Invalid or expired verification code'**
  String get errorInvalidOtp;

  /// No description provided for @noSquadsFound.
  ///
  /// In en, this message translates to:
  /// **'No squads found. Try a different search.'**
  String get noSquadsFound;

  /// No description provided for @uploadedCount.
  ///
  /// In en, this message translates to:
  /// **'{current}/{max} uploaded'**
  String uploadedCount(int current, int max);

  /// No description provided for @squadTarget.
  ///
  /// In en, this message translates to:
  /// **'Target: {count} surveys'**
  String squadTarget(int count);

  /// No description provided for @noSquadWaitingDesc.
  ///
  /// In en, this message translates to:
  /// **'If you just sent a join request, it\'s waiting for the squad leader\'s approval. Pull to refresh once it\'s accepted.'**
  String get noSquadWaitingDesc;

  /// No description provided for @servicesLockedTitle.
  ///
  /// In en, this message translates to:
  /// **'Services locked'**
  String get servicesLockedTitle;

  /// No description provided for @servicesLockedDesc.
  ///
  /// In en, this message translates to:
  /// **'Join a squad to unlock surveys and field services. You need to be part of a group before you can fill surveys.'**
  String get servicesLockedDesc;

  /// No description provided for @pendingJoinRequestTitle.
  ///
  /// In en, this message translates to:
  /// **'Join request pending'**
  String get pendingJoinRequestTitle;

  /// No description provided for @pendingJoinRequestBody.
  ///
  /// In en, this message translates to:
  /// **'Your request to join \"{squadName}\" is waiting for the squad leader\'s approval.'**
  String pendingJoinRequestBody(String squadName);

  /// No description provided for @pendingJoinRequestHubNote.
  ///
  /// In en, this message translates to:
  /// **'You already have a pending join request. Wait for approval or refresh your status.'**
  String get pendingJoinRequestHubNote;

  /// No description provided for @leaveSquad.
  ///
  /// In en, this message translates to:
  /// **'Leave squad'**
  String get leaveSquad;

  /// No description provided for @leaveSquadConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave this squad?'**
  String get leaveSquadConfirmTitle;

  /// No description provided for @leaveSquadConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'You will lose access to squad surveys, chat, and gallery until you join another squad.'**
  String get leaveSquadConfirmMessage;

  /// No description provided for @leaveSquadConfirmYes.
  ///
  /// In en, this message translates to:
  /// **'Leave squad'**
  String get leaveSquadConfirmYes;

  /// No description provided for @transferLeaderTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose new squad leader'**
  String get transferLeaderTitle;

  /// No description provided for @transferLeaderMessage.
  ///
  /// In en, this message translates to:
  /// **'Before you leave, assign another member as squad leader.'**
  String get transferLeaderMessage;

  /// No description provided for @transferLeaderConfirm.
  ///
  /// In en, this message translates to:
  /// **'Transfer & leave'**
  String get transferLeaderConfirm;

  /// No description provided for @transferLeaderNoMembers.
  ///
  /// In en, this message translates to:
  /// **'Add at least one member before you can transfer leadership and leave.'**
  String get transferLeaderNoMembers;

  /// No description provided for @removeMember.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeMember;

  /// No description provided for @removeMemberConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove member?'**
  String get removeMemberConfirmTitle;

  /// No description provided for @removeMemberConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Remove {memberName} from this squad? They will lose access to squad surveys, chat, and gallery.'**
  String removeMemberConfirmMessage(String memberName);

  /// No description provided for @removeMemberConfirmYes.
  ///
  /// In en, this message translates to:
  /// **'Remove member'**
  String get removeMemberConfirmYes;

  /// No description provided for @vestSizeEditWindow.
  ///
  /// In en, this message translates to:
  /// **'Next vest size edit: {start} – {end}'**
  String vestSizeEditWindow(String start, String end);

  /// No description provided for @vestSizeChangePolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Vest size change policy'**
  String get vestSizeChangePolicyTitle;

  /// No description provided for @vestSizeChangePolicyNote.
  ///
  /// In en, this message translates to:
  /// **'You can change your vest size between {start} and {end}. After {end}, size changes will be blocked until the admin opens a new window.'**
  String vestSizeChangePolicyNote(String start, String end);

  /// No description provided for @vestSizeChangePolicyNoWindow.
  ///
  /// In en, this message translates to:
  /// **'Additional vest size changes require an admin-approved date window. Contact your initiative team if you need to update your size.'**
  String get vestSizeChangePolicyNoWindow;

  /// No description provided for @vestSizeEditOutsideWindow.
  ///
  /// In en, this message translates to:
  /// **'Vest size can only be changed during the scheduled edit window.'**
  String get vestSizeEditOutsideWindow;

  /// No description provided for @errorProfileEditOutsideWindow.
  ///
  /// In en, this message translates to:
  /// **'Vest size can only be changed during the scheduled edit window.'**
  String get errorProfileEditOutsideWindow;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @notLikely.
  ///
  /// In en, this message translates to:
  /// **'Not likely'**
  String get notLikely;

  /// No description provided for @veryLikely.
  ///
  /// In en, this message translates to:
  /// **'Very likely'**
  String get veryLikely;

  /// No description provided for @squadCreatedBodyNamed.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" is ready. Share your squad code {code} with teammates to invite them.'**
  String squadCreatedBodyNamed(String name, String code);

  /// No description provided for @mySquadTitle.
  ///
  /// In en, this message translates to:
  /// **'My Squad'**
  String get mySquadTitle;

  /// No description provided for @liveChat.
  ///
  /// In en, this message translates to:
  /// **'Live chat'**
  String get liveChat;

  /// No description provided for @liveChatTitle.
  ///
  /// In en, this message translates to:
  /// **'Live chat'**
  String get liveChatTitle;

  /// No description provided for @liveChatDesc.
  ///
  /// In en, this message translates to:
  /// **'Message your squad teammates only.'**
  String get liveChatDesc;

  /// No description provided for @liveChatUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Live chat is not configured yet. Email theboss@company.com for help.'**
  String get liveChatUnavailable;

  /// No description provided for @liveChatBanner.
  ///
  /// In en, this message translates to:
  /// **'Choose a squad teammate to message.'**
  String get liveChatBanner;

  /// No description provided for @chatSelectRecipient.
  ///
  /// In en, this message translates to:
  /// **'Message to'**
  String get chatSelectRecipient;

  /// No description provided for @chatSelectRecipientHint.
  ///
  /// In en, this message translates to:
  /// **'Choose a teammate before you send a message.'**
  String get chatSelectRecipientHint;

  /// No description provided for @chatSelectRecipientPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Select who to message…'**
  String get chatSelectRecipientPlaceholder;

  /// No description provided for @chatNoContactSelected.
  ///
  /// In en, this message translates to:
  /// **'Select a recipient first'**
  String get chatNoContactSelected;

  /// No description provided for @chatTapToMessage.
  ///
  /// In en, this message translates to:
  /// **'Use the dropdown above, or tap a contact below to start chatting.'**
  String get chatTapToMessage;

  /// No description provided for @chatQuickPick.
  ///
  /// In en, this message translates to:
  /// **'Quick pick'**
  String get chatQuickPick;

  /// No description provided for @chatSupportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Event support desk'**
  String get chatSupportSubtitle;

  /// No description provided for @chatTeammateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Squad teammate'**
  String get chatTeammateSubtitle;

  /// No description provided for @chatChooseContact.
  ///
  /// In en, this message translates to:
  /// **'Who do you want to message?'**
  String get chatChooseContact;

  /// No description provided for @chatChooseContactDesc.
  ///
  /// In en, this message translates to:
  /// **'Pick a squad teammate. Join a squad to see your team.'**
  String get chatChooseContactDesc;

  /// No description provided for @chatSquadLockedTitle.
  ///
  /// In en, this message translates to:
  /// **'Squad chat only'**
  String get chatSquadLockedTitle;

  /// No description provided for @chatSquadLockedDesc.
  ///
  /// In en, this message translates to:
  /// **'Join a squad to message your teammates. Chat is limited to people in your squad.'**
  String get chatSquadLockedDesc;

  /// No description provided for @chatSquadOnlyHint.
  ///
  /// In en, this message translates to:
  /// **'Squad chat · {squadName} — message teammates only.'**
  String chatSquadOnlyHint(String squadName);

  /// No description provided for @chatSquadMembersOnly.
  ///
  /// In en, this message translates to:
  /// **'Only squad members appear here. Support is not available in this chat.'**
  String get chatSquadMembersOnly;

  /// No description provided for @chatNoTeammatesYet.
  ///
  /// In en, this message translates to:
  /// **'No other teammates in your squad yet. Invite colleagues with your squad code.'**
  String get chatNoTeammatesYet;

  /// No description provided for @chatDirectBanner.
  ///
  /// In en, this message translates to:
  /// **'Direct chat with {name}. Messages update live.'**
  String chatDirectBanner(String name);

  /// No description provided for @chatLoading.
  ///
  /// In en, this message translates to:
  /// **'Connecting…'**
  String get chatLoading;

  /// No description provided for @chatEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Send a message to start the conversation.'**
  String get chatEmptyHint;

  /// No description provided for @chatEmptyHintDirect.
  ///
  /// In en, this message translates to:
  /// **'Say hello to {name}. Your message will be delivered instantly.'**
  String chatEmptyHintDirect(String name);

  /// No description provided for @noSquadUnlockTitle.
  ///
  /// In en, this message translates to:
  /// **'Join a squad to unlock'**
  String get noSquadUnlockTitle;

  /// No description provided for @noSquadUnlockDesc.
  ///
  /// In en, this message translates to:
  /// **'Create or join a squad to use team chat, share field photos, and fill surveys. You can still browse the gallery and edit your profile.'**
  String get noSquadUnlockDesc;

  /// No description provided for @noSquadLockedFeaturesTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlocks when you join:'**
  String get noSquadLockedFeaturesTitle;

  /// No description provided for @noSquadFeatureChat.
  ///
  /// In en, this message translates to:
  /// **'Message teammates'**
  String get noSquadFeatureChat;

  /// No description provided for @noSquadFeatureGalleryUpload.
  ///
  /// In en, this message translates to:
  /// **'Share field photos'**
  String get noSquadFeatureGalleryUpload;

  /// No description provided for @noSquadFeatureSurveys.
  ///
  /// In en, this message translates to:
  /// **'Field surveys & services'**
  String get noSquadFeatureSurveys;

  /// No description provided for @continueWithoutSquad.
  ///
  /// In en, this message translates to:
  /// **'Continue without a squad'**
  String get continueWithoutSquad;

  /// No description provided for @continueWithoutSquadHint.
  ///
  /// In en, this message translates to:
  /// **'Browse gallery, reports, and profile. Join anytime to unlock chat, surveys, and uploads.'**
  String get continueWithoutSquadHint;

  /// No description provided for @noSquadBrowseGalleryHint.
  ///
  /// In en, this message translates to:
  /// **'Browse-only mode — join a squad to share your own field photos.'**
  String get noSquadBrowseGalleryHint;

  /// No description provided for @noSquadChatLockedHint.
  ///
  /// In en, this message translates to:
  /// **'Join a squad to message teammates'**
  String get noSquadChatLockedHint;

  /// No description provided for @noSquadSurveyLockedHint.
  ///
  /// In en, this message translates to:
  /// **'Join a squad to fill field surveys'**
  String get noSquadSurveyLockedHint;

  /// No description provided for @chatTypeMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message…'**
  String get chatTypeMessage;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
