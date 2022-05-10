import 'package:flutter/material.dart';
import 'package:jbaza/jbaza.dart';
import 'package:jbaza/src/widgets/error_page.dart';
import 'package:jbaza/src/widgets/url_change_page.dart';

class ErrorsWidget extends StatelessWidget {
  const ErrorsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      onGenerateRoute: (RouteSettings settings) {
        final args = settings.arguments as Map<String, dynamic>;
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => ErrorPage(),
            );
          case 'error_info':
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => ErrorInfoPage(args['vme_model']),
            );
          case 'url_change':
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => UrlChangePage(),
            );
          default:
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => ErrorPage(),
            );
        }
      },
    );
  }
}
