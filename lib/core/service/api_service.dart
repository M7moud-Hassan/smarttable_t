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
    const apiUrl = Endpoints.baseUrl;
    // const locale = 'ar';
    var uri = Uri.parse('$apiUrl$endPoint');
    // if (locale != null) uri = uri.addParameters({'locale': locale});
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
    final data = json.decode(decodedBody) as Map<String, dynamic>;
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
    final data = json.decode(decodedBody) as Map<String, dynamic>;

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
    final data = json.decode(response.body) as Map<String, dynamic>;
    data.addAll({'status_code': response.statusCode});
    final result = ResponseModel.fromJson(data);
    return result;
  }

  Future<ResponseModel> multipartRequest(
      String endPoint, Map<String, String> body,
      [Map<String, File?>? fileMap]) async {
    final uri = await getUri(endPoint);
    final request = MultipartRequest(
      'POST',
      uri,
    );

    if (fileMap != null) {
      for (final entry in fileMap.entries) {
        final fieldName = entry.key;
        final file = entry.value;

        if (file != null) {
          final path = await MultipartFile.fromPath(
            fieldName,
            file.path,
          );

          request.files.add(path);
        }
      }
    }

    request.headers.addAll(_headers);
    request.fields.addAll(body);

    final streamResponse = await _http.send(request);
    final response = await Response.fromStream(streamResponse);
    final data = json.decode(response.body);

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

    final data = json.decode(decodedBody) as Map<String, dynamic>;
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
    return json.decode(response.body);
  }
}
