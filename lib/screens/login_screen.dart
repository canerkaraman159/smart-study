import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme/app_colors.dart';
import '../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _hidePassword = true;
  bool _isLoading = false;
  bool _isRegisterMode = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showMessage('Lütfen e-posta ve şifre alanlarını doldur.');
      return;
    }

    if (password.length < 6) {
      _showMessage('Şifre en az 6 karakter olmalıdır.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isRegisterMode) {
        await _auth.createUserWithEmailAndPassword(email: email, password: password);
      } else {
        await _auth.signInWithEmailAndPassword(email: email, password: password);
      }

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
    } on FirebaseAuthException catch (error) {
      debugPrint('FIREBASE AUTH HATASI | code: ${error.code} | message: ${error.message}');
      _showMessage('Kod: ${error.code}\n${error.message ?? _getFirebaseErrorMessage(error.code)}');
    } catch (e, stackTrace) {
      debugPrint('KAYIT HATASI: $e');
      debugPrintStack(stackTrace: stackTrace);
      _showMessage(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showMessage('Önce e-posta adresini yaz.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _auth.sendPasswordResetEmail(email: email);

      _showMessage('Şifre sıfırlama bağlantısı e-posta adresine gönderildi.');
    } on FirebaseAuthException catch (error) {
      _showMessage(_getFirebaseErrorMessage(error.code));
    } catch (e) {
      debugPrint('RESET HATASI: $e');
      _showMessage(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getFirebaseErrorMessage(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Geçerli bir e-posta adresi gir.';
      case 'user-not-found':
        return 'Bu e-posta adresiyle kayıtlı kullanıcı bulunamadı.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'E-posta veya şifre hatalı.';
      case 'email-already-in-use':
        return 'Bu e-posta adresi zaten kullanılıyor.';
      case 'weak-password':
        return 'Şifre çok zayıf. En az 6 karakter kullan.';
      case 'too-many-requests':
        return 'Çok fazla deneme yapıldı. Bir süre sonra tekrar dene.';
      case 'network-request-failed':
        return 'İnternet bağlantısını kontrol et.';
      case 'operation-not-allowed':
        return 'E-posta/şifre girişi Firebase Console’da etkin değil.';
      default:
        return 'İşlem tamamlanamadı. Tekrar dene.';
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message), behavior: SnackBarBehavior.floating));
  }

  void _continueAsGuest() {
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  width: 190,
                  height: 190,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(28)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Image.asset('assets/images/logo.png', fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Planla • Odaklan • Başar',
                  style: GoogleFonts.inter(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 32),
                Card(
                  color: Colors.white,
                  surfaceTintColor: Colors.white,
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      children: [
                        Text(
                          _isRegisterMode ? 'Hesap Oluştur' : 'Tekrar Hoş Geldin',
                          style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 22),
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.email],
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.email_outlined),
                            hintText: 'E-posta',
                            filled: true,
                            fillColor: const Color(0xFFF7F9FC),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _passwordController,
                          obscureText: _hidePassword,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.password],
                          onSubmitted: (_) {
                            if (!_isLoading) {
                              _submit();
                            }
                          },
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(_hidePassword ? Icons.visibility_off : Icons.visibility),
                              onPressed: () {
                                setState(() {
                                  _hidePassword = !_hidePassword;
                                });
                              },
                            ),
                            hintText: 'Şifre',
                            filled: true,
                            fillColor: const Color(0xFFF7F9FC),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
                          ),
                        ),
                        if (!_isRegisterMode)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(onPressed: _isLoading ? null : _resetPassword, child: const Text('Şifremi unuttum?')),
                          )
                        else
                          const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                            ),
                            onPressed: _isLoading ? null : _submit,
                            child: _isLoading
                                ? const SizedBox(width: 23, height: 23, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                                : Text(
                                    _isRegisterMode ? 'Hesap Oluştur' : 'Giriş Yap',
                                    style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 18, color: Colors.white),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  setState(() {
                                    _isRegisterMode = !_isRegisterMode;
                                  });
                                },
                          child: Text(_isRegisterMode ? 'Zaten hesabın var mı? Giriş yap' : 'Hesabın yok mu? Kayıt ol'),
                        ),
                        TextButton(onPressed: _isLoading ? null : _continueAsGuest, child: const Text('Misafir olarak devam et →')),
                      ],
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
}
