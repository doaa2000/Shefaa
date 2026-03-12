import 'package:flutter/material.dart';
import 'package:shefaa_app/core/services/secure_storage_service.dart';
import 'package:get_it/get_it.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final SecureStorageService secureStorage =
      GetIt.instance<SecureStorageService>();

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final token = await secureStorage.getAccessToken();

    await Future.delayed(const Duration(seconds: 1)); 

    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      Navigator.pushReplacementNamed(context, '/home-screen');
    } else {
      Navigator.pushReplacementNamed(context, '/login-screen');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}