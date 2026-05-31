import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo.shade50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo, Colors.indigoAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text('About', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 8),
            CircleAvatar(
              radius: 40,
              backgroundImage: const AssetImage('assets/images/arnob.jpeg'),
              backgroundColor: Colors.transparent,
            ),
            const SizedBox(height: 16),
            const Text(
              'StudentFlow App',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Version 1.0.0'),
            const SizedBox(height: 20),
            const Text(
              'Developed by',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Arnob Das',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'B.Sc. in Computer Science & Engineering\nDaffodil International University',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text('Flutter Developer'),
            const SizedBox(height: 20),
            const Text(
              'This application was developed to help teachers\nmanage students, exams, results, and performance\nanalytics efficiently.',
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            SafeArea(
              bottom: true,
              child: const Text('© 2026 Arnob. All rights reserved.'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
