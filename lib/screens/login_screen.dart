import 'package:flutter/material.dart';

import '../data/sesion.dart';
import '../models/rol.dart';
import 'menu_principal_screen.dart';

/// Pantalla 2: selección de usuario (nombre + rol) con validación.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  Rol _rolSeleccionado = Rol.mozo;

  @override
  void dispose() {
    _nombreController.dispose(); // Libera memoria del controlador.
    super.dispose();
  }

  void _ingresar() {
    // validate() ejecuta los validator de todos los campos del formulario.
    if (!_formKey.currentState!.validate()) return;

    Sesion.iniciar(_nombreController.text, _rolSeleccionado);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MenuPrincipalScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar sesión')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '¿Quién va a usar la aplicación?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nombreController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (valor) {
                  if (valor == null || valor.trim().length < 3) {
                    return 'Ingresa un nombre de al menos 3 letras';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              const Text('Rol', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final rol in Rol.values)
                    ChoiceChip(
                      label: Text(rol.etiqueta),
                      selected: rol == _rolSeleccionado,
                      onSelected: (_) => setState(() => _rolSeleccionado = rol),
                    ),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _ingresar,
                child: const Text('Ingresar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
