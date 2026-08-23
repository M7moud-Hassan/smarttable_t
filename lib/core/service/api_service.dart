import 'dart:convert' show json, utf8;

import 'dart:io' show File;

import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:hooks_riverpod/hooks_riverpod.dart' show Ref;
import 'package:http_interceptor/http_interceptor.dart';
import 'package:smart_table_app/core/constants/endpoints.dart';

import '../constants/keys_enums.dart';
import '../models/response_model.dart';
import '../providers/providers.dart';

class ApiService {
  ApiService(this._ref) : _http = _ref.read(httpProvider);

  static String? token;
  final Ref _ref;
  final InterceptedClient _http;

  Map<String, String> get _headers => {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token'
      };

  ResponseModel _parseResponse(Response response) {
    final decodedBody = utf8.decode(response.bodyBytes);
    Map<String, dynamic> data;

    if (decodedBody.isEmpty) {
      data = <String, dynamic>{};
    } else {
      try {
        final decodedJson = json.decode(decodedBody);
        if (decodedJson is Map) {
          final decodedMap = Map<String, dynamic>.from(decodedJson);
          data = _isResponseEnvelope(decodedMap, response.statusCode)
              ? decodedMap
              : <String, dynamic>{'data': decodedMap};
        } else {
          data = <String, dynamic>{'data': decodedJson};
        }
      } on FormatException {
        // Some proxies and servers return an HTML error/redirect page. Keep
        // that response out of the JSON parser and let repositories surface a
        // normal localized server error instead of crashing.
        data = <String, dynamic>{'data': null};
      }
    }

    data['status_code'] = response.statusCode;
    return ResponseModel.fromJson(data);
  }

  bool _isResponseEnvelope(Map<String, dynamic> body, int statusCode) {
    if (statusCode >= 400) return true;
    return const {
      'data',
      'success',
      'message',
      'error',
      'detail',
      'errors',
      'token',
      'fcm_token',
      'non_field_errors',
    }.any(body.containsKey);
  }

  Future<Uri> getUri(
    String endPoint, {
    Map<String, dynamic>? parameters,
  }) async {
    Uri uri;
    if (endPoint.startsWith('http')) {
      uri = Uri.parse(endPoint);
    } else if (endPoint.startsWith('/')) {
      uri = Uri.parse('${Endpoints.baseUrl}${endPoint.substring(1)}');
    } else {
      const apiUrl = Endpoints.baseUrl;
      uri = Uri.parse('$apiUrl$endPoint');
    }
    if (parameters != null) uri = uri.addParameters(parameters);
    return uri;
  }

  Future<ResponseModel> get(
    String endPoint, {
    Map<String, dynamic>? parameters,
  }) async {
    final uri = await getUri(
      endPoint,
      parameters: parameters,
    );

    print("assssssssss");
    print(endPoint);
    print(_headers);
    // Make the HTTP GET request
    final response = await _http.get(uri, headers: _headers);
    return _parseResponse(response);
  }

  /// Fetches endpoints that return a file instead of the normal JSON body.
  /// Authentication and locale headers are still added by the shared client.
  Future<Response> getRaw(
    String endPoint, {
    Map<String, dynamic>? parameters,
  }) async {
    final uri = await getUri(endPoint, parameters: parameters);
    return _http.get(uri, headers: _headers);
  }

  Future<ResponseModel> post(String endPoint, Map<String, dynamic> body) async {
    final uri = await getUri(endPoint);
    final response = await _http.post(
      uri,
      body: json.encode(body),
      headers: _headers,
    );

    return _parseResponse(response);
  }

  Future<ResponseModel> delete(String endPoint) async {
    final uri = await getUri(endPoint);
    final response = await _http.delete(
      uri,
      headers: _headers,
    );

    return _parseResponse(response);
  }

  Future<ResponseModel> multipartRequest(
    String endPoint,
    Map<String, String> body, [
    Map<String, File?>? fileMap,
  ]) async {
    final uri = await getUri(endPoint);
    final request = MultipartRequest('POST', uri);

    if (fileMap != null) {
      for (final entry in fileMap.entries) {
        final file = entry.value;
        if (file != null) {
          debugPrint(
              'Adding file: ${file.path}, size: ${await file.length()} bytes');
          final ext = file.path.split('.').last.toLowerCase();
          final contentType = ext == 'png'
              ? MediaType('image', 'png')
              : ext == 'jpg' || ext == 'jpeg'
                  ? MediaType('image', 'jpeg')
                  : ext == 'pdf'
                      ? MediaType('application', 'pdf')
                      : MediaType('application', 'octet-stream');
          request.files.add(
            await MultipartFile.fromPath(
              entry.key,
              file.path,
              contentType: contentType,
            ),
          );
        }
      }
    }

    final headers = _headers;
    headers.remove('Content-type');
    request.headers.addAll(headers);
    request.fields.addAll(body);
    debugPrint('Multipart fields: ${request.fields}');
    debugPrint(
      'Multipart files: ${request.files.map((f) => f.field).toList()}',
    );

    final streamResponse = await _http.send(request);
    final response = await Response.fromStream(streamResponse);

    if (kDebugMode && response.statusCode >= 400) {
      debugPrint(
        'Multipart response failed [${response.statusCode}] at ${uri.path}',
      );
    }

    return _parseResponse(response);
  }

  Future<ResponseModel> put(String endPoint, Map<String, dynamic> body) async {
    final uri = await getUri(endPoint);
    final response = await _http.put(
      uri,
      body: json.encode(body),
      headers: _headers,
    );

    return _parseResponse(response);
  }

  Future<ResponseModel> patch(
      String endPoint, Map<String, dynamic> body) async {
    final uri = await getUri(endPoint);
    final response = await _http.patch(
      uri,
      body: json.encode(body),
      headers: _headers,
    );

    return _parseResponse(response);
  }

  Future<dynamic> generalGet(url) async {
    final headers = _headers;
    final prefs = _ref.read(sharedPreferencesProvider);
    final lang = prefs.getString(SharedPreferenceKeys.locale.name) ?? 'ar';
    headers.addAll({'Accept-Language': lang});
    final response = await _http.get(
      Uri.parse(url),
      headers: headers,
    );
    return response.body.isNotEmpty ? json.decode(response.body) : {};
  }
}
