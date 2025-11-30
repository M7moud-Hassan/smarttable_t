enum SharedPreferenceKeys {
  locale,
  isFirst,
  localeFemale,
  userModel,
  token,
  classTimingHashed,
}

enum RequestResponseState { loading, success, error, init }

enum ActionOnDone {
  none,
  unAuth,
  goRegisterData,
  registerSucess,
  loginSucess,
  showSucessMessage,
  showSucessMessageAndPop,
}

enum LoadingTypes {
  dialog,
  inline,
}

enum AuthState { init, auth, unAuth }

enum ScheduledTasksFilter { upcoming, expired, current }
