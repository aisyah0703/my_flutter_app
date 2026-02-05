import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controller untuk menangkap input user
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isObscured = true;
  bool _isLoading = false;

  // Fungsi Inti: Handle Login & Role-Based Redirect
  Future<void> _handleLogin() async {
    // Validasi input kosong
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showErrorSnackBar("Email dan Password tidak boleh kosong");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;

      // 1. Autentikasi ke Supabase Auth
      final AuthResponse response = await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (response.user != null) {
        // 2. Ambil Role dari tabel 'profiles' berdasarkan UID user yang login
        // Pastikan nama tabel di Supabase adalah 'profiles'
        final userData = await supabase
            .from('profiles')
            .select('role')
            .eq('id', response.user!.id)
            .single();

        final String role = userData['role'];

        if (!mounted) return;

        // 3. Navigasi sesuai Role
        // Pastikan nama rute ini sudah terdaftar di main.dart
        if (role == 'admin') {
          Navigator.pushReplacementNamed(context, '/admin_dashboard');
        } else if (role == 'petugas') {
          Navigator.pushReplacementNamed(context, '/petugas_dashboard');
        } else if (role == 'peminjam') {
          Navigator.pushReplacementNamed(context, '/peminjam_dashboard');
        } else {
          _showErrorSnackBar("Akses ditolak: Role tidak dikenali");
        }
      }
    } on AuthException catch (error) {
      _showErrorSnackBar("Login Gagal: ${error.message}");
    } catch (error) {
      _showErrorSnackBar("Terjadi kesalahan sistem");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'HAI, SELAMAT DATANG!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Serif',
                  ),
                ),
                const SizedBox(height: 40),
                Image.asset(
                  'assets/images/logo.png',
                  height: 180,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, size: 100, color: Colors.grey),
                ),
                const SizedBox(height: 50),

                // Field Email
                _buildInputField(
                  label: "Email",
                  hint: "Masukkan Email",
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 20),

                // Field Password
                _buildInputField(
                  label: "Password",
                  hint: "Masukkan Password",
                  controller: _passwordController,
                  isPassword: true,
                ),

                const SizedBox(height: 40),

                // Tombol LOGIN
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A90E2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 2,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "LOGIN",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget Helper Reusable untuk Input
  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
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
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword ? _isObscured : false,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      _isObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: Colors.grey,
                    ),
                    onPressed: () => setState(() => _isObscured = !_isObscured),
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFD1E3F8), width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF4A90E2), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}