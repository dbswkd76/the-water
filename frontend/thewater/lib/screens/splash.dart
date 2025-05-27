import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thewater/providers/user_provider.dart';
import 'package:thewater/screens/login.dart';
import 'package:thewater/screens/thewater.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(milliseconds: 800));
    await Provider.of<UserModel>(context, listen: false).fetchUserInfo();
    final isLoggedIn =
        Provider.of<UserModel>(context, listen: false).isLoggedIn;

    if (isLoggedIn) {
      Navigator.pushReplacementNamed(context, '/main');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
