import 'package:flutter/material.dart';
import 'package:flutter_application_1/backend/api.dart';

class Cliente {
  final String nif;
  final String nombre;
  final String direccion;
  final String telefono;

  Cliente({
    required this.nif,
    required this.nombre,
    required this.direccion,
    required this.telefono,
  });

  // Factory constructor para crear una instancia desde un JSON
  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      nif: json['nif'] as String,
      nombre: json['nombre'] as String,
      direccion: json['direccion'] as String,
      telefono: json['telefono'] as String,
    );
  }
}

// Método que abre un modal con la lista de clientes
class MostrarClientes {
  void mostrar(BuildContext context) {
    buscarClientes().then((clientes) {
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return Scaffold(
            appBar: AppBar(title: const Text("Lista de Clientes")),
            body: ListView.builder(
              itemCount: clientes.length,
              itemBuilder: (BuildContext context, int i) {
                return ListTile(
                  title: Text(clientes[i].nombre),
                  subtitle: Text('NIF: ${clientes[i].nif}'),
                  trailing: Text(clientes[i].telefono),
                );
              },
            ),
          );
        },
      );
    });
  }
}
