import 'package:dio/dio.dart';
import 'package:flutter_healthkit/core/app_constants.dart';
import 'package:flutter_healthkit/core/network/model/general_data_collector_request_model.dart';
import 'package:flutter_healthkit/core/network/model/general_data_collector_response_model.dart';
import 'package:flutter_healthkit/core/network/model/health_records_query_response_model.dart';
import 'package:flutter_healthkit/core/network/model/sample_data_upload_request_model.dart';
import 'package:flutter_healthkit/core/network/model/sample_data_upload_response_model.dart';
import 'package:flutter_healthkit/core/network/model/sample_sets_history_response_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HealthKitApiException implements Exception {
  HealthKitApiException(this.message, {this.code});

  final String message;
  final int? code;

  @override
  String toString() => message;
}

Never _throwHealthKitApiException(DioException error) {
  final data = error.response?.data;
  final errorBody = data is Map<String, dynamic> ? data['error'] : null;
  final message =
      errorBody is Map<String, dynamic> ? errorBody['message'] as String? : null;
  final code = errorBody is Map<String, dynamic> ? errorBody['code'] as int? : null;
  throw HealthKitApiException(
    message ?? error.message ?? 'Request failed',
    code: code,
  );
}

class AuthService {
  AuthService({Dio? dio, FlutterSecureStorage? storage})
    : _dio = dio ?? Dio(),
      _storage = storage ?? const FlutterSecureStorage() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) async {
          final isTokenRequest =
              error.requestOptions.path == AppConstants.tokenUrl;
          if (error.response?.statusCode == 401 && !isTokenRequest) {
            if (await refreshAccessToken() != null) {
              try {
                return handler.resolve(await _dio.fetch(error.requestOptions));
              } on DioException catch (retryError) {
                return handler.next(retryError);
              }
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  final Dio _dio;
  final FlutterSecureStorage _storage;

  Future<bool> hasSession() async {
    return await _storage.read(key: _accessTokenKey) != null;
  }

  Future<void> logout() => _clearTokens();

  Future<Map<String, dynamic>?> postOAuthToken({required String code}) async {
    try {
      final response = await _dio.request<Map<String, dynamic>>(
        AppConstants.tokenUrl,
        options: Options(
          method: 'POST',
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        ),
        data: {
          'grant_type': 'authorization_code',
          'code': code,
          'client_id': AppConstants.clientId,
          'client_secret': AppConstants.clientSecret,
          'redirect_uri': AppConstants.redirectUrl,
        },
      );
      await _saveTokens(response.data);
      return response.data;
    } on DioException {
      return null;
    }
  }

  Future<Map<String, dynamic>?> refreshAccessToken() async {
    final refreshToken = await _storage.read(key: _refreshTokenKey);
    if (refreshToken == null) return null;

    try {
      final response = await _dio.request<Map<String, dynamic>>(
        AppConstants.tokenUrl,
        options: Options(
          method: 'POST',
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        ),
        data: {
          'grant_type': 'refresh_token',
          'client_id': AppConstants.clientId,
          'client_secret': AppConstants.clientSecret,
          'refresh_token': refreshToken,
        },
      );
      await _saveTokens(response.data);
      return response.data;
    } on DioException {
      await _clearTokens();
      return null;
    }
  }

  Future<void> _saveTokens(Map<String, dynamic>? tokenResponse) async {
    final accessToken = tokenResponse?['access_token'] as String?;
    if (accessToken == null) return;
    await _storage.write(key: _accessTokenKey, value: accessToken);

    final refreshToken = tokenResponse?['refresh_token'] as String?;
    if (refreshToken != null) {
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
    }
  }

  Future<void> _clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }
}

class HealthKitService {
  HealthKitService({Dio? dio, FlutterSecureStorage? storage, AuthService? authService})
    : _dio = dio ?? Dio(),
      _storage = storage ?? const FlutterSecureStorage(),
      _authService = authService ?? AuthService() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final accessToken = await _storage.read(key: _accessTokenKey);
          options.headers['Content-Type'] = 'application/json';
          options.headers['Cookie'] = AppConstants.wafCookie;
          if (accessToken != null) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          final alreadyRetried = error.requestOptions.extra['retried'] == true;
          if (error.response?.statusCode == 401 && !alreadyRetried) {
            if (await _authService.refreshAccessToken() != null) {
              try {
                final retryOptions = error.requestOptions
                  ..extra['retried'] = true;
                return handler.resolve(await _dio.fetch(retryOptions));
              } on DioException catch (retryError) {
                return handler.next(retryError);
              }
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  static const _accessTokenKey = 'access_token';
  static const _dataCollectorsPath = 'healthkit/v2/dataCollectors';

  final Dio _dio;
  final FlutterSecureStorage _storage;
  final AuthService _authService;

  Future<GeneralDataCollectorResponseModel?> createDataCollector(
    GeneralDataCollectorRequestModel request,
  ) async {
    try {
      final response = await _dio.request<Map<String, dynamic>>(
        '${AppConstants.baseUrl}$_dataCollectorsPath',
        options: Options(method: 'POST'),
        data: request.toJson(),
      );
      if (response.data == null) return null;
      return GeneralDataCollectorResponseModel.fromJson(response.data!);
    } on DioException catch (error) {
      _throwHealthKitApiException(error);
    }
  }

  Future<GeneralDataCollectorPatchResponseModel?> insertHealthRecords(
    String dataCollectorId,
    GeneralDataCollectorPatchRequestModel request,
  ) async {
    try {
      final response = await _dio.request<Map<String, dynamic>>(
        '${AppConstants.baseUrl}$_dataCollectorsPath/$dataCollectorId/healthRecords',
        options: Options(method: 'PATCH'),
        data: request.toJson(),
      );
      if (response.data == null) return null;
      return GeneralDataCollectorPatchResponseModel.fromJson(response.data!);
    } on DioException catch (error) {
      _throwHealthKitApiException(error);
    }
  }

  Future<SampleDataUploadPatchResponseModel?> uploadSampleData(
    String dataCollectorId,
    String sampleSetId,
    SampleDataUploadPatchRequestModel request,
  ) async {
    try {
      final response = await _dio.request<Map<String, dynamic>>(
        '${AppConstants.baseUrl}$_dataCollectorsPath/$dataCollectorId/sampleSets/$sampleSetId',
        options: Options(method: 'PATCH'),
        data: request.toJson(),
      );
      if (response.data == null) return null;
      return SampleDataUploadPatchResponseModel.fromJson(response.data!);
    } on DioException catch (error) {
      _throwHealthKitApiException(error);
    }
  }

  Future<GeneralDataCollectorResponseModel?> updateDataCollector(
    GeneralDataCollectorResponseModel request,
  ) async {
    try {
      final response = await _dio.request<Map<String, dynamic>>(
        '${AppConstants.baseUrl}$_dataCollectorsPath/${request.collectorId}',
        options: Options(method: 'PUT'),
        data: request.toJson(),
      );
      if (response.data == null) return null;
      return GeneralDataCollectorResponseModel.fromJson(response.data!);
    } on DioException catch (error) {
      _throwHealthKitApiException(error);
    }
  }

  Future<List<GeneralDataCollectorResponseModel>> queryDataCollectors() async {
    try {
      final response = await _dio.request(
        '${AppConstants.baseUrl}$_dataCollectorsPath',
        options: Options(method: 'GET'),
      );
      final data = response.data;
      final List<dynamic> items = data is List
          ? data
          : data is Map<String, dynamic>
          ? (data['dataCollector'] as List<dynamic>? ?? [])
          : [];
      return items
          .map(
            (e) => GeneralDataCollectorResponseModel.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList();
    } on DioException {
      return [];
    }
  }

  Future<bool> deleteDataCollector({required String dataCollectorId}) async {
    try {
      final response = await _dio.request(
        '${AppConstants.baseUrl}$_dataCollectorsPath/$dataCollectorId',
        options: Options(method: 'DELETE'),
      );
      return response.statusCode == 200;
    } on DioException catch (error) {
      _throwHealthKitApiException(error);
    }
  }

  Future<HealthRecordsQueryResponseModel?> queryHealthRecords({
    required String dataCollectorId,
    required int startTime,
    required int endTime,
  }) async {
    try {
      final response = await _dio.request<Map<String, dynamic>>(
        '${AppConstants.baseUrl}$_dataCollectorsPath/$dataCollectorId/healthRecords',
        options: Options(method: 'GET'),
        queryParameters: {'startTime': startTime, 'endTime': endTime},
      );
      if (response.data == null) return null;
      return HealthRecordsQueryResponseModel.fromJson(response.data!);
    } on DioException catch (error) {
      _throwHealthKitApiException(error);
    }
  }

  Future<SampleSetsHistoryResponseModel?> querySampleSetsHistory(
    String dataCollectorId,
  ) async {
    try {
      final response = await _dio.request<Map<String, dynamic>>(
        '${AppConstants.baseUrl}$_dataCollectorsPath/$dataCollectorId/sampleSets/history',
        options: Options(method: 'GET'),
      );
      if (response.data == null) return null;
      return SampleSetsHistoryResponseModel.fromJson(response.data!);
    } on DioException catch (error) {
      _throwHealthKitApiException(error);
    }
  }

  Future<bool> deleteHealthRecords({
    required String dataCollectorId,
    required int startTime,
    required int endTime,
    required bool deleteSubData,
  }) async {
    try {
      final response = await _dio.request(
        '${AppConstants.baseUrl}$_dataCollectorsPath/$dataCollectorId/healthRecords',
        options: Options(method: 'DELETE'),
        queryParameters: {
          'startTime': startTime,
          'endTime': endTime,
          'deleteSubData': deleteSubData,
        },
      );
      return response.statusCode == 200;
    } on DioException {
      return false;
    }
  }

  Future<bool> deleteSampleSet({
    required String dataCollectorId,
    required String sampleSetId,
  }) async {
    try {
      final response = await _dio.request(
        '${AppConstants.baseUrl}$_dataCollectorsPath/$dataCollectorId/sampleSets/$sampleSetId',
        options: Options(method: 'DELETE'),
      );
      return response.statusCode == 200;
    } on DioException {
      return false;
    }
  }
}
