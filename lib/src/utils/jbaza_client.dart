import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart';

abstract class JClient implements Client {
  Future updateToken();

  int get unauthorized;

  Map<String, String>? getGlobalHeaders();

  @override
  Future<StreamedResponse> send(BaseRequest request, {bool isJoinToken = true}) {
    if (isJoinToken) {
      request.headers.addAll(getGlobalHeaders() ?? {});
    }
    return request.send();
  }

  @override
  Future<Response> head(Uri url, {Map<String, String>? headers, bool isJoinToken = true}) =>
      _sendUnstreamed('HEAD', url, headers, isJoinToken: isJoinToken);

  @override
  Future<Response> get(Uri url, {Map<String, String>? headers, bool isJoinToken = true}) =>
      _sendUnstreamed('GET', url, headers, isJoinToken: isJoinToken);

  @override
  Future<Response> post(Uri url,
          {Map<String, String>? headers, Object? body, Encoding? encoding, bool isJoinToken = true}) =>
      _sendUnstreamed('POST', url, headers, body: body, encoding: encoding, isJoinToken: isJoinToken);

  @override
  Future<Response> put(Uri url,
          {Map<String, String>? headers, Object? body, Encoding? encoding, bool isJoinToken = true}) =>
      _sendUnstreamed('PUT', url, headers, body: body, encoding: encoding, isJoinToken: isJoinToken);

  @override
  Future<Response> patch(Uri url,
          {Map<String, String>? headers, Object? body, Encoding? encoding, bool isJoinToken = true}) =>
      _sendUnstreamed('PATCH', url, headers, body: body, encoding: encoding, isJoinToken: isJoinToken);

  @override
  Future<Response> delete(Uri url,
          {Map<String, String>? headers, Object? body, Encoding? encoding, bool isJoinToken = true}) =>
      _sendUnstreamed('DELETE', url, headers, body: body, encoding: encoding, isJoinToken: isJoinToken);

  @override
  Future<String> read(Uri url, {Map<String, String>? headers, bool isJoinToken = true}) async {
    final response = await get(url, headers: headers, isJoinToken: isJoinToken);
    _checkResponseSuccess(url, response);
    return response.body;
  }

  @override
  Future<Uint8List> readBytes(Uri url, {Map<String, String>? headers, bool isJoinToken = true}) async {
    final response = await get(url, headers: headers, isJoinToken: isJoinToken);
    _checkResponseSuccess(url, response);
    return response.bodyBytes;
  }

  Future<Response> _sendUnstreamed(String method, Uri url, Map<String, String>? headers,
      {body, Encoding? encoding, bool isJoinToken = true, bool isCalled = false}) async {
    var request = Request(method, url);

    if (headers != null) request.headers.addAll(headers);
    if (isJoinToken) {
      request.headers.addAll(getGlobalHeaders() ?? {});
    }
    if (encoding != null) request.encoding = encoding;
    if (body != null) {
      if (body is String) {
        request.body = body;
      } else if (body is List) {
        request.bodyBytes = body.cast<int>();
      } else if (body is Map) {
        request.bodyFields = body.cast<String, String>();
      } else {
        throw ArgumentError('Invalid request body "$body".');
      }
    }

    Response response = await Response.fromStream(await send(request));
    if (response.statusCode == unauthorized && !isCalled) {
      await updateToken();
      response = await _sendUnstreamed(method, url, headers, isCalled: true);
    }
    return response;
  }

  void _checkResponseSuccess(Uri url, Response response) {
    if (response.statusCode < 400) return;
    var message = 'Request to $url failed with status ${response.statusCode}';
    if (response.reasonPhrase != null) {
      message = '$message: ${response.reasonPhrase}';
    }
    throw ClientException('$message.', url);
  }

  @override
  void close() {}
}
