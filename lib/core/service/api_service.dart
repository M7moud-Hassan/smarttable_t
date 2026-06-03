import 'dart:convert' show json, utf8;

import 'dart:io' show File;

import 'package:hooks_riverpod/hooks_riverpod.dart' show Ref;
import 'package:http_interceptor/http_interceptor.dart';
import 'package:smart_table_app/core/constants/endpoints.dart';

import '../constants/keys_enums.dart';
import '../models/response_model.dart';
import '../providers/http_provider.dart';
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
    // Ensure the response body is correctly decoded (assuming UTF-8)
    final decodedBody = utf8.decode(response.bodyBytes);

    // Decode the JSON response
    final decodedJson = decodedBody.isNotEmpty ? json.decode(decodedBody) : {};
    Map<String, dynamic> data;
    if (decodedJson is Map<String, dynamic>) {
      data = decodedJson;
    } else {
      data = {'data': decodedJson};
    }

    data.addAll({'status_code': response.statusCode});
    // Parse the data into a ResponseModel
    final result = ResponseModel.fromJson(data);

    return result;
  }

  Future<ResponseModel> post(String endPoint, Map<String, dynamic> body) async {
    final uri = await getUri(endPoint);
    final response = await _http.post(
      uri,
      body: json.encode(body),
      headers: _headers,
    );

    final decodedBody = utf8.decode(response.bodyBytes);

    // Decode the JSON response
    final decodedJson = decodedBody.isNotEmpty ? json.decode(decodedBody) : {};
    Map<String, dynamic> data;
    if (decodedJson is Map<String, dynamic>) {
      data = decodedJson;
    } else {
      data = {'data': decodedJson};
    }

    data.addAll({'status_code': response.statusCode});
    // Parse the data into a ResponseModel
    final result = ResponseModel.fromJson(data);

    return result;
  }

  Future<ResponseModel> delete(String endPoint) async {
    final uri = await getUri(endPoint);
    final response = await _http.delete(
      uri,
      headers: _headers,
    );

    final decodedJson =
        response.body.isNotEmpty ? json.decode(response.body) : {};
    Map<String, dynamic> data;
    if (decodedJson is Map<String, dynamic>) {
      data = decodedJson;
    } else {
      data = {'data': decodedJson};
    }

    data.addAll({'status_code': response.statusCode});
    final result = ResponseModel.fromJson(data);
    return result;
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
          print(
              'Adding file: ${file.path}, size: ${await file.length()} bytes');
          request.files.add(
            await MultipartFile.fromPath(entry.key, file.path),
          );
        }
      }
    }

    final headers = _headers;
    headers.remove('Content-type');
    request.headers.addAll(headers);
    request.fields.addAll(body);
    print('Multipart fields: ${request.fields}');
    print('Multipart files: ${request.files.map((f) => f.field).toList()}');

    final streamResponse = await _http.send(request);
    final response = await Response.fromStream(streamResponse);

    final decodedJson =
        response.body.isNotEmpty ? json.decode(response.body) : {};
    Map<String, dynamic> data;
    if (decodedJson is Map<String, dynamic>) {
      data = decodedJson;
    } else {
      data = {'data': decodedJson};
    }

    /// inject HTTP status manually
    data['status_code'] = response.statusCode;

    return ResponseModel.fromJson(data);
  }

  Future<ResponseModel> put(String endPoint, Map<String, dynamic> body) async {
    final uri = await getUri(endPoint);
    final response = await _http.put(
      uri,
      body: json.encode(body),
      headers: _headers,
    );

    final decodedBody = utf8.decode(response.bodyBytes);

    final decodedJson = decodedBody.isNotEmpty ? json.decode(decodedBody) : {};
    Map<String, dynamic> data;
    if (decodedJson is Map<String, dynamic>) {
      data = decodedJson;
    } else {
      data = {'data': decodedJson};
    }

    data.addAll({'status_code': response.statusCode});

    final result = ResponseModel.fromJson(data);
    return result;
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
