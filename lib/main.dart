import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webtoon_second_try/screens/home_screen.dart';
import 'package:webtoon_second_try/services/api_service.dart';

void main() {
  ApiServer.getToons();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        textTheme: TextTheme(
          titleLarge: GoogleFonts.dynaPuff(
            fontSize: 25,
            fontWeight: FontWeight.w500,
            color: Colors.green,
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
    // TODO: implement build
    throw UnimplementedError();
  }
}
