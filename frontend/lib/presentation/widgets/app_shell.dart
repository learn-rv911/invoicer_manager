import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/client_provider.dart';
import '../../application/company_provider.dart';
import '../../application/invoice_provider.dart';
import '../../application/payment_provider.dart';
import '../../application/project_provider.dart';
import '../screens/clients_screen.dart';
import '../screens/companies_screen.dart';
import '../screens/invoices_screen.dart';
import '../screens/payments_screen.dart';
import '../screens/projects_screen.dart';

class AppShell extends ConsumerWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWide = MediaQuery.of(context).size.width >= 920;
    final route = GoRouterState.of(context).uri.toString();

    final sidebar = _Sidebar();

    // Get title and actions based on current route
    final appBarData = _getAppBarData(context, ref, route, isWide);

    return Scaffold(
      appBar:
          isWide
              ? null
              : AppBar(
                title: Text(appBarData.title),
                actions: appBarData.actions,
              ),
      drawer: isWide ? null : Drawer(child: sidebar),
      body: Row(
        children: [
          if (isWide)
            ConstrainedBox(
              constraints: BoxConstraints(minWidth: 240, maxWidth: 260),
              child: Material(
                elevation: 2,
                color: Theme.of(context).colorScheme.surface,
                child: sidebar,
              ),
            ),
          Expanded(
            child: Container(
              color: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withOpacity(0.02),
              child: child,
            ),
          ),
        ],
      ),
      floatingActionButton: _getFloatingActionButton(context, ref, route),
    );
  }

  _AppBarData _getAppBarData(
    BuildContext context,
    WidgetRef ref,
    String route,
    bool isWide,
  ) {
    switch (route) {
      case '/dashboard':
        return _AppBarData(
          title: 'Dashboard',
          actions: isWide ? [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: FilledButton.tonal(
                onPressed: () => _showPaymentForm(context, ref),
                child: const Text("＋ Received Payment"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: FilledButton(
                onPressed: () => _showInvoiceForm(context, ref),
                child: const Text("＋ Create Invoice"),
              ),
            ),
          ] : [],
        );
      case '/companies':
        return _AppBarData(
          title: 'Companies',
          actions: isWide ? [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: FilledButton.icon(
                onPressed: () => _showCreateCompanyDialog(context, ref),
                icon: const Icon(Icons.add),
                label: const Text("Add Company"),
              ),
            ),
          ] : [],
        );
      case '/clients':
        return _AppBarData(
          title: 'Clients',
          actions: isWide ? [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: FilledButton.icon(
                onPressed: () => _showCreateClientDialog(context, ref),
                icon: const Icon(Icons.add),
                label: const Text("Add Client"),
              ),
            ),
          ] : [],
        );
      case '/projects':
        return _AppBarData(
          title: 'Projects',
          actions: isWide ? [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: FilledButton.icon(
                onPressed: () => _showCreateProjectDialog(context, ref),
                icon: const Icon(Icons.add),
                label: const Text("New Project"),
              ),
            ),
          ] : [],
        );
      case '/invoices':
        return _AppBarData(
          title: 'Invoices',
          actions: isWide ? [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: FilledButton.icon(
                onPressed: () => _showCreateInvoiceDialog(context, ref),
                icon: const Icon(Icons.add),
                label: const Text("New Invoice"),
              ),
            ),
          ] : [],
        );
      case '/payments':
        return _AppBarData(
          title: 'Payments',
          actions: isWide ? [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: FilledButton.icon(
                onPressed: () => _showCreatePaymentDialog(context, ref),
                icon: const Icon(Icons.add),
                label: const Text("New Payment"),
              ),
            ),
          ] : [],
        );
      default:
        return _AppBarData(title: 'Invoicer', actions: []);
    }
  }

  Widget? _getFloatingActionButton(BuildContext context, WidgetRef ref, String route) {
    switch (route) {
      case '/dashboard':
        return FloatingActionButton.extended(
          onPressed: () => _showInvoiceForm(context, ref),
          icon: const Icon(Icons.receipt_long),
          label: const Text("Create Invoice"),
        );
      case '/companies':
        return FloatingActionButton.extended(
          onPressed: () => _showCreateCompanyDialog(context, ref),
          icon: const Icon(Icons.add),
          label: const Text("Add Company"),
        );
      case '/clients':
        return FloatingActionButton.extended(
          onPressed: () => _showCreateClientDialog(context, ref),
          icon: const Icon(Icons.add),
          label: const Text("Add Client"),
        );
      case '/projects':
        return FloatingActionButton.extended(
          onPressed: () => _showCreateProjectDialog(context, ref),
          icon: const Icon(Icons.add),
          label: const Text("New Project"),
        );
      case '/invoices':
        return FloatingActionButton.extended(
          onPressed: () => _showCreateInvoiceDialog(context, ref),
          icon: const Icon(Icons.add),
          label: const Text("New Invoice"),
        );
      case '/payments':
        return FloatingActionButton.extended(
          onPressed: () => _showCreatePaymentDialog(context, ref),
          icon: const Icon(Icons.add),
          label: const Text("New Payment"),
        );
      default:
        return null;
    }
  }

  // Dialog methods
  void _showPaymentForm(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder:
          (context) => PaymentFormDialog(
            payment: null,
            onSave: (paymentCreate) async {
              try {
                await ref
                    .read(paymentProvider.notifier)
                    .createPayment(paymentCreate);
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Payment recorded successfully"),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Error recording payment: $e"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
    );
  }

  void _showInvoiceForm(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder:
          (context) => InvoiceFormDialog(
            invoice: null,
            onSave: (invoiceCreate) async {
              try {
                await ref
                    .read(invoiceProvider.notifier)
                    .createInvoice(invoiceCreate);
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Invoice created successfully"),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Error creating invoice: $e"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
    );
  }

  void _showCreateCompanyDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder:
          (context) => CompanyFormDialog(
            onSave: (companyCreate) async {
              final result = await ref
                  .read(companyProvider.notifier)
                  .createCompany(companyCreate);
              if (result != null && context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Company created successfully")),
                );
              }
            },
          ),
    );
  }

  void _showCreateClientDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder:
          (context) => ClientFormDialog(
            onSave: (clientCreate) async {
              final result = await ref
                  .read(clientProvider.notifier)
                  .createClient(clientCreate);
              if (result != null && context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Client created successfully")),
                );
              }
            },
          ),
    );
  }

  void _showCreateProjectDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder:
          (context) => ProjectFormDialog(
            onSave: (projectCreate) async {
              final result = await ref
                  .read(projectProvider.notifier)
                  .createProject(projectCreate);
              if (result != null && context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Project created successfully")),
                );
              }
            },
          ),
    );
  }

  void _showCreateInvoiceDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder:
          (context) => InvoiceFormDialog(
            invoice: null,
            onSave: (invoiceCreate) async {
              try {
                await ref
                    .read(invoiceProvider.notifier)
                    .createInvoice(invoiceCreate);
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Invoice created successfully"),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Error creating invoice: $e"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
    );
  }

  void _showCreatePaymentDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder:
          (context) => PaymentFormDialog(
            payment: null,
            onSave: (paymentCreate) async {
              try {
                await ref
                    .read(paymentProvider.notifier)
                    .createPayment(paymentCreate);
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Payment recorded successfully"),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Error recording payment: $e"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
    );
  }
}

class _AppBarData {
  final String title;
  final List<Widget> actions;

  _AppBarData({required this.title, required this.actions});
}

class _Sidebar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final route = GoRouterState.of(context).uri.toString();

    Widget item({
      required IconData icon,
      required String label,
      required String to,
      bool matchExact = false,
    }) {
      final selected = matchExact ? route == to : route.startsWith(to);
      return ListTile(
        leading: Icon(
          icon,
          color: selected ? Theme.of(context).colorScheme.primary : null,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: selected ? Theme.of(context).colorScheme.primary : null,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        selected: selected,
        onTap: () {
          // close drawer if on narrow
          if (Scaffold.of(context).isDrawerOpen) Navigator.of(context).pop();
          if (!selected) context.go(to);
        },
      );
    }

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 14),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "INVOICER",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),

          // nav items
          item(
            icon: Icons.dashboard,
            label: "Dashboard",
            to: "/dashboard",
            matchExact: true,
          ),
          const SizedBox(height: 6),
          item(icon: Icons.business, label: "Companies", to: "/companies"),
          item(icon: Icons.people_alt, label: "Clients", to: "/clients"),
          item(icon: Icons.work_outline, label: "Projects", to: "/projects"),
          item(icon: Icons.receipt_long, label: "Invoices", to: "/invoices"),
          item(
            icon: Icons.payments_outlined,
            label: "Payments",
            to: "/payments",
          ),

          const Spacer(),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
            onTap: () => context.go("/"),
          ),
        ],
      ),
    );
  }
}
