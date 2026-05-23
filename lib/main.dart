import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'services/sound_service.dart';
import 'view_models/main_view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final soundService = SoundService();
  final viewModel = MainViewModel(soundService);
  runApp(SafeTravelsApp(viewModel: viewModel));
}

class SafeTravelsApp extends StatelessWidget {
  final MainViewModel viewModel;

  const SafeTravelsApp({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ミミテック',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
      ),
      home: HomeScreen(viewModel: viewModel),
    );
  }
}
