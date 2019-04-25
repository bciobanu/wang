import 'package:meta/meta.dart';

class Origin {
  final String scheme;
  final String host;
  final int port;
  final String pathPrefix;

  const Origin({
    @required this.scheme,
    @required this.host,
    @required this.port,
    @required this.pathPrefix,
  });
}
