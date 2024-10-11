// ignore_for_file: unused_import

import 'dart:convert';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:tredo/src/core/error/network_exception.dart';
import 'package:tredo/src/core/network/layers/network_executer.dart';
import 'package:tredo/src/core/network/result.dart';
import 'package:tredo/src/features/auth/datasource/auth_api.dart';

import 'package:l/l.dart';

abstract class IAuthRemoteDS {
  Future<Result<List<Object>>> login({
    required String login,
    required String password,
  });
  Future<Result<String>> loginFirebase({
    required String login,
    required String password,
  });

  Future<Result<String>> registrationFirebase({
    required String login,
    required String password,
  });
}

class AuthRemoteDSImpl implements IAuthRemoteDS {
  final NetworkExecuter client;

  AuthRemoteDSImpl({
    required this.client,
  });

  @override
  Future<Result<List<Object>>> login({
    required String login,
    required String password,
  }) async {
    try {
      final Result<Map> result = await client.produce(
        route: AuthApi.login(login: login, password: password),
      );
      return result.when(
        success: (response) {
          final accessToken = jsonEncode(response['accessToken']);
          final refreshToken = jsonEncode(response['refreshToken']);

          return Result.success([accessToken, refreshToken]);
        },
        failure: (NetworkException exception) =>
            Result<List<String>>.failure(exception),
      );
    } catch (e) {
      if (kDebugMode) {
        l.d('login remote=> ${NetworkException.type(error: e.toString())}');
      }

      return Result<List<String>>.failure(
        NetworkException.type(error: e.toString()),
      );
    }
  }

  @override
  Future<Result<String>> loginFirebase({
    required String login,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: login,
        password: password,
      );
      return const Result.success('success');
    } catch (e) {
      if (kDebugMode) {
        l.d('loginFirebase remote=> ${NetworkException.type(error: e.toString())}');
      }

      return Result<String>.failure(
        NetworkException.type(error: e.toString()),
      );
    }
  }

  @override
  Future<Result<String>> registrationFirebase({
    required String login,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: login,
        password: password,
      );
      return const Result.success('success');
    } catch (e) {
      if (kDebugMode) {
        l.d('registrationFirebase remote=> ${NetworkException.type(error: e.toString())}');
      }

      return Result<String>.failure(
        NetworkException.type(error: e.toString()),
      );
    }
  }
}
