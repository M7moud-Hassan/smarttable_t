import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:smart_table_app/core/extensions/context_extensions.dart';

class ServerException implements Exception {
  final String? message;
  ServerException(this.message);
}

class AuthenticationException extends ServerException {
  AuthenticationException(super.message);
}

bool isAuthenticationFailure({
  required int? statusCode,
  Object? response,
}) {
  if (statusCode == HttpStatus.unauthorized) return true;
  if (statusCode != HttpStatus.forbidden) return false;

  return _containsInvalidTokenMessage(response);
}

bool _containsInvalidTokenMessage(Object? value) {
  if (value is Map) {
    return value.values.any(_containsInvalidTokenMessage);
  }
  if (value is Iterable) {
    return value.any(_containsInvalidTokenMessage);
  }
  if (value is! String) return false;

  final normalized = value
      .toLowerCase()
      .replaceAll(RegExp(r'[_-]+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  return normalized.contains('invalid token') ||
      normalized.contains('token is invalid') ||
      normalized.contains('expired token') ||
      normalized.contains('token expired') ||
      normalized.contains('token has expired');
}

String? exceptionHandler(
    {required BuildContext context, Exception? exception}) {
  if (exception is SocketException || exception is HandshakeException) {
    return context.locale.noInternet;
  } else if (exception is TimeoutException) {
    return context.locale.slowInternet;
  } else if (exception is ServerException) {
    return exception.message;
  }
  return null;
}
