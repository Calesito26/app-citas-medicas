import 'package:flutter/material.dart';
import '../db/database_helper.dart';

class DisponibilidadVista extends StatefulWidget {
  const DisponibilidadVista({super.key});

  @override
  State<DisponibilidadVista> createState() => _DisponibilidadVistaState();
}

class _DisponibilidadVistaState extends State<DisponibilidadVista> {
  final especialidadController = TextEditingController();
  final cantidadController = TextEditingController();

  List<Map<String, dynamic>> disponibilidad = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarDisponibilidad();
  }

  @override
  void dispose() {
    especialidadController.dispose();
    cantidadController.dispose();
    super.dispose();
  }

  Future<void> cargarDisponibilidad() async {
    try {
      final datos = await DatabaseHelper.instancia.listarDisponibilidad();

      if (!mounted) return;
      setState(() {
        disponibilidad = datos;
        cargando = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        cargando = false;
      });
      _mostrarMensaje('No se pudo cargar la disponibilidad.');
    }
  }

  Future<void> guardar() async {
    final nombre = especialidadController.text.trim();
    final cantidad = int.tryParse(cantidadController.text.trim()) ?? 0;

    if (nombre.isEmpty || cantidad <= 0) {
      _mostrarMensaje('Ingresa una especialidad y una cantidad valida.');
      return;
    }

    try {
      final idEspecialidad = await DatabaseHelper.instancia
          .insertarEspecialidad(nombre);

      await DatabaseHelper.instancia.insertarDisponibilidad(
        idEspecialidad,
        cantidad,
      );

      especialidadController.clear();
      cantidadController.clear();
      await cargarDisponibilidad();
      _mostrarMensaje('Disponibilidad guardada correctamente.');
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
      appBar: AppBar(title: const Text('Disponibilidad del dia')),
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
                      'Cupos por especialidad',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: especialidadController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Especialidad medica',
                        prefixIcon: Icon(Icons.medical_information),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: cantidadController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Cantidad de citas disponibles',
                        prefixIcon: Icon(Icons.confirmation_number),
                      ),
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton.icon(
                      onPressed: guardar,
                      icon: const Icon(Icons.save),
                      label: const Text('Guardar disponibilidad'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            if (cargando)
              const Center(child: CircularProgressIndicator())
            else if (disponibilidad.isEmpty)
              const _EstadoVacio(
                icono: Icons.event_busy,
                texto: 'Aun no hay disponibilidad registrada.',
              )
            else
              ...disponibilidad.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text('${item['cantidadCitas']}'),
                      ),
                      title: Text(
                        item['especialidad'],
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: const Text('Citas disponibles'),
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
          Text(texto, style: TextStyle(color: Colors.grey.shade700)),
        ],
      ),
    );
  }
}
