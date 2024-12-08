class Tarea {
  final int id;
  final String nombre;
  final int tiempo;
  final List<int> dependencias;
  late double tempranoInicio;
  late double tempranoFin;
  late double tardioInicio;
  late double tardioFin;
  late double holgura;

  Tarea({
    required this.id,
    required this.nombre,
    required this.tiempo,
    required this.dependencias,
  });

  // Método para calcular la ruta crítica
  void calcularRutaCritica(Map<int, Tarea> tareas) {
    // Calcular el inicio y fin temprano de cada tarea
    tempranoInicio = 0;
    tempranoFin = tempranoInicio + tiempo;
    tardioFin = tempranoFin;
    tardioInicio = tardioFin - tiempo;

    // Holgura (tiempo de margen para no retrasar el proyecto)
    holgura = tardioInicio - tempranoInicio;
  }
}
