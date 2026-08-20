import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';

import '../env.dart';
import 'local_storage_service.dart';

/// Supported HTTP methods.
enum ApiMethod { get, post, put, patch, delete }

/// Uniform wrapper for EVERY api response coming from the backend.
/// Backend always returns: { code, message, isSuccess, data }
class ApiResponse<T> {
  final bool isSuccess;
  final String message;
  final int? code;
  final T? data;

  ApiResponse({
    required this.isSuccess,
    required this.message,
    this.code,
    this.data,
  });

  @override
  String toString() =>
      'ApiResponse(isSuccess: $isSuccess, code: $code, message: $message, data: $data)';
}

/// -----------------------------------------------------------------------
/// ApiService
/// -----------------------------------------------------------------------
/// Ek single, dynamic class jisse app ki HAR api (GET/POST/PUT/DELETE)
/// isi se call hogi. Naya endpoint aane par sirf [ApiEndpoints] me
/// ek line add karni hai aur controller me `ApiService().request(...)`
/// call karna hai - is file me kuch change karne ki zarurat nahi.
///
/// Usage:
/// ```dart
/// final res = await ApiService().request(
///   endpoint: ApiEndpoints.login,
///   method: ApiMethod.post,
///   data: {"email": email, "password": password},
///   fromJson: (json) => LoginResponseModel.fromJson(json),
/// );
///
/// if (res.isSuccess) {
///   final user = res.data; // LoginResponseModel
/// } else {
///   snackBar(res.message);
/// }
/// ```
class ApiService {
  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: environment['serverConfig']['apiUrl'],
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'accept': 'text/plain',
        },
      ),
    );

    // Auto attach token (agar user login hai) + basic request/response logging.
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _storage.read('token');
          if (token != null && token.toString().isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          log('➡️ [${options.method}] ${options.uri}\nbody: ${options.data}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          log('✅ [${response.requestOptions.path}] => ${response.data}');
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          log('❌ [${e.requestOptions.path}] => ${e.message}');
          return handler.next(e);
        },
      ),
    );
  }

  static final ApiService _instance = ApiService._internal();

  factory ApiService() => _instance;

  late final Dio _dio;
  final LocalStorage _storage = LocalStorage();

  /// Raw dio access, agar kabhi file upload / multipart / custom cheez karni ho.
  Dio get dio => _dio;

  /// -------------------------------------------------------------------
  /// MAIN DYNAMIC METHOD - isi ek method se app ki har api call hogi.
  /// -------------------------------------------------------------------
  /// [endpoint]  -> ApiEndpoints.login jaisa relative path (ya full url bhi de sakte ho)
  /// [method]    -> ApiMethod.get / post / put / patch / delete
  /// [data]      -> body (post/put/patch ke liye)
  /// [queryParams] -> ?page=1&limit=10 jaise query params (get me bhi, post me bhi)
  /// [fromJson]  -> response ke "data" node ko model me convert karne wala function
  /// [isFormData] -> true karo agar multipart/form-data (image upload etc.) bhejni ho
  Future<ApiResponse<T>> request<T>({
    required String endpoint,
    required ApiMethod method,
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParams,
    T Function(dynamic json)? fromJson,
    bool isFormData = false,
    Options? options,
  }) async {
    try {
      final Response response;
      final reqData = isFormData && data != null ? FormData.fromMap(data) : data;

      switch (method) {
        case ApiMethod.get:
          response = await _dio.get(
            endpoint,
            queryParameters: queryParams,
            options: options,
          );
          break;
        case ApiMethod.post:
          response = await _dio.post(
            endpoint,
            data: reqData,
            queryParameters: queryParams,
            options: options,
          );
          break;
        case ApiMethod.put:
          response = await _dio.put(
            endpoint,
            data: reqData,
            queryParameters: queryParams,
            options: options,
          );
          break;
        case ApiMethod.patch:
          response = await _dio.patch(
            endpoint,
            data: reqData,
            queryParameters: queryParams,
            options: options,
          );
          break;
        case ApiMethod.delete:
          response = await _dio.delete(
            endpoint,
            data: reqData,
            queryParameters: queryParams,
            options: options,
          );
          break;
      }

      return _parseResponse<T>(response, fromJson);
    } on DioException catch (e) {
      return ApiResponse<T>(
        isSuccess: false,
        message: _handleDioError(e),
        code: e.response?.statusCode,
        data: null,
      );
    } catch (e) {
      return ApiResponse<T>(
        isSuccess: false,
        message: e.toString(),
        data: null,
      );
    }
  }

  /// Server hamesha { code, message, isSuccess, data } shape me deta hai,
  /// isliye yaha se automatically unwrap karke ApiResponse bana rahe hai.
  ApiResponse<T> _parseResponse<T>(
    Response response,
    T Function(dynamic json)? fromJson,
  ) {
    final resBody = response.data;

    if (resBody is Map<String, dynamic>) {
      final bool success = resBody['isSuccess'] == true;
      final String message = resBody['message']?.toString() ?? '';
      final int? code = resBody['code'] is int ? resBody['code'] as int : response.statusCode;
      final dynamic rawData = resBody['data'];

      T? parsedData;
      if (rawData != null) {
        parsedData = fromJson != null ? fromJson(rawData) : rawData as T;
      }

      return ApiResponse<T>(
        isSuccess: success,
        message: message,
        code: code,
        data: parsedData,
      );
    }

    // Fallback: agar response Map na ho (rare case)
    return ApiResponse<T>(
      isSuccess: response.statusCode == 200,
      message: '',
      code: response.statusCode,
      data: fromJson != null ? fromJson(resBody) : resBody as T?,
    );
  }

  String _handleDioError(DioException e) {
    // Backend agar error ke sath bhi { message: "..." } bhejta hai to wahi dikhao
    if (e.response?.data is Map && (e.response?.data as Map)['message'] != null) {
      return (e.response?.data as Map)['message'].toString();
    }

    switch (e.type) {
case DioExceptionType.connectionTimeout:
case DioExceptionType.sendTimeout:
case DioExceptionType.receiveTimeout:
return 'The server is taking too long to respond. Please try again.';

case DioExceptionType.connectionError:
return 'Please check your internet connection and try again.';

case DioExceptionType.badCertificate:
return 'A security certificate error occurred. Please try again later.';

case DioExceptionType.cancel:
return 'The request was cancelled.';

case DioExceptionType.badResponse:
return 'Server error (${e.response?.statusCode ?? 'Unknown'}). Please try again.';

case DioExceptionType.unknown:
if (e.error is SocketException) {
return 'Please check your internet connection and try again.';
}
return e.message ?? 'Something went wrong. Please try again.';

case DioExceptionType.transformTimeout:
return 'The server response could not be processed in time. Please try again.';
}}

  /// Login/Register ke baad token save karne ke liye helper.
  void saveToken(String token) => _storage.write('token', token);

  /// Logout / token clear karne ke liye helper.
  void clearToken() => _storage.remove('token');

  String? get token => _storage.read('token');
}
