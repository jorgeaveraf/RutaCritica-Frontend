import 'dart:convert';
import 'package:http/http.dart' as http;

import 'models/proyecto.dart';

class ProyectoService {
  final String baseUrl;

  ProyectoService({required this.baseUrl});

  Future<ProyectoRemoto> fetchProyecto() async {
    final response = await http.get(Uri.parse('$baseUrl/rutaCritica/subtareasCPM'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ProyectoRemoto.fromJson(data);
    } else {
      throw Exception('Error al obtener las tareas: ${response.reasonPhrase}');
    }
  }
}
