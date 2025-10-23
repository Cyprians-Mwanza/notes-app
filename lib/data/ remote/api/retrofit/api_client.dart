import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../../models/note.dart';

part 'api_client.g.dart';

// Try a different API if JSONPlaceholder has issues
@RestApi(baseUrl: "https://jsonplaceholder.typicode.com/")
// @RestApi(baseUrl: "https://api.npoint.io/") // Alternative API
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;

  // Note endpoints (using JSONPlaceholder posts as notes)
  @GET("posts")
  Future<List<Note>> getNotes();

  @GET("posts/{id}")
  Future<Note> getNoteById(@Path("id") int id);

  @POST("posts")
  Future<Note> createNote(@Body() Note note);

  @PUT("posts/{id}")
  Future<Note> updateNote(@Path("id") int id, @Body() Note note);

  @DELETE("posts/{id}")
  Future<void> deleteNote(@Path("id") int id);
}