import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:tredo/src/core/error/network_exception.dart';
import 'package:tredo/src/core/network/interfaces/base_client_generator.dart';
import 'package:tredo/src/core/network/interfaces/base_model.dart';
import 'package:tredo/src/core/network/layers/network_connectivity.dart';
import 'package:tredo/src/core/network/layers/network_creator.dart';
import 'package:tredo/src/core/network/layers/network_decoder.dart';
import 'package:tredo/src/core/network/network_options/network_options.dart';
import 'package:tredo/src/core/network/result.dart';
import 'package:tredo/src/core/utils/error_util.dart';
import 'package:l/l.dart';

class NetworkExecuter {
  final Dio _dio;

  final NetworkDecoder _decoder;
  final NetworkCreator _creator;
  final NetworkConnectivity _connectivity;

  NetworkExecuter({
    required Dio dio,
    required NetworkDecoder decoder,
    required NetworkCreator creator,
    required NetworkConnectivity networkConnectivity,
  })  : _dio = dio,
        _creator = creator,
        _decoder = decoder,
        _connectivity = networkConnectivity;

  bool _isTimeOut(DioError err) =>
      err.type == DioErrorType.receiveTimeout ||
      err.type == DioErrorType.sendTimeout ||
      err.type == DioErrorType.connectionTimeout;

  Future<Result<K>> execute<K, T>({
    required BaseClientGenerator route,
    T? responseType,
    NetworkOptions? options,
  }) async {
    if (kDebugMode) {
      l.d(route);
    }

    if (await _connectivity.status) {
      try {
        final response =
            await _creator.request(route: route, options: options, dio: _dio);

        if (responseType != null) {
          final data = _decoder.decode<K, T>(
            response: response,
            responseType: responseType as BaseModel,
          );

          return Result<K>.success(data);
        } else {
          return Result<K>.success('' as K);
        }

        /// Dio error
      } on DioError catch (err) {
        if (kDebugMode) {
          l.d('$route => ${NetworkException.request(error: err)}');
        }

        return _isTimeOut(err)
            ? Result<K>.failure(const NetworkException.timeOut())
            : Result<K>.failure(NetworkException.request(error: err));

        /// dynamic error
      } on Object catch (e, stackTrace) {
        if (kDebugMode) {
          l.d('$route => ${NetworkException.type(error: e.toString())}');
        }

        /// Отправляем ошибку в Sentry
        await ErrorUtil.logError(
          e,
          stackTrace: stackTrace,
          hint: '$route => ${NetworkException.type(error: e.toString())}',
        );

        return Result<K>.failure(NetworkException.type(error: e.toString()));
      }

      /// No Internet Connection
    } else {
      if (kDebugMode) {
        l.d(const NetworkException.connectivity());
      }

      return Result<K>.failure(const NetworkException.connectivity());
    }
  }

  Future<Result<K>> produce<K>({
    required BaseClientGenerator route,
    NetworkOptions? options,
  }) async {
    if (kDebugMode) {
      l.d(route);
    }

    if (await _connectivity.status) {
      try {
        final response =
            await _creator.request(route: route, options: options, dio: _dio);

        final Map<String, dynamic> responseMap =
            response.data as Map<String, dynamic>;

        if (responseMap['data'] != null) {
          return Result<K>.success(responseMap['data'] as K);
        } else {
          return Result<K>.success(responseMap as K);
        }

        /// Dio error
      } on DioError catch (err) {
        if (kDebugMode) {
          l.d('$route => ${NetworkException.request(error: err)}');
        }

        return _isTimeOut(err)
            ? Result<K>.failure(const NetworkException.timeOut())
            : Result<K>.failure(NetworkException.request(error: err));

        /// dynamic error
      } on Object catch (e, stackTrace) {
        if (kDebugMode) {
          l.d('$route => ${NetworkException.type(error: e.toString())}');
        }

        /// Отправляем ошибку в Sentry
        await ErrorUtil.logError(
          e,
          stackTrace: stackTrace,
          hint: '$route => ${NetworkException.type(error: e.toString())}',
        );

        return Result<K>.failure(NetworkException.type(error: e.toString()));
      }

      /// No Internet Connection
    } else {
      if (kDebugMode) {
        l.d(const NetworkException.connectivity());
      }

      return Result<K>.failure(const NetworkException.connectivity());
    }
  }
}
