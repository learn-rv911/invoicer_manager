import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invoice/presentation/routes.dart';

void main() {
  runApp(const ProviderScope(child: InvoicerApp()));
}

class InvoicerApp extends StatelessWidget {
  const InvoicerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: "Invoicer",
      routerConfig: router,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
    );
  }
}
