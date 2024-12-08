import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/proyecto.dart';
import '../serviceCPM.dart';


class CriticalPathScreen extends StatefulWidget {
  @override
  _CriticalPathScreenState createState() => _CriticalPathScreenState();
}

class _CriticalPathScreenState extends State<CriticalPathScreen> {
  late Future<List<Tarea>> _tareasFuture;

  @override
  void initState() {
    super.initState();
    _tareasFuture = ApiService.obtenerSubtareas();  // Llamada al API
  }

  Tarea? hoveredTarea;
  Offset? cursorPosition;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text("Diagrama de Tareas del Proyecto"),
      ),
      body: FutureBuilder<List<Tarea>>(
        future: _tareasFuture, // Llamada a la función que obtiene las tareas
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No se encontraron tareas"));
          }

          final tareas = snapshot.data!;

          // Primero, calculamos la ruta crítica de las tareas
          Map<int, Tarea> tareasMap = {for (var t in tareas) t.id: t};
          tareas.forEach((tarea) => tarea.calcularRutaCritica(tareasMap));

          // Calcular las tareas críticas
          final List<Tarea> rutaCritica = tareas
              .where((t) => t.holgura == 0)
              .toList(); // Las tareas críticas tienen holgura 0

          final List<int> idsRutaCritica = rutaCritica.map((t) => t.id).toList();

          // Crear el grafo de tareas
          final graph = Graph();
          Map<int, Node> nodes = {};
          for (var tarea in tareas) {
            nodes[tarea.id] = Node.Id(tarea.id);
          }

          // Agregar dependencias entre nodos
          for (var tarea in tareas) {
            for (var dependenciaId in tarea.dependencias) {
              graph.addEdge(nodes[dependenciaId]!, nodes[tarea.id]!);
            }
          }

          final builder = SugiyamaConfiguration()
            ..orientation = SugiyamaConfiguration.ORIENTATION_LEFT_RIGHT;

          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: InteractiveViewer(
                  constrained: false,
                  boundaryMargin: EdgeInsets.all(20),
                  child: GraphView(
                    graph: graph,
                    algorithm: SugiyamaAlgorithm(builder),
                    builder: (Node node) {
                      var tareaId = node.key?.value as int;
                      var tarea =
                          tareas.firstWhere((t) => t.id == tareaId);

                      return MouseRegion(
                        onHover: (event) {
                          setState(() {
                            cursorPosition = event.position;
                            hoveredTarea = tarea;
                          });
                        },
                        onExit: (_) {
                          setState(() {
                            hoveredTarea = null;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: idsRutaCritica.contains(tarea.id)
                                ? Colors.red
                                : Colors.blue,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            tarea.nombre,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              if (hoveredTarea != null && cursorPosition != null)
                Positioned(
                  left: _calculateTooltipX(cursorPosition!.dx, screenSize.width),
                  top: _calculateTooltipY(cursorPosition!.dy, screenSize.height),
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Detalles de ${hoveredTarea!.nombre}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            "Temprano Inicio (TI): ${hoveredTarea!.tempranoInicio.toStringAsFixed(2)}",
                            style: TextStyle(color: Colors.black),
                          ),
                          Text(
                            "Temprano Fin (TF): ${hoveredTarea!.tempranoFin.toStringAsFixed(2)}",
                            style: TextStyle(color: Colors.black),
                          ),
                          Text(
                            "Tardío Inicio (TIL): ${hoveredTarea!.tardioInicio.toStringAsFixed(2)}",
                            style: TextStyle(color: Colors.black),
                          ),
                          Text(
                            "Tardío Fin (TFL): ${hoveredTarea!.tardioFin.toStringAsFixed(2)}",
                            style: TextStyle(color: Colors.black),
                          ),
                          Text(
                            "Holgura: ${hoveredTarea!.holgura.toStringAsFixed(2)}",
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  double _calculateTooltipX(double cursorX, double screenWidth) {
    const double tooltipWidth = 120;
    const double margin = 10;
    if (cursorX + tooltipWidth + margin > screenWidth) {
      return screenWidth - tooltipWidth - margin;
    }
    return cursorX + 10;
  }

  double _calculateTooltipY(double cursorY, double screenHeight) {
    const double tooltipHeight = 100;
    const double margin = 10;
    if (cursorY + tooltipHeight + margin > screenHeight) {
      return screenHeight - tooltipHeight - margin;
    }
    return cursorY + 10;
  }
}
