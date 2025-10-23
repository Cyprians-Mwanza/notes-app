import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:notes_app/models/note.dart';
import 'package:notes_app/models/user.dart';

part 'api_client.g.dart';

@RestApi(baseUrl: "https://jsonplaceholder.typicode.com")
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;

  // Auth endpoints (using HttpResponse to access metadata)
  @POST("/login")
  Future<HttpResponse<User>> login(@Body() Map<String, dynamic> data);

  @POST("/signup")
  Future<HttpResponse<User>> signup(@Body() Map<String, dynamic> data);

  // Notes endpoints
  @GET("/notes")
  Future<HttpResponse<List<Note>>> getNotes();

  @POST("/notes")
  Future<HttpResponse<Note>> createNote(@Body() Map<String, dynamic> data);

  @PUT("/notes/{id}")
  Future<HttpResponse<Note>> updateNote(
      @Path("id") String id,
      @Body() Map<String, dynamic> data,
      );

  @DELETE("/notes/{id}")
  Future<HttpResponse<void>> deleteNote(@Path("id") String id);
}

Dio createDioClient() {
  final dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
    headers: {"Content-Type": "application/json"},
  ));

  dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
  return dio;
}
