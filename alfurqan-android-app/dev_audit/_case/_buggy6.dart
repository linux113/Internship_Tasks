import 'package:dio/dio.dart';
import '../../config.dart';

class W {
  Future<void> f() async {
    // RULE-B ko do baar trigger karna chahiye:
    final mf = await MultipartFile.fromFile('x.jpg');
    print(FormData.fromMap({'files': mf}));
    // dio.-qualified sahi hai — ye trigger NAHI hona chahiye:
    final ok = await dio.MultipartFile.fromFile('y.jpg');
    print(ok.filename);
  }
}

// RULE-A ko ek baar trigger karna chahiye (bare onSubmitted),
// onFieldSubmitted waali line sahi hai — trigger NAHI honi chahiye.
buildIt() => TextFormField(
      onSubmitted: (v) {},
      onFieldSubmitted: (v) {},
    );
