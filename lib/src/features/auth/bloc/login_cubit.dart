import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
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

    final result = await _authRepository.loginFirebase(
      login: login,
      password: password,
    );

    result.when(
      success: (response) async {
        emit(LoginState.loadedState(user: response));
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

  Future<void> fetchUserData() async {
    try {
      emit(const LoginState.loadingState());

      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          final user = userDoc.data()! as Map<String, dynamic>;
          emit(LoginState.loadedState(user: user['email'] as String));
        }
      }
    } catch (e) {
      emit(const LoginState.errorState(message: 'Failed to fetch users'));
    }
  }

  Future<void> fetchAllUsers() async {
    try {
      emit(const LoginState.loadingState());
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        final QuerySnapshot userSnapshot =
            await FirebaseFirestore.instance.collection('users').get();

        final List<String> users = userSnapshot.docs
            .map(
              (doc) => (doc.data()! as Map<String, dynamic>)['email'] as String,
            )
            .toList();

        if (userDoc.exists) {
          final user = userDoc.data()! as Map<String, dynamic>;
          emit(
            LoginState.loadedState(
              user: user['email'] as String,
              userList: users,
            ),
          );
        }
      }
    } catch (e) {
      log('Failed to fetch user data: $e');
      emit(const LoginState.errorState(message: 'Failed to fetch user data'));
    }
  }

  Future<void> _addUserToFirestore() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance.collection('users').doc(user.uid).set(
        {'email': user.email ?? ''},
        SetOptions(merge: true),
      ).then((value) {
        log('User added to Firestore: ${user.uid}');
      }).catchError((error) {
        log('Failed to add user to Firestore: $error');
      });
    }
  }

  Future<void> registration({
    required String login,
    required String password,
  }) async {
    emit(const LoginState.loadingState());

    final result = await _authRepository.registrationFirebase(
      login: login,
      password: password,
    );

    result.when(
      success: (response) async {
        await _addUserToFirestore();
        emit(LoginState.loadedState(user: response));
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

    // try {
    //   await FirebaseAuth.instance.createUserWithEmailAndPassword(
    //     email: login,
    //     password: password,
    //   );
    //   emit(
    //     const LoginState.loadedState(user: 'response'),
    //   );
    // }
    // // on FirebaseAuthException catch (e) {
    // //   if (e.code == 'user-not-found') {
    // //     emit(
    // //       LoginState.errorState(message: '$_tag - ${e.code}'),
    // //     );
    // //   } else if (e.code == 'wrong-password') {
    // //     emit(
    // //       LoginState.errorState(message: '$_tag - ${e.code}'),
    // //     );
    // //   } else {
    // //     emit(
    // //       LoginState.errorState(message: '$_tag - ${e.code}'),
    // //     );
    // //   }
    // // }
    // catch (e) {
    //   emit(
    //     LoginState.errorState(message: '$_tag - $e'),
    //   );
    // }
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
    String? user,
    List<String>? userList,
  }) = _LoadedState;

  const factory LoginState.loadingState() = _LoadingState;

  const factory LoginState.errorState({
    required String message,
  }) = _ErrorState;
}
