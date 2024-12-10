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

    // Convertir la respuesta a una lista de tareas usando Tarea.fromJson
    return (data['subtareas'] as List)
        .map((tareaData) => Tarea.fromJson(tareaData))
        .toList();
  } else {
    throw Exception("Error al cargar las subtareas");
  }
}
/* static Future<List<Tarea>> obtenerSubtareas() async {
  final jsonHardcode = {
    "subtareas": [
      {
        "subtarea_id_csv": "1",
        "nombre": "Inicio del proyecto",
        "tiempo_probable": 5,
        "dependencia_id": []
      },
      {
        "subtarea_id_csv": "2",
        "nombre": "Planificación",
        "tiempo_probable": 3,
        "dependencia_id": ["1"]
      },
      {
        "subtarea_id_csv": "3",
        "nombre": "Diseño preliminar",
        "tiempo_probable": 7,
        "dependencia_id": ["1"]
      },
      {
        "subtarea_id_csv": "4",
        "nombre": "Desarrollo inicial",
        "tiempo_probable": 10,
        "dependencia_id": ["2", "3"]
      },
      {
        "subtarea_id_csv": "5",
        "nombre": "Pruebas y validación",
        "tiempo_probable": 8,
        "dependencia_id": ["4"]
      },
      {
        "subtarea_id_csv": "6",
        "nombre": "Entrega final",
        "tiempo_probable": 2,
        "dependencia_id": ["5"]
      }
    ]
  };

  // Convertir el JSON hardcodeado a una lista de tareas
  return (jsonHardcode['subtareas'] as List)
      .map((tareaData) => Tarea.fromJson(tareaData))
      .toList();
}
 */
}
