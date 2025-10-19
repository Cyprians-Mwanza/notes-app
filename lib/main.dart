import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'services/local/hive_helper.dart';
import 'cubits/auth_cubit.dart';
import 'cubits/note_cubit.dart';
import 'screens/notes_page.dart';
import 'screens/login_page.dart';
import 'services/local/prefs_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveHelper.init();
  final loggedIn = await PrefsHelper.isLoggedIn();

  runApp(MyApp(isLoggedIn: loggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthCubit()),
        BlocProvider(create: (_) => NoteCubit()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: isLoggedIn ? const NotesPage() : const LoginPage(),
      ),
    );
  }
}
