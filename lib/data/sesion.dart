import '../models/rol.dart';

/// Guarda quién inició sesión. Es una versión simple para el Avance 1:
/// no hay contraseñas, solo se elige un nombre y un rol.
class Sesion {
  Sesion._();

  static String nombre = '';
  static Rol rol = Rol.mozo;

  static void iniciar(String nombreUsuario, Rol rolUsuario) {
    nombre = nombreUsuario.trim();
    rol = rolUsuario;
  }

  static void cerrar() {
    nombre = '';
    rol = Rol.mozo;
  }
}
