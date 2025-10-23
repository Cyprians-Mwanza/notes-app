import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes_app/presentation/cubits/auth_cubit/auth_cubit.dart';
import 'package:notes_app/presentation/cubits/note_cubit/note_cubit.dart';
import 'package:notes_app/presentation/pages/auth/login_page.dart';
import 'package:notes_app/presentation/pages/notes/notes_page.dart';
import 'package:notes_app/presentation/pages/splash_page.dart';

import 'data/local/hive/hive_helper.dart';
import 'data/local/shared_prefs/shared_prefs_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await HiveHelper.init();

  // Initialize SharedPreferences
  await SharedPrefsHelper.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthCubit()),
        BlocProvider(create: (_) => NoteCubit()),
      ],
      child: MaterialApp(
        title: 'Improved Notes App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const SplashPage(),
        routes: {
          '/login': (context) => const LoginPage(),
          '/notes': (context) => const NotesPage(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}