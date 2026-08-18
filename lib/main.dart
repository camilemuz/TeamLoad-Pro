import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/training_load/data/repositories/training_load_repository_impl.dart';
import 'features/training_load/presentation/providers/training_load_provider.dart';
import 'features/settings/data/repositories/settings_repository_impl.dart';
import 'features/settings/presentation/providers/settings_provider.dart';
import 'features/training_load/presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDateFormatting('es', null);
  runApp(const TeamLoadProApp());
}

class TeamLoadProApp extends StatelessWidget {
  const TeamLoadProApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepo = AuthRepositoryImpl(auth: FirebaseAuth.instance);
    final trainingRepo = TrainingLoadRepositoryImpl();
    final settingsRepo = SettingsRepositoryImpl();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AppAuthProvider(repository: authRepo)..init(),
        ),
        ChangeNotifierProvider(
          create: (_) => TrainingLoadProvider(repository: trainingRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(repository: settingsRepo)..loadSettings(),
        ),
      ],
      child: MaterialApp(
        title: 'TeamLoad Pro',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const HomeScreen(),
      ),
    );
  }
}
