import 'package:flutter/material.dart';
import 'package:hidratrack/Servicos/AuthStorage.dart';
import 'package:hidratrack/Telas/Telalogin.dart';

class AuthHelper {
  static Future<void> logout(BuildContext context) async {
    await AuthStorage.clear();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const Telalogin()),
      (_) => false,
    );
  }
}
