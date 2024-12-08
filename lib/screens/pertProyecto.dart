import 'dart:convert'; // Para manejar JSON
import 'package:flutter/material.dart'; // Widgets básicos
import 'package:http/http.dart' as http; // HTTP para peticiones

class PertProyecto extends StatefulWidget {
  @override
  _PertProyectoState createState() => _PertProyectoState();
}

class _PertProyectoState extends State<PertProyecto> {
  List<dynamic> _data = []; // Lista para almacenar los hitos
  bool _isLoading = true; // Estado de carga
  String _errorMessage = ''; // Mensaje de error, si ocurre

  // Función para consumir el endpoint
  Future<void> fetchCalculosTotales() async {
    const String url = 'http://127.0.0.1:8000/rutaCritica/calculos';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Decodificar el JSON recibido
        final decodedData = json.decode(response.body);

        // Verificar si contiene la clave 'hitos'
        if (decodedData is Map<String, dynamic> && decodedData.containsKey('hitos')) {
          setState(() {
            _data = decodedData['hitos'] as List<dynamic>;
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = 'Formato de datos inesperado';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Error al cargar los datos: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error de conexión: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCalculosTotales(); // Llamar a la API cuando el widget se inicializa
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PERT Proyecto'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // Spinner de carga
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red),
                  ),
                ) // Mensaje de error
              : ListView.builder(
                  itemCount: _data.length,
                  itemBuilder: (context, index) {
                    // Renderizar cada hito
                    final hito = _data[index];
                    return Card(
                      margin: EdgeInsets.all(10),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hito: ${hito['nombre'] ?? 'Sin nombre'}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text('Tiempo optimista total: ${hito['tiempo_optimista_total']}'),
                            Text('Tiempo pesimista total: ${hito['tiempo_pesimista_total']}'),
                            Text('Desviación estándar: ${hito['desviacion_estandar']}'),
                            Text('Varianza: ${hito['varianza']}'),
                            SizedBox(height: 10),
                            Text(
                              'Subtareas:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            ...List.generate(
                              (hito['subtareas'] as List<dynamic>).length,
                              (subTaskIndex) {
                                final subTarea = hito['subtareas'][subTaskIndex];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '- ${subTarea['nombre'] ?? 'Sin nombre'}',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      Text(
                                          '  Tiempo optimista: ${subTarea['tiempo_optimista']}'),
                                      Text(
                                          '  Tiempo pesimista: ${subTarea['tiempo_pesimista']}'),
                                      Text(
                                          '  Duración PERT: ${subTarea['duracion_pert']}'),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
