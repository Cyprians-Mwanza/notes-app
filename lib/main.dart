import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cubits/auth_cubit.dart';
import 'cubits/note_cubit.dart';
import 'services/local/hive_helper.dart';
import 'app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveHelper().init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AppRouter _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthCubit()),
        BlocProvider(create: (_) => NoteCubit()),
      ],
      child: MaterialApp(
        title: 'Secure Notes',
        theme: ThemeData(primarySwatch: Colors.indigo),
        onGenerateRoute: _appRouter.onGenerateRoute,
        initialRoute: '/login',
      ),
    );
  }
}
