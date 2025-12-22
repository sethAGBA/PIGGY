import 'package:flutter/material.dart';

import 'views/finance_home_page.dart';

void main() {
  runApp(const PiggyApp());
}

class PiggyApp extends StatelessWidget {
  const PiggyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PIGGY',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F766E)),
        useMaterial3: true,
      ),
      home: const FinanceHomePage(),
    );
  }
}
