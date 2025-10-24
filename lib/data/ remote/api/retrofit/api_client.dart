import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../../../core/constants/app_constants.dart';
import '../../models/api_note.dart';
part 'api_client.g.dart';

@RestApi(baseUrl: AppConstants.baseUrl)
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;

  static ApiClient create() {
    final dio = Dio();
    dio.options = BaseOptions(
      baseUrl: AppConstants.baseUrl,
      headers: {
        'Content-Type': 'application/json',
        'User-Agent': 'FlutterApp',
      },
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    );

    // Add the same interceptors you had before
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print(' Request: ${options.method} ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print(' Response: ${response.statusCode}');
          return handler.next(response);
        },
        onError: (error, handler) {
          print(' Error: ${error.message}');
          return handler.next(error);
        },
      ),
    );

    return ApiClient(dio);
  }

  // Note endpoints (using JSONPlaceholder posts as notes)
  @GET("/posts")
  Future<List<ApiNote>> getNotes();

  @GET("/posts/{id}")
  Future<ApiNote> getNoteById(@Path("id") int id);

  @POST("/posts")
  Future<ApiNote> createNote(@Body() ApiNote note);

  @PUT("/posts/{id}")
  Future<ApiNote> updateNote(@Path("id") int id, @Body() ApiNote note);

  @DELETE("/posts/{id}")
  Future<void> deleteNote(@Path("id") int id);
}