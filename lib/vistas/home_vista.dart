import 'package:flutter/material.dart';
import 'atender_cita_vista.dart';
import 'disponibilidad_vista.dart';
import 'registrar_cita_vista.dart';
import 'reportes_vista.dart';

class HomeVista extends StatelessWidget {
  const HomeVista({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Centro de Salud')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.local_hospital, color: Colors.white, size: 34),
                  SizedBox(height: 14),
                  Text(
                    'Gestion de citas medicas',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Administra disponibilidad, registro, atencion y reportes.',
                    style: TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            _OpcionMenu(
              icono: Icons.event_available,
              titulo: 'Disponibilidad',
              descripcion: 'Registra o actualiza cupos por especialidad.',
              pantalla: const DisponibilidadVista(),
            ),
            _OpcionMenu(
              icono: Icons.person_add_alt_1,
              titulo: 'Registrar cita',
              descripcion: 'Agenda pacientes en horarios disponibles.',
              pantalla: const RegistrarCitaVista(),
            ),
            _OpcionMenu(
              icono: Icons.medical_services,
              titulo: 'Atender cita',
              descripcion:
                  'Marca atenciones con doctor, sintomas y diagnostico.',
              pantalla: const AtenderCitaVista(),
            ),
            _OpcionMenu(
              icono: Icons.bar_chart,
              titulo: 'Reportes',
              descripcion:
                  'Consulta citas por especialidad y anula pendientes.',
              pantalla: const ReportesVista(),
            ),
          ],
        ),
      ),
    );
  }
}

class _OpcionMenu extends StatelessWidget {
  const _OpcionMenu({
    required this.icono,
    required this.titulo,
    required this.descripcion,
    required this.pantalla,
  });

  final IconData icono;
  final String titulo;
  final String descripcion;
  final Widget pantalla;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => pantalla),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icono, color: colorScheme.onPrimaryContainer),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        descripcion,
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
