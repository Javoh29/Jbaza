import 'package:flutter/material.dart';
import 'package:jbaza/jbaza.dart';
import 'package:jbaza/src/widgets/error_info_page.dart';

import '../state_management/errors_view_model.dart';
import 'error_dialog.dart';

// ignore: must_be_immutable
class ErrorsPage extends ViewModelBuilderWidget<ErrorsViewModel> {
  ErrorsPage({Key? key}) : super(key: key);

  final TextEditingController _textEditingController = TextEditingController();

  @override
  void onViewModelReady(ErrorsViewModel viewModel) {
    super.onViewModelReady(viewModel);
    viewModel.setModelTag('ErrorsPage');
    viewModel.getAllErrors();
  }

  @override
  Widget builder(
      BuildContext context, ErrorsViewModel viewModel, Widget? child) {
    if (viewModel.isError()) {
      Future.delayed(Duration.zero,
          () => showErrorDialog(context, viewModel.getVMError()!));
    }
    return Scaffold(
      backgroundColor: Colors.grey[800],
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: TextField(
          controller: _textEditingController,
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: 'Поиск...',
            hintStyle: TextStyle(
                color: Colors.white54,
                fontSize: 16,
                fontWeight: FontWeight.w600),
          ),
          onChanged: (text) {
            if (text.isEmpty) {
              viewModel.isFilter = false;
              viewModel.notifyListeners();
            }
          },
          onSubmitted: (text) {
            if (text.isNotEmpty) {
              viewModel.searchError(text.toLowerCase());
            }
          },
          style: const TextStyle(
              fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_sharp,
            size: 22,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
              onPressed: () {
                if (_textEditingController.text.isNotEmpty) {
                  viewModel
                      .searchError(_textEditingController.text.toLowerCase());
                }
              },
              icon: const Icon(
                Icons.search,
                color: Colors.white,
                size: 22,
              )),
          PopupMenuButton(
              itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 1,
                      child: const Text("Поделится"),
                      onTap: () {
                        if (viewModel.selectedList.isNotEmpty) {
                          viewModel.shareError(viewModel.selectedList);
                        }
                      },
                    ),
                    PopupMenuItem(
                      value: 2,
                      child: const Text("Удалить все"),
                      onTap: () {},
                    )
                  ])
        ],
      ),
      body: Stack(children: [
        ListView.separated(
            itemBuilder: (context, index) =>
                _item(viewModel, viewModel.errorsList[index]),
            separatorBuilder: (context, index) => Divider(
                  color: Colors.grey[600],
                  height: 1,
                ),
            itemCount: viewModel.errorsList.length),
        if (viewModel.isBusy())
          const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          )
      ]),
    );
  }

  Widget _item(ErrorsViewModel evm, VMException vme) {
    if (evm.selectedList.contains(vme)) {
      return CheckboxListTile(
        value: true,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        title: Text(
          vme.callFuncName ?? 'Unknown',
          style: const TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          vme.message,
          maxLines: 2,
          style: const TextStyle(
              color: Colors.white54, fontSize: 14, fontWeight: FontWeight.w400),
          overflow: TextOverflow.ellipsis,
        ),
        onChanged: (value) {
          evm.selectedList.remove(vme);
          evm.notifyListeners();
        },
      );
    } else {
      return ListTile(
        onTap: () {
          if (evm.selectedList.isNotEmpty) {
            evm.selectedList.add(vme);
            evm.notifyListeners();
          } else {
            Navigator.push(mContext,
                MaterialPageRoute(builder: (_) => ErrorInfoPage(vme)));
          }
        },
        onLongPress: () {
          evm.selectedList.add(vme);
          evm.notifyListeners();
        },
        contentPadding:
            const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        title: Text(
          vme.callFuncName ?? 'Unknown',
          style: const TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          vme.message,
          maxLines: 2,
          style: const TextStyle(
              color: Colors.white54, fontSize: 14, fontWeight: FontWeight.w400),
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          vme.time.replaceAll(' ', '\n'),
          textAlign: TextAlign.end,
          style: const TextStyle(
              color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
        ),
      );
    }
  }

  @override
  void onDestroy(ErrorsViewModel model) {
    _textEditingController.dispose();
  }

  @override
  ErrorsViewModel viewModelBuilder(BuildContext context) {
    return ErrorsViewModel();
  }
}
