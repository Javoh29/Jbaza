import 'package:meta/meta.dart';

import 'reactive_service_mixin.dart';
import 'reactive_view_model.dart';

@protected
class DynamicSourceViewModel<T> extends ReactiveViewModel {
  bool changeSource = false;
  void notifySourceChanged({bool clearOldData = false}) {
    changeSource = true;
  }

  @override
  List<ReactiveServiceMixin> get reactiveServices => [];
}