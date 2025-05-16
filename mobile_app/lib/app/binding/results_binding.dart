// lib/app/binding/results_binding.dart
import 'package:get/get.dart';
import 'package:mobile_app/app/controller/results_controller.dart';

class ResultsBinding implements Bindings {
  final ResultsController controller;

  ResultsBinding(this.controller);

  @override
  void dependencies() {
    Get.lazyPut<ResultsController>(() => controller);
  }
}