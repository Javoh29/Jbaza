import 'package:flutter/material.dart';
import 'package:jbaza/jbaza.dart';

import '../state_management/errors_view_model.dart';

// ignore: must_be_immutable
class ErrorInfoPage extends ViewModelBuilderWidget<ErrorsViewModel> {
  ErrorInfoPage(this._vmException, {Key? key}) : super(key: key);
  final VMException _vmException;

  @override
  Widget builder(
      BuildContext context, ErrorsViewModel viewModel, Widget? child) {
    return Scaffold(
      backgroundColor: Colors.grey[800],
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'JBaza Exception',
          style: TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios,
              size: 22,
              color: Colors.white,
            )),
        actions: [
          IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.share,
                size: 22,
                color: Colors.white,
              ))
        ],
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        children: [
          _item('TAG:', _vmException.tag),
          const SizedBox(height: 15),
          _item('Create time:', _vmException.time),
          const SizedBox(height: 15),
          _item('Call func name:', _vmException.callFuncName),
          const SizedBox(height: 15),
          _item('Line num:', _vmException.lineNum),
          const SizedBox(height: 15),
          _item('Base request', _vmException.baseRequest),
          const SizedBox(height: 15),
          _item('Response status code:', _vmException.responseStatusCode),
          const SizedBox(height: 15),
          _item('Response phrase:', _vmException.responsePhrase),
          const SizedBox(height: 15),
          _item('Response body:', _vmException.responseBody),
          const SizedBox(height: 15),
          _item('Token is valid:', _vmException.tokenIsValid),
          const SizedBox(height: 15),
          _item('Message:', _vmException.message)
        ],
      ),
    );
  }

  Widget _item(String title, String? body) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        SelectableText(
          body ?? '- - - - - - - - -',
          style: const TextStyle(
              color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500),
        )
      ],
    );
  }

  @override
  void onDestroy(ErrorsViewModel model) {}

  @override
  ErrorsViewModel viewModelBuilder(BuildContext context) {
    return ErrorsViewModel();
  }
}
