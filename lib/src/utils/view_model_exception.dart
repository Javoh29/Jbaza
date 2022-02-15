import 'package:hive/hive.dart';
import 'package:http/http.dart';

part 'view_model_exception.g.dart';

@HiveType(typeId: 0)
class VMException extends HiveObject {
  @HiveField(0)
  final String message;
  @HiveField(1)
  String tag = '';
  @HiveField(2)
  String time = '';
  @HiveField(3)
  String? callFuncName;
  @HiveField(4)
  String? lineNum;
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
  Response? _response;

  VMException(this.message,
      {this.callFuncName, this.lineNum, this.deviceInfo, Response? response}) {
    _response = response;
    if (_response != null) {
      baseRequest = _response!.request.toString();
      responseStatusCode = _response!.statusCode.toString();
      responsePhrase = _response!.reasonPhrase.toString();
      responseBody = _response!.body.toString();
      tokenIsValid = _response!.headers['Authorization'] != null
          ? _response!.headers['Authorization']!.length < 10
              ? 'empty'
              : 'true'
          : 'null';
    }
  }

  @override
  String toString() {
    StringBuffer sb = StringBuffer();
    sb.write("JbazaException TAG: ($tag) - ");
    sb.write('Message: $message');
    sb.write(', Time($time)');
    sb.write(', Call func name: $callFuncName');
    sb.write(', Line num: $lineNum');
    if (_response != null) {
      sb.write(', Base resqust: $baseRequest');
      sb.write(', Response status code: $responseStatusCode');
      sb.write(', Response phrase: $responsePhrase');
      sb.write(', Response body: $responseBody');
      sb.write(', Token is valid: $tokenIsValid');
    }
    sb.write(', Device info: $deviceInfo');
    return sb.toString();
  }
}
