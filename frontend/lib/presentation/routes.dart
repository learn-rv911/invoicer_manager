import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../presentation/widgets/app_shell.dart';
import 'screens/clients_screen.dart';
// Placeholder pages for lists (you can replace later)
import 'screens/companies_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/invoices_screen.dart';
import 'screens/login_screen.dart';
import 'screens/payments_screen.dart';
import 'screens/projects_screen.dart';

final router = GoRouter(
  routes: [
    // public route: login
    GoRoute(path: '/', builder: (context, state) => const LoginScreen()),

    // private area wrapped in AppShell
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/companies',
          builder: (context, state) => const CompaniesScreen(),
        ),
        GoRoute(
          path: '/clients',
          builder: (context, state) => const ClientsScreen(),
        ),
        GoRoute(
          path: '/projects',
          builder: (context, state) => const ProjectsScreen(),
        ),
        GoRoute(
          path: '/invoices',
          builder: (context, state) => const InvoicesScreen(),
        ),
        GoRoute(
          path: '/payments',
          builder: (context, state) => const PaymentsScreen(),
        ),
      ],
    ),
  ],
);
