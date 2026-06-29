import 'package:flutter/material.dart';
import '../db/database_helper.dart';

class AtenderCitaVista extends StatefulWidget {
  const AtenderCitaVista({super.key});

  @override
  State<AtenderCitaVista> createState() => _AtenderCitaVistaState();
}

class _AtenderCitaVistaState extends State<AtenderCitaVista> {
  final doctorController = TextEditingController();

  List<Map<String, dynamic>> citas = [];
  int? citaSeleccionada;
  bool cargando = true;

  String sintomaSeleccionado = 'Fiebre';
  String diagnosticoSeleccionado = 'Gripe';

  final sintomas = ['Fiebre', 'Dolor de cabeza', 'Tos', 'Dolor estomacal'];
  final diagnosticos = ['Gripe', 'Migrana', 'Infeccion', 'Gastritis'];

  @override
  void initState() {
    super.initState();
    cargarCitas();
  }

  @override
  void dispose() {
    doctorController.dispose();
    super.dispose();
  }

  Future<void> cargarCitas() async {
    final datos = await DatabaseHelper.instancia.listarCitasRegistradas();

    if (!mounted) return;
    setState(() {
      citas = datos;
      cargando = false;
      if (!citas.any((cita) => cita['id'] == citaSeleccionada)) {
        citaSeleccionada = null;
      }
    });
  }

  Future<void> atender() async {
    if (citaSeleccionada == null || doctorController.text.trim().isEmpty) {
      _mostrarMensaje('Selecciona una cita e ingresa el doctor.');
      return;
    }

    try {
      await DatabaseHelper.instancia.atenderCita(
        citaSeleccionada!,
        doctorController.text,
        sintomaSeleccionado,
        diagnosticoSeleccionado,
      );

      doctorController.clear();
      citaSeleccionada = null;
      await cargarCitas();
      _mostrarMensaje('Cita atendida correctamente.');
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
      appBar: AppBar(title: const Text('Atender cita medica')),
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
                      'Registro de atencion',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<int>(
                      initialValue: citaSeleccionada,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Cita registrada',
                        prefixIcon: Icon(Icons.event_note),
                      ),
                      items: citas.map((cita) {
                        return DropdownMenuItem<int>(
                          value: cita['id'],
                          child: Text(
                            '${cita['paciente']} - ${cita['especialidad']} - ${cita['hora']}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: citas.isEmpty
                          ? null
                          : (valor) {
                              setState(() {
                                citaSeleccionada = valor;
                              });
                            },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: doctorController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del doctor',
                        prefixIcon: Icon(Icons.badge),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: sintomaSeleccionado,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Sintomas',
                        prefixIcon: Icon(Icons.sick),
                      ),
                      items: sintomas.map((s) {
                        return DropdownMenuItem(value: s, child: Text(s));
                      }).toList(),
                      onChanged: (valor) {
                        if (valor == null) return;
                        setState(() {
                          sintomaSeleccionado = valor;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: diagnosticoSeleccionado,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Diagnostico',
                        prefixIcon: Icon(Icons.assignment_turned_in),
                      ),
                      items: diagnosticos.map((d) {
                        return DropdownMenuItem(value: d, child: Text(d));
                      }).toList(),
                      onChanged: (valor) {
                        if (valor == null) return;
                        setState(() {
                          diagnosticoSeleccionado = valor;
                        });
                      },
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton.icon(
                      onPressed: citas.isEmpty ? null : atender,
                      icon: const Icon(Icons.medical_services),
                      label: const Text('Guardar atencion'),
                    ),
                  ],
                ),
              ),
            ),
            if (!cargando && citas.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 28),
                child: Column(
                  children: [
                    Icon(
                      Icons.fact_check,
                      size: 42,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'No hay citas registradas pendientes de atencion.',
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
