// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'my boss app';

  @override
  String get signInTitle => 'Sign in with your work email';

  @override
  String get signInSubtitle =>
      'Enter your Orange work email. We\'ll send you a 6-digit code — no password needed.';

  @override
  String get signInFooterHelp =>
      'Need help signing in? Contact the initiative team.';

  @override
  String get demoAccountLabel => 'Demo account';

  @override
  String get demoAccountHint => 'OTP auto-fills in demo mode.';

  @override
  String get otherTestAccountsTitle => 'Other accounts for testing';

  @override
  String get otherTestAccountsDescription =>
      'Tap any eligible @orange.com email below to try a different profile:';

  @override
  String get sendMyCode => 'Send my code';

  @override
  String get emailHint => 'demo@orange.com';

  @override
  String get contactEmail => 'theboss@company.com';

  @override
  String get otpTitle => 'Check your inbox';

  @override
  String otpSubtitle(String email) {
    return 'We sent a code to $email. It expires in 10 minutes.';
  }

  @override
  String get verifyAndContinue => 'Verify & continue';

  @override
  String get termsTitle => 'Terms & conditions';

  @override
  String get termsBody =>
      'By using my boss app you agree to follow Orange workplace policies during field activities, protect customer and colleague data, use the app only for authorized initiative work, and comply with squad and survey guidelines issued by the initiative team.';

  @override
  String get termsAcceptLabel => 'I accept all terms and conditions';

  @override
  String get termsContinue => 'Continue';

  @override
  String resendCodeIn(String time) {
    return 'Resend code in $time';
  }

  @override
  String get resendCode => 'Resend code';

  @override
  String get retry => 'Try again';

  @override
  String get language => 'Language';

  @override
  String get back => 'Back';

  @override
  String get continueLabel => 'Continue';

  @override
  String get close => 'Close';

  @override
  String get next => 'Next';

  @override
  String get submit => 'Submit';

  @override
  String get done => 'Done';

  @override
  String showMore(int count) {
    return 'Show more ($count)';
  }

  @override
  String get showLess => 'Show less';

  @override
  String get navHome => 'Home';

  @override
  String get navReports => 'Reports';

  @override
  String get navMySquad => 'My Squad';

  @override
  String get navGallery => 'Gallery';

  @override
  String get navNotifications => 'Notifications';

  @override
  String get navProfile => 'Profile';

  @override
  String get notificationsEmptyTitle => 'No notifications yet';

  @override
  String get notificationsEmptyBody =>
      'Admin announcements and squad alerts will appear here.';

  @override
  String get notificationsEnableTitle => 'Enable notifications';

  @override
  String get notificationsEnableBody =>
      'Turn on notifications to get live alerts when the initiative team sends updates — even when the app is in the background.';

  @override
  String get notificationsEnableAction => 'Enable';

  @override
  String get notificationsEnableLater => 'Not now';

  @override
  String homeWelcome(String name) {
    return 'Hey $name 👋';
  }

  @override
  String get serviceTemplates => 'Service templates';

  @override
  String get serviceTemplatesDesc =>
      'Pick a template to start a customer visit or feedback session.';

  @override
  String get noSquadYet =>
      'You\'re not in a squad yet. Tap to create or join one.';

  @override
  String get surveyProgress => 'Survey progress';

  @override
  String get governorateInsights => 'Governorate insights';

  @override
  String get responses => 'Responses';

  @override
  String get avgSatisfaction => 'Avg. satisfaction';

  @override
  String get perHour => 'Per hour';

  @override
  String get segmentConsumer => 'Consumer';

  @override
  String get segmentBusiness => 'Business';

  @override
  String get segmentEmployee => 'Employee';

  @override
  String get profileTitle => 'Profile';

  @override
  String get vestSize => 'Vest size';

  @override
  String get openToTravel => 'Open to travel';

  @override
  String get openToTravelDesc =>
      'Willing to be assigned outside your governorate';

  @override
  String get saveChanges => 'Save changes';

  @override
  String profileEditsRemaining(int count) {
    return '$count profile edits remaining';
  }

  @override
  String get profileEditsRemainingOne => '1 profile edit remaining';

  @override
  String get noProfileEditsRemaining => 'No profile edits remaining';

  @override
  String get employeeFeedbackSurvey => 'Employee feedback survey';

  @override
  String get reports => 'Reports';

  @override
  String get logOut => 'Log out';

  @override
  String get logOutConfirmTitle => 'Log out?';

  @override
  String get logOutConfirmMessage =>
      'You will need to sign in again to access the app.';

  @override
  String get logOutConfirmYes => 'Log out';

  @override
  String get logOutConfirmNo => 'Cancel';

  @override
  String get loadProfileError => 'Unable to load profile.';

  @override
  String get vestSizeTitle => 'Pick your vest size';

  @override
  String get vestSizeSubtitle =>
      'Your tool-kit includes a squad vest, a cap, and giveaways for the customers you\'ll visit.';

  @override
  String get vestSizeHint =>
      'Sizes run true to fit. Kits are handed out at your building on the morning of the event.';

  @override
  String get step1Tag => 'STEP 1 OF 3 · YOUR KIT';

  @override
  String get step2Tag => 'STEP 2 OF 3 · HOME BASE';

  @override
  String get step3Tag => 'STEP 3 OF 3 · YOUR SQUAD';

  @override
  String get buildingTitle => 'Where do you work?';

  @override
  String get buildingSubtitle =>
      'We use this to place your squad near you whenever possible.';

  @override
  String get selectBuilding => 'Select your building';

  @override
  String get governorate => 'Governorate';

  @override
  String get finishSetup => 'Finish setup';

  @override
  String get formYourSquad => 'Five people.\nOne mission.';

  @override
  String get formYourSquadDesc =>
      'Every squad has exactly 5 members. Lead one, or join colleagues who\'ve already started.';

  @override
  String squadsFormedProgress(int formed, int max) {
    return '$formed / $max squads formed so far';
  }

  @override
  String get takeMeHome => 'Take me home →';

  @override
  String get destinationIncomingTitle => 'Destination incoming.';

  @override
  String get destinationIncomingBody =>
      'Your squad\'s visit locations will land here soon — we\'ll ping you the moment they do.';

  @override
  String get addCustomer => '＋ Add a customer';

  @override
  String get addCustomerDesc => 'Opens the visit survey';

  @override
  String get travelPrefTitle => 'GREAT! WHICH GOVERNORATES INTEREST YOU?';

  @override
  String get totalSquads => 'Total squads';

  @override
  String get slotsLeft => 'Slots left';

  @override
  String get maxSquads => 'Max squads';

  @override
  String get createSquad => 'Create a squad';

  @override
  String get createSquadDesc =>
      'Start fresh, pick a name and badge, and invite others to join you.';

  @override
  String get createSquadNameTitle => 'Name your squad';

  @override
  String get createSquadNameDesc =>
      'Make it memorable — it shows up on the leaderboard for the whole company.';

  @override
  String get squadNameHint => 'e.g. Desert Falcons';

  @override
  String get squadIdAutoGenerated => 'Squad ID: auto-generated on create';

  @override
  String get createSquadLeaderHint =>
      'Creating a squad makes you its leader. You\'ll approve join requests until the squad is full (5/5).';

  @override
  String get findYourSquad => 'Find your squad';

  @override
  String get joinSquadDemoHint =>
      'Demo: requests are auto-accepted after a moment.';

  @override
  String get joinSquad => 'Join a squad';

  @override
  String get joinSquadDesc => 'Browse open squads and request to join.';

  @override
  String get joinSquadBrowseAllDesc =>
      'All open squads are listed below. Filter by governorate or search by name and code.';

  @override
  String get filterByGovernorate => 'Filter by governorate';

  @override
  String get filterAllGovernorates => 'All';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String squadsFilteredCount(int visible, int total) {
    return 'Showing $visible of $total squads';
  }

  @override
  String get noSquadsAvailable =>
      'No squads are available right now. Pull down to refresh.';

  @override
  String get squadName => 'Squad name';

  @override
  String get pickBadge => 'Pick a badge';

  @override
  String get create => 'Create';

  @override
  String get searchSquads => 'Search by squad name or code';

  @override
  String squadsFoundCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count squads found',
      one: '1 squad found',
    );
    return '$_temp0';
  }

  @override
  String get joinSquadSearchHint =>
      'Try searching \"Orange\" or \"Amman\", or pull down to refresh the list.';

  @override
  String get join => 'Join';

  @override
  String get full => 'Full';

  @override
  String members(int count) {
    return 'Members ($count/5)';
  }

  @override
  String get leader => 'Leader';

  @override
  String joinRequests(int count) {
    return 'Join requests ($count)';
  }

  @override
  String get noJoinRequests => 'No pending join requests';

  @override
  String get noSquadTitle => 'No squad yet';

  @override
  String get noSquadDesc =>
      'Create or join a squad to see members and progress here.';

  @override
  String get browseSquads => 'Browse squads';

  @override
  String get squadCreated => 'Squad created!';

  @override
  String get squadCreatedBody =>
      'Your squad is ready. Share the squad code with teammates.';

  @override
  String get requestSent => 'Request sent';

  @override
  String get requestSentBody =>
      'Your join request was sent. The squad leader will review it shortly.';

  @override
  String get goToMySquad => 'Go to My Squad';

  @override
  String get goToHome => 'Go to Home';

  @override
  String get galleryTitle => 'Gallery';

  @override
  String get upload => 'Upload';

  @override
  String get galleryAddPost => 'Add post';

  @override
  String get galleryPost => 'Post';

  @override
  String get galleryCaptionHint => 'Write a caption for your field moment…';

  @override
  String get gallerySkipCaption => 'Skip';

  @override
  String get galleryLockedDesc =>
      'Join a squad to upload photos and share posts with your team.';

  @override
  String get galleryUploadHint =>
      'Use the Share photo card below to add an image with an optional caption.';

  @override
  String get galleryViewOnlyHint =>
      'Browse squad field moments. Join a squad to upload your own posts.';

  @override
  String get galleryEmptyCanPost =>
      'No posts yet. Tap Share photo to add your first field moment.';

  @override
  String get galleryPostSuccess => 'Photo shared with your squad!';

  @override
  String get gallerySharePhotoTitle => 'Share a field moment';

  @override
  String gallerySharePhotoDesc(String squadName) {
    return 'Pick a photo from your gallery, add a caption, and share it with $squadName.';
  }

  @override
  String get gallerySharePhotoButton => 'Share photo';

  @override
  String get gallerySharePost => 'Share';

  @override
  String get galleryShareCopied =>
      'Caption copied — paste it in your favorite app to share.';

  @override
  String get galleryShareDefault =>
      'Amazing field moment with #theBOSS! #Orange #MCMB2026';

  @override
  String gallerySquadBanner(String squadName) {
    return 'Posting as $squadName';
  }

  @override
  String get fieldMoments => 'Field moments';

  @override
  String get noPhotosYet => 'No photos yet. Upload your first field moment.';

  @override
  String get maxUploadsReached => 'Maximum uploads reached';

  @override
  String get employeeFeedback => 'Employee Feedback';

  @override
  String get customerSurvey => 'Customer Survey';

  @override
  String questionProgress(int current, int total) {
    return 'Question $current of $total';
  }

  @override
  String get optional => 'Optional';

  @override
  String get typeAnswer => 'Type your answer…';

  @override
  String get fullName => 'Full name';

  @override
  String get nationalId => 'National ID number';

  @override
  String get signHere => 'Sign here';

  @override
  String get clear => 'Clear';

  @override
  String get reportsTitle => 'Reports';

  @override
  String get reportsSquadRequiredTitle => 'Reports need a squad';

  @override
  String get reportsSquadRequiredDesc =>
      'Join or create a squad to view survey reports and performance insights.';

  @override
  String get scopeCompany => 'Company';

  @override
  String get scopeMySquad => 'My Squad';

  @override
  String get scopeMyGovernorate => 'My Governorate';

  @override
  String get totalResponses => 'Total responses';

  @override
  String get surveysPerHour => 'Surveys per hour';

  @override
  String get topPriorities => 'Top priorities';

  @override
  String get noPriorityData => 'No priority data yet.';

  @override
  String get demoOtpHint => 'Demo mode: OTP auto-filled';

  @override
  String get noSurveyQuestions => 'No questions available for this survey.';

  @override
  String get surveySuccessTitle => 'Thank you!';

  @override
  String get surveySuccessBody =>
      'The survey response has been submitted successfully.';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get errorNetwork => 'Network error. Please check your connection.';

  @override
  String get errorUnauthorized =>
      'Authentication required. Please sign in again.';

  @override
  String get errorForbidden => 'You are not allowed to perform this action.';

  @override
  String get errorNotFound => 'The requested item was not found.';

  @override
  String get errorValidation =>
      'Some fields are invalid. Please review your input.';

  @override
  String get errorInvalidNationalId => 'Invalid national ID.';

  @override
  String get errorInvalidPhone => 'Invalid phone number.';

  @override
  String get errorNotEligible => 'You are not eligible to participate.';

  @override
  String get errorInvalidDomain =>
      'Please use your @orange.com work email address.';

  @override
  String get errorAuthInvalidOtp => 'Invalid or expired verification code.';

  @override
  String get errorAuthSessionInvalid =>
      'Your session is invalid. Please sign in again.';

  @override
  String get errorAuthSessionExpired =>
      'Your session expired. Please sign in again.';

  @override
  String get errorUserNotFound => 'User not found.';

  @override
  String get errorProfileEditLimit => 'Maximum profile edits reached.';

  @override
  String get errorConfigNotFound => 'Configuration not found.';

  @override
  String get errorBuildingNotFound => 'Building not found.';

  @override
  String get errorSquadNotFound => 'Squad not found.';

  @override
  String get errorSquadLimitReached =>
      'Maximum squad limit reached. Please join an existing squad.';

  @override
  String get errorSquadNameTaken => 'Squad name is already taken.';

  @override
  String get errorSquadAlreadyMember => 'You are already in a squad.';

  @override
  String get errorSquadFull => 'This squad is full.';

  @override
  String get errorSquadJoinRequestExists => 'Join request already sent.';

  @override
  String get errorSquadJoinRequestNotFound => 'Join request not found.';

  @override
  String get errorSquadLeaderOnly =>
      'Only the squad leader can perform this action.';

  @override
  String get errorSquadLeaderCannotLeave =>
      'Transfer leadership before leaving the squad.';

  @override
  String get errorSquadLeaderCannotRemoveSelf =>
      'Transfer leadership before removing yourself.';

  @override
  String get errorSquadMemberNotFound => 'Member not found in this squad.';

  @override
  String get errorSurveyNotFound => 'Survey not found.';

  @override
  String get errorSurveySegmentNotFound => 'No active survey for this segment.';

  @override
  String get errorGalleryUploadLimit =>
      'Maximum uploads reached for this employee.';

  @override
  String get errorBackendUnavailable =>
      'Cannot reach the backend. Ensure my boss app services are running and port 3001 is free.';

  @override
  String get errorInvalidOtp => 'Invalid or expired verification code';

  @override
  String get noSquadsFound => 'No squads found. Try a different search.';

  @override
  String uploadedCount(int current, int max) {
    return '$current/$max uploaded';
  }

  @override
  String squadTarget(int count) {
    return 'Target: $count surveys';
  }

  @override
  String get noSquadWaitingDesc =>
      'If you just sent a join request, it\'s waiting for the squad leader\'s approval. Pull to refresh once it\'s accepted.';

  @override
  String get servicesLockedTitle => 'Services locked';

  @override
  String get servicesLockedDesc =>
      'Join a squad to unlock surveys and field services. You need to be part of a group before you can fill surveys.';

  @override
  String get pendingJoinRequestTitle => 'Join request pending';

  @override
  String pendingJoinRequestBody(String squadName) {
    return 'Your request to join \"$squadName\" is waiting for the squad leader\'s approval.';
  }

  @override
  String get pendingJoinRequestHubNote =>
      'You already have a pending join request. Wait for approval or refresh your status.';

  @override
  String get leaveSquad => 'Leave squad';

  @override
  String get leaveSquadConfirmTitle => 'Leave this squad?';

  @override
  String get leaveSquadConfirmMessage =>
      'You will lose access to squad surveys, chat, and gallery until you join another squad.';

  @override
  String get leaveSquadConfirmYes => 'Leave squad';

  @override
  String get transferLeaderTitle => 'Choose new squad leader';

  @override
  String get transferLeaderMessage =>
      'Before you leave, assign another member as squad leader.';

  @override
  String get transferLeaderConfirm => 'Transfer & leave';

  @override
  String get transferLeaderNoMembers =>
      'Add at least one member before you can transfer leadership and leave.';

  @override
  String get removeMember => 'Remove';

  @override
  String get removeMemberConfirmTitle => 'Remove member?';

  @override
  String removeMemberConfirmMessage(String memberName) {
    return 'Remove $memberName from this squad? They will lose access to squad surveys, chat, and gallery.';
  }

  @override
  String get removeMemberConfirmYes => 'Remove member';

  @override
  String vestSizeEditWindow(String start, String end) {
    return 'Next vest size edit: $start – $end';
  }

  @override
  String get vestSizeChangePolicyTitle => 'Vest size change policy';

  @override
  String vestSizeChangePolicyNote(String start, String end) {
    return 'You can change your vest size between $start and $end. After $end, size changes will be blocked until the admin opens a new window.';
  }

  @override
  String get vestSizeChangePolicyNoWindow =>
      'Additional vest size changes require an admin-approved date window. Contact your initiative team if you need to update your size.';

  @override
  String get vestSizeEditOutsideWindow =>
      'Vest size can only be changed during the scheduled edit window.';

  @override
  String get errorProfileEditOutsideWindow =>
      'Vest size can only be changed during the scheduled edit window.';

  @override
  String get refresh => 'Refresh';

  @override
  String get notLikely => 'Not likely';

  @override
  String get veryLikely => 'Very likely';

  @override
  String squadCreatedBodyNamed(String name, String code) {
    return '\"$name\" is ready. Share your squad code $code with teammates to invite them.';
  }

  @override
  String get mySquadTitle => 'My Squad';

  @override
  String get liveChat => 'Live chat';

  @override
  String get liveChatTitle => 'Live chat';

  @override
  String get liveChatDesc => 'Message your squad teammates only.';

  @override
  String get liveChatUnavailable =>
      'Live chat is not configured yet. Email theboss@company.com for help.';

  @override
  String get liveChatBanner => 'Choose a squad teammate to message.';

  @override
  String get chatSelectRecipient => 'Message to';

  @override
  String get chatSelectRecipientHint =>
      'Choose a teammate before you send a message.';

  @override
  String get chatSelectRecipientPlaceholder => 'Select who to message…';

  @override
  String get chatNoContactSelected => 'Select a recipient first';

  @override
  String get chatTapToMessage =>
      'Use the dropdown above, or tap a contact below to start chatting.';

  @override
  String get chatQuickPick => 'Quick pick';

  @override
  String get chatSupportSubtitle => 'Event support desk';

  @override
  String get chatTeammateSubtitle => 'Squad teammate';

  @override
  String get chatChooseContact => 'Who do you want to message?';

  @override
  String get chatChooseContactDesc =>
      'Pick a squad teammate. Join a squad to see your team.';

  @override
  String get chatSquadLockedTitle => 'Squad chat only';

  @override
  String get chatSquadLockedDesc =>
      'Join a squad to message your teammates. Chat is limited to people in your squad.';

  @override
  String chatSquadOnlyHint(String squadName) {
    return 'Squad chat · $squadName — message teammates only.';
  }

  @override
  String get chatSquadMembersOnly =>
      'Only squad members appear here. Support is not available in this chat.';

  @override
  String get chatNoTeammatesYet =>
      'No other teammates in your squad yet. Invite colleagues with your squad code.';

  @override
  String chatDirectBanner(String name) {
    return 'Direct chat with $name. Messages update live.';
  }

  @override
  String get chatLoading => 'Connecting…';

  @override
  String get chatEmptyHint => 'Send a message to start the conversation.';

  @override
  String chatEmptyHintDirect(String name) {
    return 'Say hello to $name. Your message will be delivered instantly.';
  }

  @override
  String get noSquadUnlockTitle => 'Join a squad to unlock';

  @override
  String get noSquadUnlockDesc =>
      'Create or join a squad to use team chat, share field photos, and fill surveys. You can still browse the gallery and edit your profile.';

  @override
  String get noSquadLockedFeaturesTitle => 'Unlocks when you join:';

  @override
  String get noSquadFeatureChat => 'Message teammates';

  @override
  String get noSquadFeatureGalleryUpload => 'Share field photos';

  @override
  String get noSquadFeatureSurveys => 'Field surveys & services';

  @override
  String get continueWithoutSquad => 'Continue without a squad';

  @override
  String get continueWithoutSquadHint =>
      'Browse gallery, reports, and profile. Join anytime to unlock chat, surveys, and uploads.';

  @override
  String get noSquadBrowseGalleryHint =>
      'Browse-only mode — join a squad to share your own field photos.';

  @override
  String get noSquadChatLockedHint => 'Join a squad to message teammates';

  @override
  String get noSquadSurveyLockedHint => 'Join a squad to fill field surveys';

  @override
  String get chatTypeMessage => 'Type a message…';
}
