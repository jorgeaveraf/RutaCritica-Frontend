import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'detallesProyecto.dart'; // Importa la pantalla de detalles

class CrearProyecto extends StatefulWidget {
  @override
  _CrearProyectoState createState() => _CrearProyectoState();
}

class _CrearProyectoState extends State<CrearProyecto> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  Uint8List? _csvBytes;
  String _message = '';

  Future<void> _cargarCsv() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null) {
      setState(() {
        _csvBytes = result.files.single.bytes;
        _message = 'Archivo cargado exitosamente';
      });

      await _validarCsv();
    }
  }

  Future<void> _validarCsv() async {
    if (_csvBytes == null) {
      setState(() {
        _message = 'No se ha seleccionado ningún archivo CSV.';
      });
      return;
    }

    final uri = Uri.parse('http://127.0.0.1:8000/rutaCritica/validar_proyecto');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(http.MultipartFile.fromBytes('file', _csvBytes!, filename: 'archivo.csv'));

    try {
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final data = jsonDecode(responseData);

      if (data['estado'] == 'error') {
        setState(() {
          _message = 'Errores: ${data['errores']}';
        });
      } else {
        setState(() {
          _message = 'Archivo CSV validado con éxito';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Error al validar el archivo: $e';
      });
    }
  }

  Future<void> _crearProyecto() async {
    if (_csvBytes == null) {
      setState(() {
        _message = 'No se ha seleccionado ningún archivo CSV.';
      });
      return;
    }

    final uri = Uri.parse('http://127.0.0.1:8000/rutaCritica/crear_proyecto_desde_csv');
    final request = http.MultipartRequest('POST', uri)
      ..fields['nombre_proyecto'] = _nombreController.text
      ..fields['descripcion'] = _descripcionController.text
      ..files.add(http.MultipartFile.fromBytes('file', _csvBytes!, filename: 'archivo.csv'));

    try {
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final data = jsonDecode(responseData);

      if (data['estado'] == 'error') {
        setState(() {
          _message = 'Errores al crear proyecto: ${data['errores']}';
        });
      } else {
        setState(() {
          _message = 'Proyecto creado con éxito!';
        });

        // Navegar a la pantalla de detalles del proyecto si la creación es exitosa
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetallesProyecto(
              nombreProyecto: _nombreController.text,
              descripcionProyecto: _descripcionController.text,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _message = 'Error al crear el proyecto: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear Proyecto desde CSV'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nombreController,
              decoration: InputDecoration(labelText: 'Nombre del Proyecto'),
            ),
            TextField(
              controller: _descripcionController,
              decoration: InputDecoration(labelText: 'Descripción del Proyecto'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _cargarCsv,
              child: Text('Cargar CSV'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _crearProyecto,
              child: Text('Crear Proyecto'),
            ),
            SizedBox(height: 20),
            Text(
              _message,
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
