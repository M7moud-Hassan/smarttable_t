import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:smart_table_app/core/extensions/context_extensions.dart';

class ServerException implements Exception {
  final String? message;
  ServerException(this.message);
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
