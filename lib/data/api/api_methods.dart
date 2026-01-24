import 'package:dio/dio.dart';

class DioClient {
  late final Dio dio;

  DioClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: 'http://apxapi.somee.com/api/',
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('\x1B[34m➡️ REQUEST: ${options.method} ${options.uri}\x1B[0m');
          if (options.data != null) {
            print('\x1B[36mDATA: ${options.data}\x1B[0m'); 
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('\x1B[32m✅ RESPONSE [${response.statusCode}]: ${response.requestOptions.uri}\x1B[0m');
          print('\x1B[37mBODY: ${response.data}\x1B[0m');
          return handler.next(response);
        },
        onError: (error, handler) {
          print('\x1B[31m❌ ERROR [${error.response?.statusCode}]: ${error.requestOptions.uri}\x1B[0m');
          print('\x1B[33mMESSAGE: ${error.message}\x1B[0m');
          if (error.response?.data != null) {
            print('\x1B[37mBODY: ${error.response?.data}\x1B[0m'); 
          }
          return handler.next(error);
        },
      ),
    );
  }
}
