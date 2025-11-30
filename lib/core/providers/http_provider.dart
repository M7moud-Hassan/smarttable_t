import 'package:hooks_riverpod/hooks_riverpod.dart' show Provider;
import 'package:http/io_client.dart' as d;
import 'package:http_interceptor/http_interceptor.dart' show InterceptedClient;

import '../service/http_interceptor_service.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_interceptor/http_interceptor.dart';

final httpProvider = Provider<InterceptedClient>((ref) {
  // Create a custom HttpClient that bypasses SSL verification
  final httpClient = HttpClient()
    ..badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;

  // Wrap HttpClient in an IOClient for use with InterceptedClient
  final ioClient = d.IOClient(httpClient);

  // Create the InterceptedClient with custom client and interceptors
  final client = InterceptedClient.build(
    client: ioClient,
    interceptors: [InterceptorClientService(ref)],
    retryPolicy: ExpiredTokenRetryPolicy(),
  );

  ref.onDispose(client.close);
  return client;
});
