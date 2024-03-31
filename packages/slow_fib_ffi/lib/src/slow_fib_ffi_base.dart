import 'dart:ffi';
import 'package:ffi/ffi.dart';

const fileName = "libslow_fib.dylib";
const targetPath = "slow_fib/target/debug/";

typedef NativeCallType = Pointer<Int32> Function(Pointer<Int32>);

late final dylib = DynamicLibrary.open(targetPath + fileName);

class SlowFibConverter {
  static List<int> convert({required int row}) {
    final mainFunction =
        dylib.lookup<NativeFunction<NativeCallType>>('fib_row');
    final dartFunction = mainFunction.asFunction<NativeCallType>();

    final point = calloc<Int32>();
    point.value = row;

    final returnPoint = dartFunction(point);
    calloc.free(point);
    print(returnPoint.asTypedList(row + 1));
    return [];
  }
}
