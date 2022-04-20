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
      body: Stack(
        children: [
          SafeArea(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(15, 70, 15, 15),
              shrinkWrap: true,
              children: [
                _item('TAG:', _vmException.tag),
                const SizedBox(height: 15),
                _item('Create time:', _vmException.time),
                const SizedBox(height: 15),
                _item('Call func name:', _vmException.callFuncName),
                const SizedBox(height: 15),
                _item('Line:', _vmException.line),
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
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
                color: Colors.grey[900],
                boxShadow: const [
                  BoxShadow(
                      offset: Offset(0, 1),
                      color: Colors.black26,
                      blurRadius: 10)
                ]),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        size: 22,
                        color: Colors.white,
                      )),
                  const Text(
                    'JBaza Exception',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                  IconButton(
                      onPressed: () => viewModel.shareError([_vmException]),
                      icon: const Icon(
                        Icons.share,
                        size: 22,
                        color: Colors.white,
                      ))
                ],
              ),
            ),
          )
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
  ErrorsViewModel viewModelBuilder(BuildContext context) {
    return ErrorsViewModel();
  }
}
