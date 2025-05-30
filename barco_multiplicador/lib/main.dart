import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'constants/colors.dart';
import 'models/game_model.dart';
import 'screens/game_screen.dart';
import 'services/audio_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Forzar orientación horizontal
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Ocultar barra de estado y barra de navegación para pantalla completa
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // Inicializar servicios
  final audioService = AudioService();
  await audioService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GameModel(),
      child: MaterialApp(
        title: 'Barco Multiplicador',
        theme: ThemeData(
          primaryColor: AppColors.blackPearl,
          scaffoldBackgroundColor: AppColors.blackPearl,
          fontFamily: 'PressStart2P',
          colorScheme: ColorScheme.dark(
            primary: AppColors.java,
            secondary: AppColors.funBlue,
            surface: AppColors.blackPearl,
            background: AppColors.blackPearl,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.blackPearl,
            elevation: 0,
            titleTextStyle: TextStyle(
              fontFamily: 'PressStart2P',
              fontSize: 16,
              color: AppColors.white,
            ),
          ),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(
              fontFamily: 'PressStart2P',
              color: AppColors.white,
              fontSize: 14,
            ),
            bodyMedium: TextStyle(
              fontFamily: 'PressStart2P',
              color: AppColors.white,
              fontSize: 12,
            ),
            titleLarge: TextStyle(
              fontFamily: 'PressStart2P',
              color: AppColors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            titleMedium: TextStyle(
              fontFamily: 'PressStart2P',
              color: AppColors.white,
              fontSize: 14,
            ),
            titleSmall: TextStyle(
              fontFamily: 'PressStart2P',
              color: AppColors.white,
              fontSize: 12,
            ),
            labelLarge: TextStyle(
              fontFamily: 'PressStart2P',
              color: AppColors.white,
              fontSize: 12,
            ),
          ),
          useMaterial3: true,
        ),
        home: const GameScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
