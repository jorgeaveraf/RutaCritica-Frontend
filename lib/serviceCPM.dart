import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models/proyecto.dart';

class ApiService {
  static const String _baseUrl = "http://localhost:8000"; // Cambia esta URL a la de tu backend

  // Método para obtener las subtareas del backend
  static Future<List<Tarea>> obtenerSubtareas() async {
    final response = await http.get(Uri.parse("$_baseUrl/rutaCritica/subtareasCPM"));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Convertir la respuesta a una lista de tareas
      List<Tarea> tareas = [];
      for (var tareaData in data['subtareas']) {
        tareas.add(Tarea(
          id: tareaData['subtarea_id'],
          nombre: tareaData['nombre'],
          tiempo: tareaData['tiempo_probable'],
          dependencias: List<int>.from(tareaData['dependencias']),
        ));
      }

      return tareas;
    } else {
      throw Exception("Error al cargar las subtareas");
    }
  }
}
