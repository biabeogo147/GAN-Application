import 'dart:io';
import 'package:flutter/services.dart';

class NativeBridge {
  static final _instance = NativeBridge._internal();

  NativeBridge._internal();

  static NativeBridge getInstance() {
    return _instance;
  }

  static const platformFramework = MethodChannel('dcgan_native_bridge');
  static final String tag = '--NativeBridge ${Platform.operatingSystem}--: ';

  Future<NativeResponseModel<String?>> nativeInitNlSdk() async {
    try {
      final result = await platformFramework.invokeMethod('initNlSdk');
      return NativeResponseModel(true, result, null);
    } on PlatformException catch (e) {
      return NativeResponseModel(false, null, e);
    }
  }
}

class NativeResponseModel<T> {
  bool isSuccess = false;
  T data;
  PlatformException? error;

  NativeResponseModel(this.isSuccess, this.data, this.error);
}
