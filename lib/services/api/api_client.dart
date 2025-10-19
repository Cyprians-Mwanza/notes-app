import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../models/note.dart';
import '../../models/user.dart';

part 'api_client.g.dart';

@RestApi(baseUrl: "https://yourapi.com/api")
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;

  @POST("/signup")
  Future<User> signup(@Body() Map<String, dynamic> body);

  @POST("/login")
  Future<User> login(@Body() Map<String, dynamic> body);

  @GET("/notes")
  Future<List<Note>> getNotes();

  @POST("/notes")
  Future<Note> addNote(@Body() Note note);

  @PUT("/notes/{id}")
  Future<Note> updateNote(@Path("id") int id, @Body() Note note);

  @DELETE("/notes/{id}")
  Future<void> deleteNoteById(@Path("id") int id);
}
