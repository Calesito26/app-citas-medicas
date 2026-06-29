import 'package:flutter/material.dart';
import '../db/database_helper.dart';

class ReportesVista extends StatefulWidget {
  const ReportesVista({super.key});

  @override
  State<ReportesVista> createState() => _ReportesVistaState();
}

class _ReportesVistaState extends State<ReportesVista> {
  List<Map<String, dynamic>> especialidades = [];
  List<Map<String, dynamic>> citas = [];

  int? especialidadSeleccionada;
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarEspecialidades();
  }

  Future<void> cargarEspecialidades() async {
    final datos = await DatabaseHelper.instancia.listarEspecialidades();

    if (!mounted) return;
    setState(() {
      especialidades = datos;
      cargando = false;
    });
  }

  Future<void> cargarReporte(int especialidadId) async {
    final datos = await DatabaseHelper.instancia.listarCitasPorEspecialidad(
      especialidadId,
    );

    if (!mounted) return;
    setState(() {
      citas = datos;
    });
  }

  Future<void> anular(int citaId) async {
    final actualizado = await DatabaseHelper.instancia.anularCita(citaId);

    if (especialidadSeleccionada != null) {
      await cargarReporte(especialidadSeleccionada!);
    }

    _mostrarMensaje(
      actualizado > 0 ? 'Cita anulada.' : 'La cita ya no se puede anular.',
    );
  }

  void _mostrarMensaje(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  Color colorEstado(String estado) {
    if (estado == 'Atendida') return Colors.green.shade700;
    if (estado == 'Anulada') return Colors.red.shade700;
    return Colors.orange.shade800;
  }

  IconData iconoEstado(String estado) {
    if (estado == 'Atendida') return Icons.check_circle;
    if (estado == 'Anulada') return Icons.cancel;
    return Icons.schedule;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reportes')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: DropdownButtonFormField<int>(
                  initialValue: especialidadSeleccionada,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Seleccionar especialidad',
                    prefixIcon: Icon(Icons.local_hospital),
                  ),
                  items: especialidades.map((esp) {
                    return DropdownMenuItem<int>(
                      value: esp['id'],
                      child: Text(esp['nombre']),
                    );
                  }).toList(),
                  onChanged: especialidades.isEmpty
                      ? null
                      : (valor) {
                          setState(() {
                            especialidadSeleccionada = valor;
                            citas = [];
                          });

                          if (valor != null) {
                            cargarReporte(valor);
                          }
                        },
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (cargando)
              const Center(child: CircularProgressIndicator())
            else if (especialidades.isEmpty)
              const _EstadoVacio(
                icono: Icons.folder_off,
                texto: 'No hay especialidades registradas.',
              )
            else if (especialidadSeleccionada == null)
              const _EstadoVacio(
                icono: Icons.touch_app,
                texto: 'Selecciona una especialidad para ver sus citas.',
              )
            else if (citas.isEmpty)
              const _EstadoVacio(
                icono: Icons.event_busy,
                texto: 'No hay citas para mostrar.',
              )
            else
              ...citas.map((cita) {
                final estado = cita['estado'] as String;
                final color = colorEstado(estado);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Card(
                    child: ListTile(
                      leading: Icon(iconoEstado(estado), color: color),
                      title: Text(
                        cita['paciente'],
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text('Hora: ${cita['hora']}'),
                      trailing: estado == 'Registrada'
                          ? IconButton(
                              tooltip: 'Anular cita',
                              icon: const Icon(Icons.cancel_outlined),
                              color: Colors.red.shade700,
                              onPressed: () => anular(cita['id'] as int),
                            )
                          : Text(
                              estado,
                              style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _EstadoVacio extends StatelessWidget {
  const _EstadoVacio({required this.icono, required this.texto});

  final IconData icono;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(icono, size: 42, color: Colors.grey.shade500),
          const SizedBox(height: 10),
          Text(
            texto,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }
}
