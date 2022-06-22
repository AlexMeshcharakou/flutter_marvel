import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:marvel/data/models/local_models/local_character.dart';

import 'presentation/navigation/route_generator.dart';
import 'presentation/features/heroes/heroes_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initHive();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HeroesPage(),
      onGenerateRoute: RouteGenerator.generateRoute,
    ),
  );
}

Future<void> _initHive() async {
  await Hive.initFlutter();
  Hive.registerAdapter<LocalCharacter>(LocalCharacterAdapter());
  await Hive.openBox('characters');
}
