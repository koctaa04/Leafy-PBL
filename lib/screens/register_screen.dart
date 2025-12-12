import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
    bool _isLoading = false;
    String? _firebaseError;
  String? _usernameError;

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _showPassword = false;
  bool _showConfirm = false;
  String? _emailError;
  String? _passwordError;
  String? _confirmError;

  // Simulasi pengecekan username ke database (ganti dengan API call asli jika ada)
  Future<bool> cekUsernameTerpakai(String username) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Contoh: username 'leafyuser123' dianggap sudah terpakai
    return username.trim().toLowerCase() == 'leafyuser123';
  }

  Future<void> _validateUsername() async {
    setState(() {
      _usernameError = null;
    });
    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      setState(() {
        _usernameError = 'Username tidak boleh kosong';
      });
      return;
    }
    final exists = await cekUsernameTerpakai(username);
    if (exists) {
      setState(() {
        _usernameError = 'Username sudah digunakan';
      });
    }
  }

  bool _isPasswordValid(String value) {
    final regex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$');
    return regex.hasMatch(value);
  }
  bool _isEmailValid(String value) {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(value);
  }


  void _validateEmail() {
    setState(() {
      _emailError = null;
      if (!_isEmailValid(_emailController.text)) {
        _emailError = 'Email tidak valid';
      }
    });
  }

  void _validatePassword() {
    setState(() {
      _passwordError = null;
      if (!_isPasswordValid(_passwordController.text)) {
        _passwordError = 'Minimal 8 karakter, huruf & angka';
      }
    });
  }

  void _validateConfirm() {
    setState(() {
      _confirmError = null;
      if (_passwordController.text != _confirmController.text) {
        _confirmError = 'Konfirmasi password tidak sama';
      }
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Fullscreen gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFE8F5E9),
                  Color(0xFFB3E5FC),
                ],
              ),
            ),
          ),
          // Foreground scrollable content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(bottom: bottomInset, left: 24.0, right: 24.0, top: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 32),
                  Image.asset(
                    'assets/logo-leafy.png',
                    width: 56,
                    height: 56,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Daftar Akun Baru',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Isi data di bawah untuk membuat akun',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 18),
                  // Username
                  Align(
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      'Username',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _usernameController,
                      onChanged: (_) => _validateUsername(),
                      decoration: InputDecoration(
                        hintText: 'contoh: leafy',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      ),
                    ),
                  ),
                  if (_usernameError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6, left: 4, bottom: 2),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _usernameError!,
                          style: const TextStyle(color: Colors.red, fontSize: 13),
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),
                  // Email
                  Align(
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      'Email',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _emailController,
                      onChanged: (_) => _validateEmail(),
                      decoration: InputDecoration(
                        hintText: 'contoh: leafy@email.com',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                  if (_emailError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6, left: 4, bottom: 2),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _emailError!,
                          style: const TextStyle(color: Colors.red, fontSize: 13),
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),
                  // Password
                  Align(
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      'Password',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: !_showPassword,
                      onChanged: (_) => _validatePassword(),
                      decoration: InputDecoration(
                        hintText: 'minimal 8 karakter',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        suffixIcon: IconButton(
                          icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              _showPassword = !_showPassword;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  if (_passwordError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6, left: 4, bottom: 2),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _passwordError!,
                          style: const TextStyle(color: Colors.red, fontSize: 13),
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),
                  // Konfirmasi Password
                  Align(
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      'Konfirmasi Password',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _confirmController,
                      obscureText: !_showConfirm,
                      onChanged: (_) => _validateConfirm(),
                      decoration: InputDecoration(
                        hintText: 'ulangi password',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        suffixIcon: IconButton(
                          icon: Icon(_showConfirm ? Icons.visibility : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              _showConfirm = !_showConfirm;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  if (_confirmError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6, left: 4, bottom: 2),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _confirmError!,
                          style: const TextStyle(color: Colors.red, fontSize: 13),
                        ),
                      ),
                    ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () async {
                        await _validateUsername();
                        _validateEmail();
                        _validatePassword();
                        _validateConfirm();
                        if (_usernameError == null && _emailError == null && _passwordError == null && _confirmError == null) {
                          setState(() {
                            _isLoading = true;
                            _firebaseError = null;
                          });
                          try {
                            final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                              email: _emailController.text.trim(),
                              password: _passwordController.text.trim(),
                            );
                            // Sukses daftar, bisa simpan username ke Firestore jika perlu
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          } on FirebaseAuthException catch (e) {
                            setState(() {
                              _firebaseError = e.message ?? 'Gagal daftar, coba lagi.';
                            });
                          } catch (e) {
                            setState(() {
                              _firebaseError = 'Gagal daftar, coba lagi.';
                            });
                          } finally {
                            setState(() {
                              _isLoading = false;
                            });
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00C853),
                        shape: const StadiumBorder(),
                        elevation: 2,
                      ),
                      child: const Text(
                        'Daftar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  if (_firebaseError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 2),
                      child: Text(
                        _firebaseError!,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Sudah punya akun? ',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black54,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Masuk',
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF00C853),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
