class VMResponse {
  String tag = '';
  final dynamic data;

  VMResponse(this.data);

  @override
  String toString() {
    StringBuffer sb = StringBuffer();
    sb.write("TAG: ($tag) - ");
    sb.write(data.toString());
    return sb.toString();
  }
}
