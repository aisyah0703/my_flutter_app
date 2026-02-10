import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isObscured = true;
  bool _isLoading = false;

  // State untuk menyimpan pesan error masing-masing field
  String? _emailError;
  String? _passwordError;
  String? _globalError;

  Future<void> _handleLogin() async {
    // Reset error sebelum validasi
    setState(() {
      _emailError = null;
      _passwordError = null;
      _globalError = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // 1. Validasi Kosong (Sesuai gambar ke-3)
    if (email.isEmpty && password.isEmpty) {
      setState(() => _globalError = "email dan password tidak boleh kosong");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;

      // 2. Autentikasi ke Supabase
      final AuthResponse response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        final userData = await supabase
            .from('profiles')
            .select('role')
            .eq('user_id', response.user!.id)
            .maybeSingle();

        if (userData == null) throw "User data not found.";

        final String role = userData['role'].toString().toLowerCase();
        if (!mounted) return;

        // Navigasi...
        if (role == 'admin')
          Navigator.pushReplacementNamed(context, '/admin_dashboard');
        else if (role == 'petugas')
          Navigator.pushReplacementNamed(context, '/petugas_dashboard');
        else
          Navigator.pushReplacementNamed(context, '/peminjam_dashboard');
      }
    } on AuthException catch (error) {
      // 3. Menangani error spesifik (Sesuai gambar 1 & 2)
      setState(() {
        if (error.message.toLowerCase().contains('email')) {
          _emailError = "email salah atau tidak ditemukan";
        } else if (error.message.toLowerCase().contains(
              'invalid login credentials',
            ) ||
            error.message.toLowerCase().contains('password')) {
          _passwordError = "Password salah";
        } else {
          _globalError = error.message;
        }
      });
    } catch (error) {
      setState(() => _globalError = "Terjadi kesalahan sistem");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: [
                const Text(
                  'HAI, SELAMAT DATANG!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Serif',
                  ),
                ),
                const SizedBox(height: 30),
                // Logo placeholder sesuai gambar
                Image.network(
                  'https://via.placeholder.com/120', // Ganti dengan asset logo E-LAB Anda
                  height: 120,
                ),
                const SizedBox(height: 40),

                // Field Email
                _buildField(
                  label: "Email",
                  hint: "Masukkan Email",
                  controller: _emailController,
                  errorText: _emailError,
                ),
                const SizedBox(height: 20),

                // Field Password
                _buildField(
                  label: "Password",
                  hint: "Masukkan Password",
                  controller: _passwordController,
                  isPass: true,
                  errorText: _passwordError,
                ),

                const SizedBox(height: 30),

                // Tombol Login
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A90E2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "LOGIN",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                // Pesan Error Global (Gambar 3)
                if (_globalError != null) ...[
                  const SizedBox(height: 20),
                  Text(
                    _globalError!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required String hint,
    required TextEditingController controller,
    String? errorText,
    bool isPass = false,
  }) {
    // Warna border berubah jika ada error
    final Color borderColor = errorText != null
        ? Colors.red.withOpacity(0.3)
        : const Color(0xFFDDEEFA);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF4A90E2),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          obscureText: isPass ? _isObscured : false,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            suffixIcon: isPass
                ? IconButton(
                    icon: Icon(
                      _isObscured ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () => setState(() => _isObscured = !_isObscured),
                  )
                : null,
            // Styling border sesuai gambar (rounded & soft color)
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: errorText != null ? Colors.redAccent : Colors.blue,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 15,
            ),
          ),
        ),
        // Pesan error di bawah field (Gambar 1 & 2)
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 5, left: 5),
            child: Text(
              errorText,
              style: const TextStyle(color: Colors.redAccent, fontSize: 11),
            ),
          ),
      ],
    );
  }
}
