import '../constants/keys_enums.dart';

class RequestResponseModel {
  final bool isLoading;
  final LoadingTypes? loadingType;
  final String? message;
  final dynamic additionalData;
  final ActionOnDone? actionOnDone;
  final Exception? exception;
  final RequestResponseState state;

  RequestResponseModel._({
    this.isLoading = false,
    this.loadingType,
    this.message,
    this.additionalData,
    this.actionOnDone,
    this.exception,
    required this.state,
  });

  /// Represents the loading state.
  factory RequestResponseModel.loading({
    bool loading = true,
    LoadingTypes loadingType = LoadingTypes.dialog,
  }) {
    return RequestResponseModel._(
      isLoading: loading,
      loadingType: loadingType,
      state: RequestResponseState.loading,
    );
  }

  /// Represents the success state.
  factory RequestResponseModel.success({
    String? message,
    dynamic additionalData,
    ActionOnDone actionOnDone = ActionOnDone.none,
  }) {
    return RequestResponseModel._(
        message: message,
        additionalData: additionalData,
        actionOnDone: actionOnDone,
        state: RequestResponseState.success,
        isLoading: false);
  }

  /// Represents the error state.
  factory RequestResponseModel.error({
    String? message,
    ActionOnDone actionOnDone = ActionOnDone.none,
    Exception? exception,
  }) {
    return RequestResponseModel._(
        message: message,
        actionOnDone: actionOnDone,
        exception: exception,
        state: RequestResponseState.error,
        isLoading: false);
  }

  /// Represents the initial state.
  factory RequestResponseModel.init() {
    return RequestResponseModel._(
      state: RequestResponseState.init,
    );
  }
}

/// Enum to represent the state of the RequestResponseModel.
