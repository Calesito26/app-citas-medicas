import 'package:sqflite/sqflite.dart' as sqflite;

import 'database_factory.dart';

class DatabaseHelper {
  static final DatabaseHelper instancia = DatabaseHelper._internal();

  DatabaseHelper._internal();

  static sqflite.Database? _database;

  Future<sqflite.Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _iniciarBaseDatos();
    return _database!;
  }

  Future<sqflite.Database> _iniciarBaseDatos() async {
    final factory = obtenerDatabaseFactory();
    final rutaCompleta = await obtenerRutaBaseDatos(
      factory,
      'citas_medicas.db',
    );

    return factory.openDatabase(
      rutaCompleta,
      options: sqflite.OpenDatabaseOptions(
        version: 2,
        onCreate: _crearTablas,
        onUpgrade: _actualizarTablas,
      ),
    );
  }

  Future<void> _crearTablas(sqflite.Database db, int version) async {
    await db.execute('''
      CREATE TABLE especialidad(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE disponibilidad_dia(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        especialidadId INTEGER NOT NULL,
        cantidadCitas INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE cita(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        paciente TEXT NOT NULL,
        especialidadId INTEGER NOT NULL,
        hora TEXT NOT NULL,
        estado TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE atencion(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        citaId INTEGER NOT NULL,
        doctor TEXT NOT NULL,
        sintomas TEXT NOT NULL,
        diagnostico TEXT NOT NULL
      )
    ''');
  }

  Future<void> _actualizarTablas(
    sqflite.Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      final columnasCita = await db.rawQuery('PRAGMA table_info(cita)');
      final tieneEstado = columnasCita.any(
        (columna) => columna['name'] == 'estado',
      );

      if (!tieneEstado) {
        await db.execute('''
          ALTER TABLE cita
          ADD COLUMN estado TEXT NOT NULL DEFAULT 'Registrada'
        ''');
      }

      await db.execute('''
        UPDATE cita
        SET estado = 'Registrada'
        WHERE estado IS NULL OR estado = ''
      ''');
    }
  }

  Future<int> insertarEspecialidad(String nombre) async {
    final db = await database;
    final existente = await buscarEspecialidadPorNombre(nombre);

    if (existente != null) {
      return existente['id'] as int;
    }

    return db.insert('especialidad', {'nombre': nombre.trim()});
  }

  Future<Map<String, dynamic>?> buscarEspecialidadPorNombre(
    String nombre,
  ) async {
    final db = await database;
    final datos = await db.query(
      'especialidad',
      where: 'LOWER(nombre) = LOWER(?)',
      whereArgs: [nombre.trim()],
      limit: 1,
    );

    if (datos.isEmpty) {
      return null;
    }

    return datos.first;
  }

  Future<List<Map<String, dynamic>>> listarEspecialidades() async {
    final db = await database;
    return db.query('especialidad', orderBy: 'nombre COLLATE NOCASE');
  }

  Future<List<Map<String, dynamic>>> listarEspecialidadesDisponibles() async {
    final db = await database;

    return db.rawQuery('''
      SELECT especialidad.id,
             especialidad.nombre,
             disponibilidad_dia.cantidadCitas
      FROM especialidad
      INNER JOIN disponibilidad_dia
      ON disponibilidad_dia.especialidadId = especialidad.id
      WHERE disponibilidad_dia.cantidadCitas > 0
      ORDER BY especialidad.nombre COLLATE NOCASE
    ''');
  }

  Future<int> insertarDisponibilidad(
    int especialidadId,
    int cantidadCitas,
  ) async {
    final db = await database;

    final existente = await db.query(
      'disponibilidad_dia',
      where: 'especialidadId = ?',
      whereArgs: [especialidadId],
      limit: 1,
    );

    if (existente.isNotEmpty) {
      await db.update(
        'disponibilidad_dia',
        {'cantidadCitas': cantidadCitas},
        where: 'especialidadId = ?',
        whereArgs: [especialidadId],
      );
      return existente.first['id'] as int;
    }

    return db.insert('disponibilidad_dia', {
      'especialidadId': especialidadId,
      'cantidadCitas': cantidadCitas,
    });
  }

  Future<List<Map<String, dynamic>>> listarDisponibilidad() async {
    final db = await database;

    return db.rawQuery('''
      SELECT disponibilidad_dia.id,
             especialidad.id AS especialidadId,
             especialidad.nombre AS especialidad,
             disponibilidad_dia.cantidadCitas
      FROM disponibilidad_dia
      INNER JOIN especialidad
      ON disponibilidad_dia.especialidadId = especialidad.id
      ORDER BY especialidad.nombre COLLATE NOCASE
    ''');
  }

  Future<int> insertarCita(
    String paciente,
    int especialidadId,
    String hora,
  ) async {
    final db = await database;

    return db.transaction((txn) async {
      final disponibilidad = await txn.query(
        'disponibilidad_dia',
        where: 'especialidadId = ? AND cantidadCitas > 0',
        whereArgs: [especialidadId],
        limit: 1,
      );

      if (disponibilidad.isEmpty) {
        throw Exception('No hay citas disponibles para esta especialidad.');
      }

      final citaDuplicada = await txn.query(
        'cita',
        where: 'especialidadId = ? AND hora = ? AND estado = ?',
        whereArgs: [especialidadId, hora, 'Registrada'],
        limit: 1,
      );

      if (citaDuplicada.isNotEmpty) {
        throw Exception('Ya existe una cita registrada para esa hora.');
      }

      await txn.rawUpdate(
        '''
        UPDATE disponibilidad_dia
        SET cantidadCitas = cantidadCitas - 1
        WHERE especialidadId = ?
        ''',
        [especialidadId],
      );

      return txn.insert('cita', {
        'paciente': paciente.trim(),
        'especialidadId': especialidadId,
        'hora': hora,
        'estado': 'Registrada',
      });
    });
  }

  Future<List<Map<String, dynamic>>> listarCitasRegistradas() async {
    final db = await database;

    return db.rawQuery('''
      SELECT cita.id,
             cita.paciente,
             especialidad.nombre AS especialidad,
             cita.hora,
             cita.estado
      FROM cita
      INNER JOIN especialidad
      ON cita.especialidadId = especialidad.id
      WHERE cita.estado = 'Registrada'
      ORDER BY cita.hora
    ''');
  }

  Future<List<Map<String, dynamic>>> listarCitasPorEspecialidad(
    int especialidadId,
  ) async {
    final db = await database;

    return db.rawQuery(
      '''
      SELECT cita.id,
             cita.paciente,
             especialidad.nombre AS especialidad,
             cita.hora,
             cita.estado
      FROM cita
      INNER JOIN especialidad
      ON cita.especialidadId = especialidad.id
      WHERE cita.especialidadId = ?
      ORDER BY cita.hora
    ''',
      [especialidadId],
    );
  }

  Future<int> anularCita(int citaId) async {
    final db = await database;

    return db.transaction((txn) async {
      final datos = await txn.query(
        'cita',
        where: 'id = ?',
        whereArgs: [citaId],
        limit: 1,
      );

      if (datos.isEmpty || datos.first['estado'] != 'Registrada') {
        return 0;
      }

      final especialidadId = datos.first['especialidadId'] as int;

      await txn.rawUpdate(
        '''
        UPDATE disponibilidad_dia
        SET cantidadCitas = cantidadCitas + 1
        WHERE especialidadId = ?
        ''',
        [especialidadId],
      );

      return txn.update(
        'cita',
        {'estado': 'Anulada'},
        where: 'id = ?',
        whereArgs: [citaId],
      );
    });
  }

  Future<int> atenderCita(
    int citaId,
    String doctor,
    String sintomas,
    String diagnostico,
  ) async {
    final db = await database;

    return db.transaction((txn) async {
      final datos = await txn.query(
        'cita',
        where: 'id = ? AND estado = ?',
        whereArgs: [citaId, 'Registrada'],
        limit: 1,
      );

      if (datos.isEmpty) {
        throw Exception('La cita seleccionada ya no esta disponible.');
      }

      await txn.insert('atencion', {
        'citaId': citaId,
        'doctor': doctor.trim(),
        'sintomas': sintomas,
        'diagnostico': diagnostico,
      });

      return txn.update(
        'cita',
        {'estado': 'Atendida'},
        where: 'id = ?',
        whereArgs: [citaId],
      );
    });
  }
}
