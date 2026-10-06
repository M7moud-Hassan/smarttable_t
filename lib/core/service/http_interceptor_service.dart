import 'dart:convert' show jsonDecode, jsonEncode;
import 'dart:io' show HttpHeaders;

import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:hooks_riverpod/hooks_riverpod.dart' show Ref;
import 'package:http_interceptor/http_interceptor.dart'
    show
        InterceptorContract,
        BaseRequest,
        BaseResponse,
        RetryPolicy,
        Response,
        Request,
        MultipartRequest;
import 'dart:developer' as dev;

import '../constants/keys_enums.dart';
import '../models/request_response_state_model.dart';
import '../providers/providers.dart';
import '../utils/exceptions.dart';
import '../utils/token_storage.dart';

class InterceptorClientService extends InterceptorContract {
  InterceptorClientService(this._ref);
  final Ref _ref;

  void _log(String message) {
    if (kDebugMode) {
      dev.log(message, name: 'HttpInterceptor');
    }
  }

  @override
  Future<BaseRequest> interceptRequest({required BaseRequest request}) async {
    final prefs = _ref.read(sharedPreferencesProvider);
    final token = await _ref.read(tokenStorageProvider).getToken();
    final lang = prefs.getString(SharedPreferenceKeys.locale.name) ?? 'ar';
    final localeGenderFemale =
        prefs.getBool(SharedPreferenceKeys.localeFemale.name) ?? false;
    if (!request.headers.containsKey('auth-token')) {
      if (token != null) {
        final Map<String, String> headers = Map.from(request.headers);
        headers[HttpHeaders.acceptHeader] = 'application/json';
        headers['auth-token'] = token;
        headers[HttpHeaders.acceptLanguageHeader] = lang == 'ar'
            ? localeGenderFemale
                ? 'ar-fe'
                : 'ar'
            : 'en';
        request.headers.addAll(headers);
      }
    }
    _log(
      '➡️ Request -> ${request.method} ${request.url}\n'
      'Request headers: ${jsonEncode(request.headers)}',
    );
    if (request is Request && request.body.isNotEmpty) {
      _log('Request body: ${request.body}');
    } else if (request is MultipartRequest) {
      _log('Multipart request fields: ${jsonEncode(request.fields)}');
      final files = request.files
          .map(
            (file) => {
              'field': file.field,
              'filename': file.filename,
              'length': file.length,
              'content_type': file.contentType.toString(),
            },
          )
          .toList(growable: false);
      _log('Multipart request files: ${jsonEncode(files)}');
    }
    return request;
  }

  @override
  Future<BaseResponse> interceptResponse({
    required BaseResponse response,
  }) async {
    _log('✅ Response <- [${response.statusCode}] ${response.request?.url}');

    if (response is Response) {
      _log('Response headers: ${jsonEncode(response.headers)}');
      _log('Response body: ${response.body}');
    }
    Object? responseBody;
    if (response is Response && response.body.isNotEmpty) {
      try {
        responseBody = jsonDecode(response.body);
      } catch (_) {
        responseBody = response.body;
      }
    }

    // Validation and permission responses must stay available to the feature
    // that made the request. Only an explicit authentication failure should
    // end the teacher's session.
    if (isAuthenticationFailure(
      statusCode: response.statusCode,
      response: responseBody,
    )) {
      final token = await _ref.read(tokenStorageProvider).getToken();
      if (token != null) {
        _ref.read(requestResponseProvider.notifier).update((state) =>
            RequestResponseModel.error(actionOnDone: ActionOnDone.unAuth));
      }
    }
    return response;
  }
}

class ExpiredTokenRetryPolicy extends RetryPolicy {
  ExpiredTokenRetryPolicy();
  @override
  int get maxRetryAttempts => 2;

  @override
  Future<bool> shouldAttemptRetryOnException(
    Exception reason,
    BaseRequest request,
  ) async {
    debugPrint(reason.toString());
    // Retry on internet issues

    return false;
  }

  @override
  Future<bool> shouldAttemptRetryOnResponse(BaseResponse response) async {
    if (response.statusCode == 401) {
      //Todo
      // Perform your token refresh here.

      return true;
    }

    return false;
  }
}
