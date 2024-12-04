import 'package:flutter/material.dart';
import 'screens/crearProyecto.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Crear Proyecto',
      home: CrearProyecto(),
    );
  }
}
