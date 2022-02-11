import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart';
import 'package:jbaza/jbaza.dart';

abstract class NetViewModel extends BaseViewModel implements Client {
  String? authToken;

  @override
  Future<Response> head(Uri url, {Map<String, String>? headers}) =>
      _sendUnstreamed('HEAD', url, headers);

  @override
  Future<Response> get(Uri url, {Map<String, String>? headers}) =>
      _sendUnstreamed('GET', url, headers);

  @override
  Future<Response> post(Uri url,
          {Map<String, String>? headers, Object? body, Encoding? encoding}) =>
      _sendUnstreamed('POST', url, headers, body, encoding);

  @override
  Future<Response> put(Uri url,
          {Map<String, String>? headers, Object? body, Encoding? encoding}) =>
      _sendUnstreamed('PUT', url, headers, body, encoding);

  @override
  Future<Response> patch(Uri url,
          {Map<String, String>? headers, Object? body, Encoding? encoding}) =>
      _sendUnstreamed('PATCH', url, headers, body, encoding);

  @override
  Future<Response> delete(Uri url,
          {Map<String, String>? headers, Object? body, Encoding? encoding}) =>
      _sendUnstreamed('DELETE', url, headers, body, encoding);

  @override
  Future<String> read(Uri url, {Map<String, String>? headers}) async {
    final response = await get(url, headers: headers);
    _checkResponseSuccess(url, response);
    return response.body;
  }

  @override
  Future<Uint8List> readBytes(Uri url, {Map<String, String>? headers}) async {
    final response = await get(url, headers: headers);
    _checkResponseSuccess(url, response);
    return response.bodyBytes;
  }

  @override
  Future<StreamedResponse> send(BaseRequest request);

  Future<Response> _sendUnstreamed(
      String method, Uri url, Map<String, String>? headers,
      [body, Encoding? encoding]) async {
    var request = Request(method, url);

    if (headers != null) {
      if (authToken != null) headers['Authorization'] = authToken!;
      request.headers.addAll(headers);
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

    return Response.fromStream(await send(request));
  }

  void _checkResponseSuccess(Uri url, Response response) {
    if (response.statusCode < 400) return;
    var message = 'Request to $url failed with status ${response.statusCode}';
    if (response.reasonPhrase != null) {
      message = '$message: ${response.reasonPhrase}';
    }
    throw ClientException('$message.', url);
  }
}
