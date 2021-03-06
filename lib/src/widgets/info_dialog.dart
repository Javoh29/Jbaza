import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<T?> showInfoDialog<T>(BuildContext context, String message,
    {String? title,
    List<Widget>? btns,
    bool isShowMore = true,
    bool isCancelBtn = false}) {
  if (Platform.isIOS) {
    return showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
              title: Text(title ?? 'Error'),
              content: isShowMore
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                            child: Text(message,
                                maxLines: 5, overflow: TextOverflow.ellipsis)),
                        CupertinoButton(
                            onPressed: () {},
                            child: const Text(
                              'more info',
                              style: TextStyle(
                                  decoration: TextDecoration.underline),
                            ))
                      ],
                    )
                  : Text(message),
              actions: btns ??
                  [CupertinoButton(child: const Text('OK'), onPressed: () {})],
            ));
  } else {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(title ?? 'Error'),
              content: isShowMore
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                            child: Text(message,
                                maxLines: 5, overflow: TextOverflow.ellipsis)),
                        TextButton(
                            onPressed: () {},
                            child: const Text(
                              'more info',
                              style: TextStyle(
                                  decoration: TextDecoration.underline),
                            ))
                      ],
                    )
                  : Text(message),
              actions: btns ??
                  [TextButton(onPressed: () {}, child: const Text('OK'))],
            ));
  }
}
