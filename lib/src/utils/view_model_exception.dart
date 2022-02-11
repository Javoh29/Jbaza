class VMException implements Exception {
  String tag = '';
  final String message;

  VMException(this.message);

  @override
  String toString() {
    StringBuffer sb = StringBuffer();
    sb.write("TAG: ($tag) - ");
    sb.write("JbazaException");
    if (message.isNotEmpty) sb.write(": $message");
    return sb.toString();
  }
}