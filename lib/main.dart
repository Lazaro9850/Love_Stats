import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:love_stats_app/telas/tela_inicial.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LoveStats',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFA8072), // Salmon/Pinkish
          primary: const Color(0xFFFF6B6B),
          secondary: const Color(0xFFA29BFE),
          surface: Colors.white,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.poppins(
            color: const Color(0xFFFF6B6B),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFFF6B6B),
          foregroundColor: Colors.white,
        ),
      ),
      home: PaginaInicial(),
    );
  }
}
