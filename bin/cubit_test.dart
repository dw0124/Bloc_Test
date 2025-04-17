import 'package:bloc/bloc.dart';

class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  void increment() {
    emit(state + 1);  // emit을 통해 state를 변경
  }

  void errorTest() {
    addError(Exception('increment error!'), StackTrace.current);
  }

  @override
  void onChange(Change<int> change) {
    // Change는 Cubit의 state가 업데이트되기 직전에 발생
    super.onChange(change);
    print('CounterCubit - 변경 전: ${change.currentState}, 변경 후: ${change.nextState}');
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    // Cubit 내부에서 에러가 발생했을 때 호출
    print('CounterCubit - $error, $stackTrace');
    super.onError(error, stackTrace);
  }
}

class SimpleBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    // 어떤 Bloc/Cubit에서 어떤 변화가 있었는지 출력
    print('SimpleBlocObserver - ${bloc.runtimeType} $change');
    super.onChange(bloc, change);
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    // Bloc 또는 Cubit에서 발생한 에러를 감지하고 출력
    super.onError(bloc, error, stackTrace);
    print('SimpleBlocObserver - ${bloc.runtimeType} $error $stackTrace');
  }
}

Future<void> main() async {
  Bloc.observer = SimpleBlocObserver(); // 전역에서 모든 Cubit 및 Bloc의 상태 변화와 에러를 감시

  final cubit = CounterCubit();

  // listen - cubit을 구독해서 전달되는 stream을 처리함
  final subscription = cubit.stream.listen((value) {
    print(value);  // 여기서 방출된 state를 value라는 이름으로 받아서 출력
  });

  cubit.increment(); // emit(state + 1) -> stream에 값 방출

  await Future.delayed(Duration.zero); // 구독이 바로 종료되지 않게 비동기 흐름 기다려줌

  // 구독 종료 및 cubit 정리
  await subscription.cancel();
  await cubit.close();

}