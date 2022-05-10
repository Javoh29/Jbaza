import 'package:flutter/material.dart';
import 'package:jbaza/jbaza.dart';
import 'package:jbaza/src/state_management/url_change_viewmodel.dart';

class UrlChangePage extends ViewModelBuilderWidget<UrlChangeViewModel> {
  UrlChangePage({Key? key}) : super(key: key);

  @override
  Widget builder(
      BuildContext context, UrlChangeViewModel viewModel, Widget? child) {
    return Scaffold(
      backgroundColor: Colors.grey[800],
      body: Stack(
        children: [
          Material(
            color: Colors.transparent,
            child: ListView.separated(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 70),
                shrinkWrap: true,
                itemBuilder: (context, index) => TextField(
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500),
                      onChanged: (value) {
                        viewModel.urlList[index] = value;
                      },
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Colors.white54, width: 1)),
                          hintText: 'BaseUrl ${index + 1}',
                          hintStyle: const TextStyle(
                            color: Colors.white54,
                            fontSize: 16,
                          )),
                    ),
                separatorBuilder: (context, index) => const SizedBox(
                      height: 20,
                    ),
                itemCount: viewModel.urlList.length),
          ),
          Positioned(
            bottom: 15,
            height: 50,
            left: 15,
            right: 15,
            child: TextButton(
                onPressed: () {},
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Colors.grey[900]),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)))),
                child: const Text(
                  'Save',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500),
                )),
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
                    'Change Base urls',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                  IconButton(
                      onPressed: () {
                        viewModel.urlList.add(null);
                        viewModel.notifyListeners();
                      },
                      icon: const Icon(
                        Icons.add,
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

  @override
  UrlChangeViewModel viewModelBuilder(BuildContext context) {
    return UrlChangeViewModel();
  }
}
