import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

// Función para obtener los clientes
Future<List<Cliente>> buscarClientes() async {
  final direccion = Uri.parse("http://10.2.0.2:5020/api/clientes");
  final respuesta = await http.get(direccion);

  if (respuesta.statusCode != 200) {
    return [];
  }

  try {
    return compute(pasarInfoClientes, respuesta.body);
  } catch (e) {
    return [];
  }
}

// Función para convertir el JSON en objetos Cliente
List<Cliente> pasarInfoClientes(String respuesta) {
  final decoded = json.decode(respuesta);
  if (decoded is List) {
    return decoded.map<Cliente>((json) => Cliente.fromJson(json)).toList();
  }
  return [];
}

// Clase para representar los datos de un cliente
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

  // Constructor para crear un Cliente desde JSON
  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      nif: json["nif"] as String,
      nombre: json["nombre"] as String,
      direccion: json["direccion"] as String,
      telefono: json["telefono"] as String,
    );
  }
}
