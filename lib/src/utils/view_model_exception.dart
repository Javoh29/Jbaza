import 'package:hive/hive.dart';
import 'package:http/http.dart';

part 'view_model_exception.g.dart';

@HiveType(typeId: 0)
class VMException extends HiveObject {
  @HiveField(0)
  final String message;
  @HiveField(1)
  String tag;
  @HiveField(2)
  String time;
  @HiveField(3)
  String? callFuncName;
  @HiveField(4)
  String? line;
  @HiveField(5)
  String? deviceInfo;
  @HiveField(6)
  String? baseRequest;
  @HiveField(7)
  String? responseStatusCode;
  @HiveField(8)
  String? responsePhrase;
  @HiveField(9)
  String? responseBody;
  @HiveField(10)
  String? tokenIsValid;
  @HiveField(11)
  String? responseRequest;
  @HiveField(12)
  String? responseHeader;
  bool isInet = false;
  String? action;
  Response? response;

  VMException(this.message,
      {this.tag = '',
      this.time = '',
      this.callFuncName,
      this.line,
      this.deviceInfo,
      this.response,
      this.baseRequest,
      this.responseStatusCode,
      this.responsePhrase,
      this.responseBody,
      this.tokenIsValid,
      this.isInet = false,
      this.action}) {
    if (response != null) {
      baseRequest = response!.request.toString();
      responseStatusCode = response!.statusCode.toString();
      responsePhrase = response!.reasonPhrase.toString();
      responseBody = response!.body.toString();
      responseRequest = (response!.request as Request).body;
      responseHeader = response!.request?.headers.toString();
      tokenIsValid = response!.headers['Authorization'] != null
          ? response!.headers['Authorization']!.length < 10
              ? 'empty'
              : 'true'
          : 'null';
    }
  }

  factory VMException.fromJson(Map<String, dynamic> json) {
    return VMException(json['message'] ?? 'Unknown message',
        tag: json['tag'],
        time: json['time'],
        callFuncName: json['call_func_name'],
        line: json['line'],
        action: json['action'],
        baseRequest: json['base_request'],
        responseStatusCode: json['response_status_code'],
        responsePhrase: json['response_phrase'],
        responseBody: json['response_body'],
        tokenIsValid: json['token_is_valid']);
  }

  Map<String, dynamic> toJson() {
    if (responseStatusCode != null) {
      return {
        'tag': tag,
        'message': message,
        'time:': time,
        'call_func_name': callFuncName,
        'line': line,
        'action': action,
        'base_request': baseRequest,
        'response_status_code': responseStatusCode,
        'response_phrase': responsePhrase,
        'response_body': responseBody,
        'token_is_valid': tokenIsValid
      };
    } else {
      return {
        'tag': tag,
        'message': message,
        'time:': time,
        'call_func_name': callFuncName,
        'line': line,
        'action': action
      };
    }
  }

  VMException copyWith(
          {String? message,
          String? callFuncName,
          String? line,
          String? deviceInfo,
          Response? response,
          bool? isInet,
          String? action,
          String? tag}) =>
      VMException(message ?? this.message,
          callFuncName: callFuncName ?? this.callFuncName,
          line: line ?? this.line,
          deviceInfo: deviceInfo ?? this.deviceInfo,
          response: response ?? this.response,
          isInet: isInet ?? this.isInet,
          action: action ?? this.action,
          tag: tag ?? this.tag);

  @override
  String toString() {
    StringBuffer sb = StringBuffer();
    sb.write("JbazaException TAG: ($tag) - ");
    sb.write('Message: $message');
    sb.write(', Time($time)');
    sb.write(', Call func name: $callFuncName');
    sb.write(', Line: $line');
    sb.write(', Action: $action');
    if (response != null) {
      sb.write(', Base request: $baseRequest');
      sb.write(', Response status code: $responseStatusCode');
      sb.write(', Response phrase: $responsePhrase');
      sb.write(', Response body: $responseBody');
      sb.write(', Token is valid: $tokenIsValid');
    }
    sb.write(', Device info: $deviceInfo');
    return sb.toString();
  }
}
