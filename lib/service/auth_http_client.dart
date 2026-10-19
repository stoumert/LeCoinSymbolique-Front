import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:synchronized/synchronized.dart';
import 'navigation_service.dart';

class AuthHttpClient extends http.BaseClient {
  static final _shared = AuthHttpClient._internal();
  factory AuthHttpClient() => _shared;
  AuthHttpClient._internal();

  final http.Client _inner = http.Client();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final String baseUrl = "http://localhost:8080/api";
  final Lock _refreshLock = Lock();

  Completer<void>? _refreshCompleter;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    return await _refreshLock.synchronized(() async {
      final response = await _sendRequest(request);

      if (response.statusCode != 401) return response;

      final copiedResponse = await http.Response.fromStream(response);

      try {
        final body = jsonDecode(copiedResponse.body);
        final isExpired = body["erreur"]?.toString() == "Le token expired";

        if (isExpired) {
          if (_refreshCompleter != null) {
            await _refreshCompleter!.future;
          } else {
            _refreshCompleter = Completer<void>();
            final success = await _refreshToken();
            _refreshCompleter!.complete();
            _refreshCompleter = null;

            if (!success) {
              NavigationService.navigateToLogin();
              throw Exception("Échec du rafraîchissement du token");
            }
          }

          return await _retryRequest(request);
        }else{
          NavigationService.navigateToLogin();

        }
      } catch (e) {
        print("Erreur lors du traitement du 401: $e");
      }

      return http.StreamedResponse(
        Stream.value(copiedResponse.bodyBytes),
        copiedResponse.statusCode,
        headers: copiedResponse.headers,
        reasonPhrase: copiedResponse.reasonPhrase,
      );
    });
  }


  Future<http.StreamedResponse> _sendRequest(http.BaseRequest request) async {
    final token = await _storage.read(key: "token");
    if (token != null) {
      request.headers["Authorization"] = "Bearer $token";
    }
    return _inner.send(request);
  }


  Future<http.StreamedResponse> _retryRequest(http.BaseRequest request) async {
    final newToken = await _storage.read(key: "token");
    if (newToken == null) {
      NavigationService.navigateToLogin();
      throw Exception("No token available");
    }

    if (request is http.MultipartRequest) {
      final newRequest = http.MultipartRequest(request.method, request.url)
        ..headers.addAll(request.headers)
        ..fields.addAll(request.fields)
        ..files.addAll(request.files);
      newRequest.headers["Authorization"] = "Bearer $newToken";
      return _inner.send(newRequest);
    } else {
      final newRequest = http.Request(request.method, request.url)
        ..headers.addAll(request.headers);

      if (request is http.Request) {
        newRequest.body = request.body;
      }

      newRequest.headers["Authorization"] = "Bearer $newToken";
      return _inner.send(newRequest);
    }
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storage.read(key: "refreshToken");
      final username = await _storage.read(key: "username");

      if (refreshToken == null || username == null) NavigationService.navigateToLogin();


      final response = await _inner.post(
        Uri.parse("$baseUrl/refresh-token"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "refreshToken": refreshToken,
          "username": username,
        }),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        await _storage.write(key: "token", value: body["bearer"]);

        if (body["refreshToken"] != null) {
          await _storage.write(key: "refreshToken", value: body["refreshToken"]);
        }

        print("🔁 Token rafraîchi avec succès !");
        return true;
      }
    } catch (e) {
      print("Erreur rafraîchissement token: $e");
    }

    return false;
  }

  Future<http.StreamedResponse> multipartRequest(
      String method,
      Uri url, {
        Map<String, String>? headers,
        Map<String, String>? fields,
        List<http.MultipartFile>? files,
      }) async {
    final request = http.MultipartRequest(method, url)
      ..headers.addAll(headers ?? {})
      ..fields.addAll(fields ?? {});
    if (files != null) {
      request.files.addAll(files);
    }
    return send(request);
  }
}