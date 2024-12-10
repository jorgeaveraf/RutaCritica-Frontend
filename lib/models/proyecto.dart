class Tarea {
  final int id;
  final String nombre;
  final int tiempo;
  final List<int> dependencias;

  // Inicialización con valores predeterminados para evitar errores de LateInitializationError
  double tempranoInicio = 0.0;
  double tempranoFin = 0.0;
  double tardioInicio = 0.0;
  double tardioFin = 0.0;
  double holgura = 0.0;

  // Constructor ajustado con valores predeterminados
  Tarea({
    required this.id,
    required this.nombre,
    required this.tiempo,
    this.dependencias = const [], // Lista vacía como valor predeterminado
  });

  // Método factory para deserializar JSON
  factory Tarea.fromJson(Map<String, dynamic> json) {
    return Tarea(
      id: int.tryParse(json['subtarea_id_csv']?.toString() ?? '') ?? 0, // Manejar ID nulo o formato incorrecto
      nombre: json['nombre'] ?? 'Sin nombre', // Asignar un valor predeterminado si el nombre es nulo
      tiempo: (json['tiempo_probable'] as num?)?.toInt() ?? 0, // Asegurar que tiempo_probable sea un int
      dependencias: (json['dependencia_id'] as List<dynamic>?)
              ?.map((e) => int.tryParse(e.toString()) ?? 0)
              .toList() ??
          [], // Convertir dependencias y manejar valores nulos
    );
  }

  // Método opcional para convertir la tarea a JSON (útil si necesitas enviar datos al backend)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'tiempo': tiempo,
      'dependencias': dependencias,
    };
  }

  // Método para calcular la ruta crítica
void calcularRutaCritica(Map<int, Tarea> tareas, [double? tardioFinProyecto]) {
  // Calcular tempranoInicio y tempranoFin (hacia adelante)
  tempranoInicio = 0.0;

  for (var dependenciaId in dependencias) {
    if (tareas.containsKey(dependenciaId)) {
      var tareaDependencia = tareas[dependenciaId]!;
      tempranoInicio = tareaDependencia.tempranoFin > tempranoInicio
          ? tareaDependencia.tempranoFin
          : tempranoInicio;
    }
  }
  tempranoFin = tempranoInicio + tiempo;

  // Cálculo inicial de tardioFin y tardioInicio (hacia atrás)
  if (tardioFinProyecto != null) {
    tardioFin = tardioFinProyecto;
  } else {
    tardioFin = tareas.values.map((t) => t.tempranoFin).reduce((a, b) => a > b ? a : b);
  }

  tardioInicio = tardioFin - tiempo;

  // Propagar hacia atrás: Ajustar tardioInicio y tardioFin de las tareas dependientes
  for (var dependenciaId in dependencias) {
    if (tareas.containsKey(dependenciaId)) {
      var tareaDependencia = tareas[dependenciaId]!;
      if (tardioInicio < tareaDependencia.tardioFin || tareaDependencia.tardioFin == 0) {
        tareaDependencia.calcularRutaCritica(tareas, tardioInicio);
      }
    }
  }

  // Calcular holgura
  holgura = tardioInicio - tempranoInicio;
}


}
