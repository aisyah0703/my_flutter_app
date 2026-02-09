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

  Future<void> _handleLogin() async {
    // 1. Validasi Input
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      _showErrorSnackBar("Email dan Password tidak boleh kosong!");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;

      // 2. Autentikasi ke Supabase Auth
      final AuthResponse response = await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (response.user != null) {
        // 3. Ambil Role dari tabel 'profiles'
        // PERBAIKAN: Menggunakan kolom 'user_id' sesuai screenshot database kamu
        final userData = await supabase
            .from('profiles')
            .select('role')
            .eq(
              'user_id',
              response.user!.id,
            ) // Perubahan dari 'id' ke 'user_id'
            .maybeSingle();

        if (userData == null) {
          throw "User terdaftar di Auth, tapi data Role di tabel 'profiles' tidak ditemukan.";
        }

        final String role = userData['role'].toString().toLowerCase();

        if (!mounted) return;

        // 4. Navigasi Berdasarkan Role
        if (role == 'admin') {
          Navigator.pushReplacementNamed(context, '/admin_dashboard');
        } else if (role == 'petugas') {
          Navigator.pushReplacementNamed(context, '/petugas_dashboard');
        } else if (role == 'peminjam') {
          Navigator.pushReplacementNamed(context, '/peminjam_dashboard');
        } else {
          _showErrorSnackBar("Role '$role' tidak dikenali.");
        }
      }
    } on AuthException catch (error) {
      _showErrorSnackBar("Login Gagal: ${error.message}");
    } catch (error) {
      _showErrorSnackBar("Kesalahan: $error");
      print("Error Detail: $error");
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
              children: [
                const Text(
                  'HAI, SELAMAT DATANG!',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),
                // Gunakan Icon jika asset belum diatur di pubspec.yaml
                const Icon(
                  Icons.account_circle,
                  size: 150,
                  color: Color(0xFF4A90E2),
                ),
                const SizedBox(height: 50),
                _buildField("Email", _emailController, false),
                const SizedBox(height: 20),
                _buildField("Password", _passwordController, true),
                const SizedBox(height: 40),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, bool isPass) {
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
          controller: ctrl,
          obscureText: isPass ? _isObscured : false,
          decoration: InputDecoration(
            suffixIcon: isPass
                ? IconButton(
                    icon: Icon(
                      _isObscured ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () => setState(() => _isObscured = !_isObscured),
                  )
                : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 15,
            ),
          ),
        ),
      ],
    );
  }
}
