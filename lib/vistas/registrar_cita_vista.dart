import 'package:flutter/material.dart';
import '../db/database_helper.dart';

class RegistrarCitaVista extends StatefulWidget {
  const RegistrarCitaVista({super.key});

  @override
  State<RegistrarCitaVista> createState() => _RegistrarCitaVistaState();
}

class _RegistrarCitaVistaState extends State<RegistrarCitaVista> {
  final pacienteController = TextEditingController();
  final horaController = TextEditingController();

  List<Map<String, dynamic>> especialidades = [];
  int? especialidadSeleccionada;
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarEspecialidades();
  }

  @override
  void dispose() {
    pacienteController.dispose();
    horaController.dispose();
    super.dispose();
  }

  Future<void> cargarEspecialidades() async {
    try {
      final datos = await DatabaseHelper.instancia
          .listarEspecialidadesDisponibles();

      if (!mounted) return;
      setState(() {
        especialidades = datos;
        cargando = false;
        if (!especialidades.any((e) => e['id'] == especialidadSeleccionada)) {
          especialidadSeleccionada = null;
        }
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        cargando = false;
      });
      _mostrarMensaje('No se pudieron cargar las especialidades.');
    }
  }

  Future<void> seleccionarHora() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (hora == null || !mounted) return;

    final horas = hora.hour.toString().padLeft(2, '0');
    final minutos = hora.minute.toString().padLeft(2, '0');
    setState(() {
      horaController.text = '$horas:$minutos';
    });
  }

  Future<void> guardarCita() async {
    final paciente = pacienteController.text.trim();
    final hora = horaController.text.trim();

    if (paciente.isEmpty || hora.isEmpty || especialidadSeleccionada == null) {
      _mostrarMensaje('Completa paciente, especialidad y hora.');
      return;
    }

    try {
      await DatabaseHelper.instancia.insertarCita(
        paciente,
        especialidadSeleccionada!,
        hora,
      );

      pacienteController.clear();
      horaController.clear();
      especialidadSeleccionada = null;
      await cargarEspecialidades();
      _mostrarMensaje('Cita registrada correctamente.');
    } catch (error) {
      _mostrarMensaje(error.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _mostrarMensaje(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar cita medica')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Datos de la cita',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: pacienteController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del paciente',
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      key: ValueKey(especialidadSeleccionada),
                      initialValue: especialidadSeleccionada,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Especialidad',
                        prefixIcon: Icon(Icons.local_hospital),
                      ),
                      items: especialidades.map((esp) {
                        return DropdownMenuItem<int>(
                          value: esp['id'],
                          child: Text(
                            '${esp['nombre']} (${esp['cantidadCitas']} cupos)',
                          ),
                        );
                      }).toList(),
                      onChanged: cargando || especialidades.isEmpty
                          ? null
                          : (valor) {
                              setState(() {
                                especialidadSeleccionada = valor;
                              });
                            },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: horaController,
                      readOnly: true,
                      onTap: seleccionarHora,
                      decoration: const InputDecoration(
                        labelText: 'Hora de atencion',
                        prefixIcon: Icon(Icons.schedule),
                        suffixIcon: Icon(Icons.expand_more),
                      ),
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton.icon(
                      onPressed: cargando ? null : guardarCita,
                      icon: const Icon(Icons.check),
                      label: const Text('Guardar cita'),
                    ),
                  ],
                ),
              ),
            ),
            if (!cargando && especialidades.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 28),
                child: Column(
                  children: [
                    Icon(
                      Icons.event_busy,
                      size: 42,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'No hay cupos disponibles. Registra disponibilidad primero.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
