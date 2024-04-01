import 'dart:ffi';
import 'package:ffi/ffi.dart';

const fileName = "libslow_fib.dylib";
const targetPath = "slow_fib/target/debug/";

typedef NativeCallType = Pointer<Int32> Function(Pointer<Int32>);
typedef NativeSlowFibCallType = Int32 Function(Int32);
typedef DartSlowFibCallType = int Function(int);

final dylib = DynamicLibrary.open(targetPath + fileName);

class SlowFibConverter {
  static List<int> convert({required int row}) {
    final mainFunction =
        dylib.lookup<NativeFunction<NativeCallType>>('fib_row');
    final dartFunction = mainFunction.asFunction<NativeCallType>();

    final point = calloc<Int32>();
    point.value = row;

    final returnPoint = dartFunction(point);
    calloc.free(point);
    final result = returnPoint.asTypedList(row);
    print(result);

    final slowFib = dylib
        .lookupFunction<NativeSlowFibCallType, DartSlowFibCallType>('slow_fib');

    final fibVal = slowFib(12);
    print(fibVal);

    return result.toList();
  }
}
