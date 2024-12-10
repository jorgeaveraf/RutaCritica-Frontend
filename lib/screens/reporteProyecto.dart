import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ReporteProyecto extends StatefulWidget {
  @override
  _ReporteProyectoState createState() => _ReporteProyectoState();
}

class _ReporteProyectoState extends State<ReporteProyecto> {
  Map<String, dynamic> _proyecto = {};
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchProyecto();
  }

  Future<void> _fetchProyecto() async {
    final String apiUrl = "http://localhost:8000/rutaCritica/calculos"; // Cambia esta URL
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _proyecto = data["proyecto"];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Error al obtener los datos: ${response.reasonPhrase}';
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reporte del Proyecto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _errorMessage.isNotEmpty
                ? Center(
                    child: Text(
                      _errorMessage,
                      style: TextStyle(color: Colors.red),
                    ),
                  )
                : _buildProyectoDetails(),
      ),
    );
  }

  Widget _buildProyectoDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resumen del Proyecto',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        _buildDetailRow("Tiempo Optimista:", _proyecto["tiempo_optimista_proyecto"]),
        _buildDetailRow("Tiempo Pesimista:", _proyecto["tiempo_pesimista_proyecto"]),
        _buildDetailRow("Desviación Estándar:", _proyecto["desviacion_estandar_total"]),
        _buildDetailRow("PERT Total:", _proyecto["pert_total"]),
      ],
    );
  }

  Widget _buildDetailRow(String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 8),
          Text(value != null ? value.toString() : "N/A"),
        ],
      ),
    );
  }
}
