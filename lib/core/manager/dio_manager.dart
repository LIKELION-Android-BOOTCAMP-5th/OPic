import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DioManager {
  static final DioManager shared = DioManager._internal();

  factory DioManager() => shared;

  DioManager._internal();

  static const String _baseUrl =
      'https://zoqxnpklgtcqkvskarls.supabase.co/rest/v1';
  static const String _apiKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpvcXhucGtsZ3RjcWt2c2thcmxzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI0OTk4NTYsImV4cCI6MjA3ODA3NTg1Nn0.qR8GmGNztCm44qqm7xJK4VvmI1RcIJybGKeMVBy8yaA';

  late final _dio = _createDio();

  Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://zoqxnpklgtcqkvskarls.supabase.co/rest/v1',
        headers: {
          'apikey':
              'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpvcXhucGtsZ3RjcWt2c2thcmxzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI0OTk4NTYsImV4cCI6MjA3ODA3NTg1Nn0.qR8GmGNztCm44qqm7xJK4VvmI1RcIJybGKeMVBy8yaA',
          'Content-Type': 'application/json',
        },
      ),
    );

    dio.interceptors.add(_createAuthInterceptor());

    return dio;
  }

  InterceptorsWrapper _createAuthInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        final session = Supabase.instance.client.auth.currentSession;

        if (session != null) {
          options.headers['Authorization'] = 'Bearer ${session.accessToken}';
        }

        handler.next(options);
      },
    );
  }

  Dio get dio => _dio;
}
