import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tredo/src/features/auth/repository/auth_repository.dart';

part 'login_cubit.freezed.dart';

const _tag = "LoginCubit";

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(
    this._authRepository,
  ) : super(const LoginState.loadingState());

  final IAuthRepository _authRepository;

  Future<void> login({
    required String login,
    required String password,
  }) async {
    emit(const LoginState.loadingState());
    // try {
    //   await FirebaseAuth.instance.signInWithEmailAndPassword(
    //     email: login,
    //     password: password,
    //   );
    //   emit(
    //     const LoginState.loadedState(user: 'response'),
    //   );
    // } on FirebaseAuthException catch (e) {
    //   if (e.code == 'user-not-found') {
    //     emit(
    //       LoginState.errorState(message: '$_tag - ${e.code}'),
    //     );
    //   } else if (e.code == 'wrong-password') {
    //     emit(
    //       LoginState.errorState(message: '$_tag - ${e.code}'),
    //     );
    //   } else {
    //     emit(
    //       LoginState.errorState(message: '$_tag - ${e.code}'),
    //     );
    //   }
    // } catch (e) {
    //   emit(
    //     LoginState.errorState(message: '$_tag - $e'),
    //   );
    // }

    final result = await _authRepository.loginFirebase(
      login: login,
      password: password,
    );

    result.when(
      success: (response) {
        emit(
          LoginState.loadedState(user: response),
        );
      },
      failure: (e) {
        e.maybeWhen(
          orElse: () {
            emit(
              LoginState.errorState(
                message: '$_tag - ${e.msg}',
              ),
            );
          },
        );
      },
    );
  }

  Future<void> registration({
    required String login,
    required String password,
  }) async {
    emit(const LoginState.loadingState());
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: login,
        password: password,
      );
      emit(
        const LoginState.loadedState(user: 'response'),
      );
    }
    // on FirebaseAuthException catch (e) {
    //   if (e.code == 'user-not-found') {
    //     emit(
    //       LoginState.errorState(message: '$_tag - ${e.code}'),
    //     );
    //   } else if (e.code == 'wrong-password') {
    //     emit(
    //       LoginState.errorState(message: '$_tag - ${e.code}'),
    //     );
    //   } else {
    //     emit(
    //       LoginState.errorState(message: '$_tag - ${e.code}'),
    //     );
    //   }
    // }
    catch (e) {
      emit(
        LoginState.errorState(message: '$_tag - $e'),
      );
    }
  }

  @override
  void onChange(Change<LoginState> change) {
    log(change.toString(), name: _tag);
    super.onChange(change);
  }
}

@freezed
class LoginState with _$LoginState {
  const factory LoginState.initialState() = _InitialState;

  const factory LoginState.loadedState({
    required String user,
  }) = _LoadedState;

  const factory LoginState.loadingState() = _LoadingState;

  const factory LoginState.errorState({
    required String message,
  }) = _ErrorState;
}
