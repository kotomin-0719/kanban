
import 'package:flutter/material.dart';
import 'view.dart';
import 'view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final vm = KanbanViewModel();
  await vm.load();

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Study Flow',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF526A87),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 14,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: KanbanView(vm),
    ),
  );
}
