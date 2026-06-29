class Cita {
  int? id;
  String paciente;
  int especialidadId;
  String hora;
  String estado;

  Cita({
    this.id,
    required this.paciente,
    required this.especialidadId,
    required this.hora,
    required this.estado,
  });
}
