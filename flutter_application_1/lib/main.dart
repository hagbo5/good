import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


const String apiBaseUrl = 'http://localhost:5020';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HGB',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const InicioPage(),
    );
  }
}

class InicioPage extends StatelessWidget {
  const InicioPage({super.key});

  void _openAndClose(BuildContext context, Widget page) {
    Navigator.pop(context); // cierra Drawer si está abierto
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.deepPurple,
              ),
              child: Row(
                children: const [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: NetworkImage('https://wallpapercave.com/wp/wp12143257.jpg'),
                  ),
                  SizedBox(width: 12),
                  Text('Menú de APIs', style: TextStyle(color: Colors.white, fontSize: 18)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text("Clientes"),
              onTap: () => _openAndClose(context, const ClientesScreen()),
            ),
            ListTile(
              leading: const Icon(Icons.directions_car),
              title: const Text("Coches"),
              onTap: () => _openAndClose(context, const CochesScreen()),
            ),
            ListTile(
              leading: const Icon(Icons.build),
              title: const Text("Revisiones"),
              onTap: () => _openAndClose(context, const RevisionesScreen()),
            ),
            const Divider(),
            // se eliminó la entrada "Registrar Cliente" del Drawer:
            // ahora el registro se realiza desde la pantalla "Clientes" con el botón '+'
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text("Acerca de"),
              onTap: () {
                Navigator.pop(context);
                showAboutDialog(
                  context: context,
                  applicationName: 'HGB',
                  applicationVersion: '1.0',
                  children: const [Text('App demo consumiendo API Flask')],
                );
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text('HGB'),
        centerTitle: true,
        elevation: 2,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 80,
                backgroundImage: NetworkImage('https://wallpapercave.com/wp/wp12143257.jpg'),
              ),
              const SizedBox(height: 20),
              const Text('Hola Mundo 👋', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Bienvenido a la app de HUGO', style: TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedCardButton(
                    icon: Icons.people,
                    label: 'Clientes',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ClientesScreen())),
                  ),
                  ElevatedCardButton(
                    icon: Icons.directions_car,
                    label: 'Coches',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CochesScreen())),
                  ),
                  ElevatedCardButton(
                    icon: Icons.build,
                    label: 'Revisiones',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RevisionesScreen())),
                  ),
                  // botón 'Registrar' eliminado de la página de inicio
                ],
               ),
             ],
           ),
         ),
       ),
     );
   }
 }
 
class ElevatedCardButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const ElevatedCardButton({super.key, required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 100,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 8),
                Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ------------------ Pantallas existentes  ------------------

// === ClientesScreen ===
class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key});
  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  List clientes = [];
  bool loading = true;

  Future<void> fetchClientes() async {
    try {
      final response = await http.get(Uri.parse('$apiBaseUrl/api/clientes'));
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        setState(() {
          clientes = decoded is List ? decoded : [];
          loading = false;
        });
      } else {
        setState(() => loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error HTTP: ${response.statusCode}')),
        );
      }
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchClientes();
  }

  Future<void> _onRefresh() async {
    setState(() => loading = true);
    await fetchClientes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Registrar cliente',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegistrarScreen())),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => fetchClientes(),
        tooltip: 'Refrescar',
        child: const Icon(Icons.refresh),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _onRefresh,
              child: ListView.separated(
                padding: const EdgeInsets.all(8),
                itemCount: clientes.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final c = clientes[index];
                  final name = (c['nombre'] ?? '').toString();
                  final initials = name.isNotEmpty ? name.trim().split(' ').map((s) => s.isEmpty ? '' : s[0]).take(2).join() : '?';
                  return ListTile(
                    leading: CircleAvatar(child: Text(initials)),
                    title: Text(name),
                    subtitle: Text('NIF: ${c['nif'] ?? ''} • Tel: ${c['telefono'] ?? ''}'),
                  );
                },
              ),
            ),
    );
  }
}

// === CochesScreen ===
class CochesScreen extends StatefulWidget {
  const CochesScreen({super.key});
  @override
  State<CochesScreen> createState() => _CochesScreenState();
}

class _CochesScreenState extends State<CochesScreen> {
  List coches = [];
  bool loading = true;

  Future<void> fetchCoches() async {
    try {
      final response = await http.get(Uri.parse('$apiBaseUrl/api/coches'));
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        setState(() {
          coches = decoded is List ? decoded : [];
          loading = false;
        });
      } else {
        setState(() => loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error HTTP: ${response.statusCode}')),
        );
      }
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCoches();
  }

  Future<void> _onRefresh() async {
    setState(() => loading = true);
    await fetchCoches();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coches'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Registrar coche',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegistrarCocheScreen())),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _onRefresh,
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: coches.length,
                itemBuilder: (context, index) {
                  final c = coches[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: const Icon(Icons.directions_car),
                      title: Text('${c['marca'] ?? ''} ${c['modelo'] ?? ''}'),
                      subtitle: Text('Matrícula: ${c['matricula'] ?? ''} • Color: ${c['color'] ?? ''}'),
                      trailing: Text('${c['precio'] ?? ''}'),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

// === RevisionesScreen ===
class RevisionesScreen extends StatefulWidget {
  const RevisionesScreen({super.key});
  @override
  State<RevisionesScreen> createState() => _RevisionesScreenState();
}

class _RevisionesScreenState extends State<RevisionesScreen> {
  List revisiones = [];
  bool loading = true;

  Future<void> fetchRevisiones() async {
    try {
      final response = await http.get(Uri.parse('$apiBaseUrl/api/revisiones'));
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        setState(() {
          revisiones = decoded is List ? decoded : [];
          loading = false;
        });
      } else {
        setState(() => loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error HTTP: ${response.statusCode}')),
        );
      }
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchRevisiones();
  }

  Future<void> _onRefresh() async {
    setState(() => loading = true);
    await fetchRevisiones();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Revisiones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Registrar revisión',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const RegistrarRevisionScreen()))
                .then((value) { if (value == true) fetchRevisiones(); });
            },
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _onRefresh,
              child: ListView.separated(
                padding: const EdgeInsets.all(8),
                itemCount: revisiones.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final r = revisiones[index];
                  return ListTile(
                    leading: const Icon(Icons.build),
                    title: Text('Revisión ${r['codigo'] ?? ''}'),
                    subtitle: Text('Coche: ${r['matricula_coche'] ?? ''} • Filtro: ${r['filtro'] ?? ''}'),
                  );
                },
              ),
            ),
    );
  }
}

// === RegistrarScreen ===
class RegistrarScreen extends StatefulWidget {
  const RegistrarScreen({super.key});
  @override
  State<RegistrarScreen> createState() => _RegistrarScreenState();
}

class _RegistrarScreenState extends State<RegistrarScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nifController = TextEditingController();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController direccionController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();

  Future<void> registrarCliente() async {
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/api/clientes'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'nif': nifController.text,
          'nombre': nombreController.text,
          'direccion': direccionController.text,
          'telefono': telefonoController.text,
        }),
      );
      if (response.statusCode == 201) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cliente registrado correctamente')),
        );
        nifController.clear();
        nombreController.clear();
        direccionController.clear();
        telefonoController.clear();
      } else {
        var decoded = json.decode(response.body);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${decoded['error'] ?? response.body}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Cliente')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nifController,
                decoration: const InputDecoration(labelText: 'NIF'),
                validator: (value) => value == null || value.isEmpty ? 'Ingrese NIF' : null,
              ),
              TextFormField(
                controller: nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) => value == null || value.isEmpty ? 'Ingrese nombre' : null,
              ),
              TextFormField(
                controller: direccionController,
                decoration: const InputDecoration(labelText: 'Dirección'),
                validator: (value) => value == null || value.isEmpty ? 'Ingrese dirección' : null,
              ),
              TextFormField(
                controller: telefonoController,
                decoration: const InputDecoration(labelText: 'Teléfono'),
                validator: (value) => value == null || value.isEmpty ? 'Ingrese teléfono' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    registrarCliente();
                  }
                },
                child: const Text('Registrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// === RegistrarCocheScreen ===
class RegistrarCocheScreen extends StatefulWidget {
  const RegistrarCocheScreen({super.key});
  @override
  State<RegistrarCocheScreen> createState() => _RegistrarCocheScreenState();
}

class _RegistrarCocheScreenState extends State<RegistrarCocheScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController matriculaController = TextEditingController();
  final TextEditingController marcaController = TextEditingController();
  final TextEditingController modeloController = TextEditingController();
  final TextEditingController colorController = TextEditingController();
  final TextEditingController precioController = TextEditingController();

  @override
  void dispose() {
    matriculaController.dispose();
    marcaController.dispose();
    modeloController.dispose();
    colorController.dispose();
    precioController.dispose();
    super.dispose();
  }

  Future<void> registrarCoche() async {
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/api/coches'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'matricula': matriculaController.text,
          'marca': marcaController.text,
          'modelo': modeloController.text,
          'color': colorController.text,
          'precio': precioController.text,
        }),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Coche registrado correctamente')),
        );
        matriculaController.clear();
        marcaController.clear();
        modeloController.clear();
        colorController.clear();
        precioController.clear();
      } else {
        var decoded = {};
        try { decoded = json.decode(response.body); } catch (_) {}
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${decoded['error'] ?? response.body}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Coche')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: matriculaController,
                decoration: const InputDecoration(labelText: 'Matrícula'),
                validator: (value) => value == null || value.isEmpty ? 'Ingrese matrícula' : null,
              ),
              TextFormField(
                controller: marcaController,
                decoration: const InputDecoration(labelText: 'Marca'),
                validator: (value) => value == null || value.isEmpty ? 'Ingrese marca' : null,
              ),
              TextFormField(
                controller: modeloController,
                decoration: const InputDecoration(labelText: 'Modelo'),
                validator: (value) => value == null || value.isEmpty ? 'Ingrese modelo' : null,
              ),
              TextFormField(
                controller: colorController,
                decoration: const InputDecoration(labelText: 'Color'),
                validator: (value) => value == null || value.isEmpty ? 'Ingrese color' : null,
              ),
              TextFormField(
                controller: precioController,
                decoration: const InputDecoration(labelText: 'Precio'),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty ? 'Ingrese precio' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    registrarCoche();
                  }
                },
                child: const Text('Registrar coche'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// === RegistrarRevisionScreen ===
class RegistrarRevisionScreen extends StatefulWidget {
  const RegistrarRevisionScreen({super.key});
  @override
  State<RegistrarRevisionScreen> createState() => _RegistrarRevisionScreenState();
}

class _RegistrarRevisionScreenState extends State<RegistrarRevisionScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController codigoController = TextEditingController();
  final TextEditingController matriculaController = TextEditingController();
  final TextEditingController filtroController = TextEditingController();
  final TextEditingController fechaController = TextEditingController();
  final TextEditingController notasController = TextEditingController();

  // lista de coches para el dropdown
  List cochesList = [];
  String? selectedMatricula;
  bool loadingCoches = true;

  // opciones de revisión
  bool opcionFiltro = false;
  bool opcionAceite = false;
  bool opcionFrenos = false;

  @override
  void initState() {
    super.initState();
    fetchCoches();
  }

  Future<void> fetchCoches() async {
    try {
      final response = await http.get(Uri.parse('$apiBaseUrl/api/coches'));
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        setState(() {
          cochesList = decoded is List ? decoded : [];
          loadingCoches = false;
        });
      } else {
        setState(() => loadingCoches = false);
      }
    } catch (_) {
      setState(() => loadingCoches = false);
    }
  }

  @override
  void dispose() {
    codigoController.dispose();
    matriculaController.dispose();
    filtroController.dispose();
    fechaController.dispose();
    notasController.dispose();
    super.dispose();
  }

  Future<void> registrarRevision() async {
    try {
      final body = {
        'codigo': codigoController.text,
        'matricula_coche': matriculaController.text,
        'opciones': {
          'filtro': opcionFiltro,
          'aceite': opcionAceite,
          'frenos': opcionFrenos,
        },
        'fecha': fechaController.text,
        'notas': notasController.text,
      };

      final response = await http.post(
        Uri.parse('$apiBaseUrl/api/revisiones'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Revisión registrada correctamente')),
        );
        Navigator.pop(context, true);
      } else {
        var decoded = {};
        try {
          decoded = json.decode(response.body);
        } catch (_) {}
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${decoded['error'] ?? response.body}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Revisión')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: codigoController,
                decoration: const InputDecoration(labelText: 'Código'),
                validator: (v) => v == null || v.isEmpty ? 'Ingrese código' : null,
              ),

              // Matricula: dropdown con coches registrados, si no hay coches permitir entrada manual
              const SizedBox(height: 12),
              if (loadingCoches)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (cochesList.isNotEmpty)
                DropdownButtonFormField<String>(
                  value: selectedMatricula,
                  decoration: const InputDecoration(labelText: 'Coche (Matrícula - Modelo):'),
                  items: cochesList.map<DropdownMenuItem<String>>((c) {
                    final mat = (c['matricula'] ?? '').toString();
                    final modelo = (c['modelo'] ?? '').toString();
                    final label = '$mat - $modelo';
                    return DropdownMenuItem(value: mat, child: Text(label));
                  }).toList(),
                  onChanged: (v) {
                    setState(() {
                      selectedMatricula = v;
                      matriculaController.text = v ?? '';
                    });
                  },
                  validator: (v) => (matriculaController.text).isEmpty ? 'Seleccione matrícula' : null,
                )
              else
                TextFormField(
                  controller: matriculaController,
                  decoration: const InputDecoration(labelText: 'Matrícula coche (manual)'),
                  validator: (v) => v == null || v.isEmpty ? 'Ingrese matrícula' : null,
                ),

              const SizedBox(height: 16),

              // Checkboxes de opciones de revisión
              CheckboxListTile(
                value: opcionFiltro,
                onChanged: (v) => setState(() => opcionFiltro = v ?? false),
                title: const Text('Filtro'),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),

              CheckboxListTile(
                value: opcionAceite,
                onChanged: (v) => setState(() => opcionAceite = v ?? false),
                title: const Text('Aceite'),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),

              CheckboxListTile(
                value: opcionFrenos,
                onChanged: (v) => setState(() => opcionFrenos = v ?? false),
                title: const Text('Frenos'),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),

              const SizedBox(height: 12),

              // Campo de fecha: abre selector de calendario
              TextFormField(
                controller: fechaController,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Fecha (YYYY-MM-DD)'),
                onTap: () async {
                  final now = DateTime.now();
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: now,
                    firstDate: DateTime(now.year - 5),
                    lastDate: DateTime(now.year + 5),
                  );
                  if (picked != null) {
                    final formatted = '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                    setState(() => fechaController.text = formatted);
                  }
                },
                validator: (v) => v == null || v.isEmpty ? 'Ingrese fecha' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: notasController,
                decoration: const InputDecoration(labelText: 'Notas'),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                onPressed: () {
                  if (_formKey.currentState!.validate()) registrarRevision();
                },
                child: const Text('Guardar Revisión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
