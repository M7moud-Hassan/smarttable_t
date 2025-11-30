class ResponseModel {
  final bool? success;
  final String? message;
  final String? token;
  final String? fcmToken;
  final int? statusCode;
  final dynamic data;

  ResponseModel({
    required this.success,
    this.message,
    required this.statusCode,
    required this.data,
    this.token,
    this.fcmToken,
  });

  factory ResponseModel.fromJson(Map<String, dynamic> json) {
    bool successValue;
    if (json['success'] is bool) {
      successValue = json['success'];
    } else {
      // If 'success' is not bool, determine it based on status code
      final statusCode = json['status_code'];
      successValue = statusCode != null &&
          statusCode is int &&
          statusCode >= 200 &&
          statusCode < 300;
    }

    return ResponseModel(
      success: successValue,
      message: json['message'] ?? json['error'],
      data: json['data'],
      statusCode: json['status_code'],
      token: json['token'],
      fcmToken: json['fcm_token'],
    );
  }

  /// Converts an instance to a JSON object.
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data,
      'status_code': statusCode,
      'token': token,
      'fcm_token': token,
    };
  }

  /// Factory for creating an error response.
  factory ResponseModel.error() => ResponseModel(
        success: false,
        message: '',
        statusCode: 0,
        data: <String, dynamic>{},
      );
}
