import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'services/game_state.dart';
import 'screens/menu_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: TruckiColors.black,
    ),
  );
  runApp(const TruckiApp());
}

class TruckiApp extends StatefulWidget {
  const TruckiApp({super.key});

  @override
  State<TruckiApp> createState() => _TruckiAppState();
}

class _TruckiAppState extends State<TruckiApp> {
  // GameState lives at the top of the tree so it persists across navigation
  final _gameState = GameState();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trucki',
      theme: TruckiTheme.theme,
      debugShowCheckedModeBanner: false,
      home: MenuScreen(gameState: _gameState),
    );
  }
}
