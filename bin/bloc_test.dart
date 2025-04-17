import 'package:bloc/bloc.dart';

sealed class CounterEvent {}

final class CounterIncrementPressed extends CounterEvent {}
final class CounterDecrementPressed extends CounterEvent {}
final class CounterErrorPressed extends CounterEvent {}

class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0) {
    // CounterIncrementPressed 이벤트를 관리하는 EventHandler
    on<CounterIncrementPressed>((event, emit) => emit(state + 1));

    // CounterDecrementPressed 이벤트를 관리하는 EventHandler
    on<CounterDecrementPressed>((event, emit) {
      emit(state - 1);
    },
    );

    on<CounterErrorPressed>((event, emit) {
      addError(Exception('error!'), StackTrace.current);
    });
  }

  @override
  void onEvent(CounterEvent event) {
    // 이벤트 발생 시 호출됨
    super.onEvent(event);
    print(event);
  }

  @override
  void onChange(Change<int> change) {
    // State가 변경될 때 호출됨
    super.onChange(change);
    print(change);
  }

  @override
  void onTransition(Transition<CounterEvent, int> transition) {
    // State가 변경될 때 호출됨 (이벤트 정보를 포함)
    super.onTransition(transition);
    print(transition);
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    print('$error, $stackTrace');
    super.onError(error, stackTrace);
  }
}

Future<void> main() async {
  final bloc = CounterBloc();

  final subscription = bloc.stream.listen((value) {
    print("Stream - $value");
  });

  print(bloc.state);  // 0

  bloc.add(CounterIncrementPressed());  // Stream - 1

  bloc.add(CounterErrorPressed());  // 에러 로그

  await Future.delayed(Duration.zero);

  await subscription.cancel();
  await bloc.close();
}

// 0
// Instance of 'CounterIncrementPressed'  -> onEvent 콜백
// Instance of 'CounterErrorPressed'      -> onEvent 콜백
// Transition { currentState: 0, event: Instance of 'CounterIncrementPressed', nextState: 1 } -> onTransition 콜백
// Change { currentState: 0, nextState: 1 } -> onChange 콜백
// Stream - 1
// 에러 로그 ...