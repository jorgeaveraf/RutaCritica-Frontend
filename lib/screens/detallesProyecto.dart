import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DetallesProyecto extends StatefulWidget {
  final String nombreProyecto;
  final String descripcionProyecto;

  DetallesProyecto({
    required this.nombreProyecto,
    required this.descripcionProyecto,
  });

  @override
  _DetallesProyectoState createState() => _DetallesProyectoState();
}

class _DetallesProyectoState extends State<DetallesProyecto> {
  List<Map<String, dynamic>> subtareas = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _cargarSubtareas();
  }

  Future<void> _cargarSubtareas() async {
    final uri = Uri.parse('http://127.0.0.1:8000/rutaCritica/subtareas');
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['estado'] == 'exito') {
          setState(() {
            subtareas = List<Map<String, dynamic>>.from(
              data['subtareas'].map((subtarea) {
                return {
                  'nombre': subtarea['nombre'],
                  'tiempoEstimado': (subtarea['tiempoEstimado'] ?? 0.0) is double
                      ? subtarea['tiempoEstimado']
                      : double.tryParse(subtarea['tiempoEstimado'].toString()) ?? 0.0,
                  'tiempoReal': subtarea['tiempoReal'],
                };
              }),
            );
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = 'Error al cargar subtareas: ${data['detalle']}';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Error al conectar con el servidor: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error al cargar subtareas: $e';
        isLoading = false;
      });
    }
  }

  void asignarTiempoReal(int index, double tiempoReal) {
    setState(() {
      subtareas[index]['tiempoReal'] = tiempoReal;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles del Proyecto'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage, style: TextStyle(color: Colors.red)))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.nombreProyecto,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(widget.descripcionProyecto, style: TextStyle(fontSize: 16)),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              // Navegar o mostrar análisis PERT
                            },
                            child: Text('Ver Análisis PERT'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // Navegar o mostrar ruta crítica
                            },
                            child: Text('Ver Ruta Crítica'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // Navegar o mostrar reportes
                            },
                            child: Text('Ver Reportes'),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          itemCount: subtareas.length,
                          itemBuilder: (context, index) {
                            final subtarea = subtareas[index];
                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                title: Text('Subtarea: ${subtarea['nombre']}'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Tiempo estimado: ${subtarea['tiempoEstimado'] != null ? subtarea['tiempoEstimado'].toStringAsFixed(1) : 'No definido'} horas',
                                    ),
                                    Text(
                                      'Tiempo real: ${subtarea['tiempoReal'] != null ? subtarea['tiempoReal'].toString() : 'N/A'} horas',
                                    ),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () async {
                                    final tiempo = await showDialog<double>(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return TiempoRealDialog(
                                          subtarea: subtarea,
                                        );
                                      },
                                    );

                                    if (tiempo != null) {
                                      asignarTiempoReal(index, tiempo);
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

class TiempoRealDialog extends StatefulWidget {
  final Map<String, dynamic> subtarea;

  TiempoRealDialog({required this.subtarea});

  @override
  _TiempoRealDialogState createState() => _TiempoRealDialogState();
}

class _TiempoRealDialogState extends State<TiempoRealDialog> {
  final TextEditingController _tiempoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Asignar Tiempo Real'),
      content: TextField(
        controller: _tiempoController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: 'Tiempo Real (horas)',
          hintText: 'Ejemplo: 2.5',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Cerrar sin guardar
          },
          child: Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            final tiempoReal = double.tryParse(_tiempoController.text);
            if (tiempoReal != null && tiempoReal >= 0) {
              Navigator.of(context).pop(tiempoReal);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Por favor, ingresa un tiempo válido.')),
              );
            }
          },
          child: Text('Guardar'),
        ),
      ],
    );
  }
}
