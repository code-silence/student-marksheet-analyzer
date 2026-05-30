import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/student_provider.dart';
import 'data/local/hive_service.dart';
import 'providers/batch_provider.dart';
import 'screens/home/home_screen.dart';
import 'providers/exam_provider.dart';
import 'providers/exam_session_provider.dart';
import 'providers/result_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HiveService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BatchProvider()), // Add BatchProvider
        ChangeNotifierProvider(create: (_) => StudentProvider()), // Add StudentProvider
        ChangeNotifierProvider(create: (_) => ExamProvider()),// Add ExamProvider
        ChangeNotifierProvider(create: (_) => ExamSessionProvider()), // Add ExamSessionProvider
        ChangeNotifierProvider(create: (_) => ResultProvider()), // Add ResultProvider
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Student Analyzer',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: const HomeScreen(),
    );
  }
}
