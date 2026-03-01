import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://fxfvtzqsbyphmddnylxp.supabase.co',
    anonKey: 'sb_publishable_gocOS0HP38_-FLsKlphaCQ_WYg524PL',
  );

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Puerto Montt App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      // Si hay sesión activa va al mapa, si no al login
      home: supabase.auth.currentSession != null
          ? const MapaPage()
          : const LoginPage(),
    );
  }
}

// ═══════════════════════════════════════════
// PANTALLA DE LOGIN
// ═══════════════════════════════════════════
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _cargando = false;
  bool _mostrarPassword = false;

  Future<void> _login() async {
    setState(() => _cargando = true);
    try {
      await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MapaPage()),
        );
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.location_city,
                  color: Colors.white,
                  size: 50,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Puerto Montt App',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const Text(
                'Monitoreo Urbano Inteligente',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 40),
              // Email
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Correo electrónico',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Password
              TextField(
                controller: _passwordController,
                obscureText: !_mostrarPassword,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_mostrarPassword
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () {
                      setState(() => _mostrarPassword = !_mostrarPassword);
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Botón Login
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _cargando ? null : _login,
                  child: _cargando
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Iniciar Sesión',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              // Ir a Registro
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterPage()),
                  );
                },
                child: const Text(
                  '¿No tienes cuenta? Regístrate',
                  style: TextStyle(color: Colors.green),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════
// PANTALLA DE REGISTRO
// ═══════════════════════════════════════════
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _cargando = false;

  Future<void> _registrar() async {
    setState(() => _cargando = true);
    try {
      await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Cuenta creada! Revisa tu email para confirmar.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Cuenta'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_add, size: 60, color: Colors.green),
            const SizedBox(height: 24),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Correo electrónico',
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Contraseña (mínimo 6 caracteres)',
                prefixIcon: const Icon(Icons.lock),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _cargando ? null : _registrar,
                child: _cargando
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Crear Cuenta',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════
// PANTALLA DEL MAPA
// ═══════════════════════════════════════════
class MapaPage extends StatefulWidget {
  const MapaPage({super.key});

  @override
  State<MapaPage> createState() => _MapaPageState();
}

class _MapaPageState extends State<MapaPage> {
  LatLng _ubicacion = const LatLng(-41.4717, -72.9353);
  bool _cargando = true;
  final MapController _mapController = MapController();
  List<Map<String, dynamic>> _incidentes = [];
  RealtimeChannel? _canal;

  @override
  void initState() {
    super.initState();
    _obtenerUbicacion();
    _cargarIncidentes();
    _suscribirRealtime();
  }

  @override
  void dispose() {
    _canal?.unsubscribe();
    super.dispose();
  }

  void _suscribirRealtime() {
    _canal = supabase
        .channel('incidentes_realtime')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'incidentes',
          callback: (payload) {
            _cargarIncidentes();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🔔 Nuevo reporte en el mapa!'),
                  backgroundColor: Colors.blue,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
        )
        .subscribe();
  }

  Future<void> _cargarIncidentes() async {
    try {
      final data = await supabase
          .from('incidentes')
          .select()
          .order('creado_en', ascending: false);
      setState(() {
        _incidentes = List<Map<String, dynamic>>.from(data);
      });
    } catch (e) {
      debugPrint('Error cargando incidentes: $e');
    }
  }

  Future<void> _obtenerUbicacion() async {
    try {
      bool servicioActivo = await Geolocator.isLocationServiceEnabled();
      if (!servicioActivo) {
        setState(() => _cargando = false);
        return;
      }
      LocationPermission permiso = await Geolocator.checkPermission();
      if (permiso == LocationPermission.denied) {
        permiso = await Geolocator.requestPermission();
      }
      if (permiso == LocationPermission.deniedForever) {
        setState(() => _cargando = false);
        return;
      }
      Position posicion = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _ubicacion = LatLng(posicion.latitude, posicion.longitude);
        _cargando = false;
      });
      _mapController.move(_ubicacion, 15);
    } catch (e) {
      setState(() => _cargando = false);
    }
  }

  Future<void> _cerrarSesion() async {
    await supabase.auth.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  void _mostrarDialogoReporte(LatLng punto) {
    String tipoSeleccionado = 'taco';
    int gravedadSeleccionada = 1;
    final TextEditingController descripcionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Nuevo Reporte'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tipo de incidencia:'),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _botonTipo('taco', '🚗 Taco', tipoSeleccionado, (v) {
                    setStateDialog(() => tipoSeleccionado = v);
                  }),
                  _botonTipo('accidente', '💥 Accidente', tipoSeleccionado, (v) {
                    setStateDialog(() => tipoSeleccionado = v);
                  }),
                  _botonTipo('obra', '🚧 Obra', tipoSeleccionado, (v) {
                    setStateDialog(() => tipoSeleccionado = v);
                  }),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Gravedad (1-5):'),
              Slider(
                value: gravedadSeleccionada.toDouble(),
                min: 1,
                max: 5,
                divisions: 4,
                label: gravedadSeleccionada.toString(),
                activeColor: Colors.green,
                onChanged: (v) {
                  setStateDialog(() => gravedadSeleccionada = v.toInt());
                },
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descripcionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción (opcional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () async {
                Navigator.pop(context);
                await _guardarIncidente(
                  punto,
                  tipoSeleccionado,
                  gravedadSeleccionada,
                  descripcionController.text,
                );
              },
              child: const Text('Reportar',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _botonTipo(String valor, String etiqueta, String seleccionado,
      Function(String) onTap) {
    final bool activo = valor == seleccionado;
    return GestureDetector(
      onTap: () => onTap(valor),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: activo ? Colors.green : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          etiqueta,
          style: TextStyle(
            fontSize: 12,
            color: activo ? Colors.white : Colors.black,
            fontWeight: activo ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Future<void> _guardarIncidente(
    LatLng punto,
    String tipo,
    int gravedad,
    String descripcion,
  ) async {
    try {
      await supabase.from('incidentes').insert({
        'ubicacion': 'POINT(${punto.longitude} ${punto.latitude})',
        'tipo': tipo,
        'gravedad': gravedad,
        'descripcion': descripcion.isEmpty ? null : descripcion,
        'usuario_id': supabase.auth.currentUser?.id,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ Reporte de $tipo guardado'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  IconData _iconoPorTipo(String tipo) {
    switch (tipo) {
      case 'accidente':
        return Icons.car_crash;
      case 'obra':
        return Icons.construction;
      default:
        return Icons.traffic;
    }
  }

  Color _colorPorTipo(String tipo) {
    switch (tipo) {
      case 'accidente':
        return Colors.red;
      case 'obra':
        return Colors.orange;
      default:
        return Colors.amber;
    }
  }

  @override
  Widget build(BuildContext context) {
    final usuario = supabase.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Puerto Montt App'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Chip(
              label: Text(
                '${_incidentes.length} reportes',
                style: const TextStyle(fontSize: 12),
              ),
              backgroundColor: Colors.white,
            ),
          ),
          // Menu usuario
          PopupMenuButton(
            icon: const Icon(Icons.account_circle),
            itemBuilder: (_) => [
              PopupMenuItem(
                enabled: false,
                child: Text(
                  usuario?.email ?? 'Invitado',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Cerrar sesión'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'logout') _cerrarSesion();
            },
          ),
        ],
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _ubicacion,
          initialZoom: 14,
          onTap: (tapPosition, punto) {
            _mostrarDialogoReporte(punto);
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.puerto_montt_app',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: _ubicacion,
                width: 60,
                height: 60,
                child: const Icon(
                  Icons.person_pin_circle,
                  color: Colors.blue,
                  size: 50,
                ),
              ),
              ..._incidentes.map((incidente) {
                final ubicacion = incidente['ubicacion'] as String? ?? '';
                double lat = _ubicacion.latitude;
                double lng = _ubicacion.longitude;
                try {
                  final coords = ubicacion
                      .replaceAll('POINT(', '')
                      .replaceAll(')', '')
                      .split(' ');
                  lng = double.parse(coords[0]);
                  lat = double.parse(coords[1]);
                } catch (e) {
                  debugPrint('Error parseando coordenadas: $e');
                }
                return Marker(
                  point: LatLng(lat, lng),
                  width: 50,
                  height: 50,
                  child: Container(
                    decoration: BoxDecoration(
                      color: _colorPorTipo(incidente['tipo'] ?? 'taco'),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _iconoPorTipo(incidente['tipo'] ?? 'taco'),
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.small(
            heroTag: 'recargar',
            backgroundColor: Colors.blue,
            onPressed: _cargarIncidentes,
            child: const Icon(Icons.refresh, color: Colors.white),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'ubicacion',
            backgroundColor: Colors.green,
            onPressed: () => _mapController.move(_ubicacion, 15),
            child: const Icon(Icons.my_location, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
