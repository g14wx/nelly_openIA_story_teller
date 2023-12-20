import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'counter_provider.g.dart'; // Generated code

@riverpod
class CounterLogic extends _$CounterLogic {
  @override
  int build() {
    // Initialize the state when the provider is first initialized
    return 0;
  }

  void increment() {
    // Update the state when the increment method is called
    state = state + 1;
  }
}