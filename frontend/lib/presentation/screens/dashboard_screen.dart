import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme_constants.dart';
import '../../application/dashboard_provider.dart';
import '../../application/company_provider.dart';
import '../../application/client_provider.dart';
import '../../application/project_provider.dart';
import '../../utils/formatters.dart';
import '../widgets/dashboard/dashboard_filter_bar.dart';
import '../widgets/dashboard/payment_overview_card.dart';
import '../widgets/dashboard/summary_stat_card.dart';
import '../widgets/dashboard/recent_invoices_list.dart';
import '../widgets/dashboard/recent_payments_list.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _loadedOnce = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_loadedOnce) {
        ref.read(dashboardProvider.notifier).load();
        ref.read(companyProvider.notifier).loadCompanies();
        ref.read(clientProvider.notifier).loadClients();
        ref.read(projectProvider.notifier).loadProjects();
        _loadedOnce = true;
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: state.loading && state.summary == null
          ? _buildLoadingState()
          : state.error != null
              ? _buildErrorState(state.error!)
              : _buildDashboard(state),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
          ),
          SizedBox(height: AppTheme.spacing16),
          Text(
            'Loading dashboard...',
            style: AppTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: AppTheme.danger,
          ),
          const SizedBox(height: AppTheme.spacing16),
          Text(
            'Error loading dashboard',
            style: AppTheme.headingSmall.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spacing8),
          Text(
            error,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacing24),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacing24,
                vertical: AppTheme.spacing12,
              ),
            ),
            onPressed: () => ref.read(dashboardProvider.notifier).load(),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard(DashboardState state) {
    final summary = state.summary;
    if (summary == null) {
      return _buildErrorState('No data available');
    }

    return Column(
      children: [
        // Sticky Filter Bar
        const DashboardFilterBar(),
        
        // Scrollable Content
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await ref.read(dashboardProvider.notifier).load();
            },
            color: AppTheme.primary,
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(AppTheme.spacing24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  _buildHeader(),
                  const SizedBox(height: AppTheme.spacing24),

                  // Payment Overview Section
                  PaymentOverviewCard(
                    totalAmount: summary.metrics.totalAmount,
                    paidAmount: summary.metrics.totalPaid,
                    outstandingAmount: summary.metrics.outstanding,
                  ),
                  const SizedBox(height: AppTheme.spacing24),

                  // KPI Cards Grid
                  _buildKpiGrid(summary),
                  const SizedBox(height: AppTheme.spacing32),

                  // Recent Data Lists
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth < 900) {
                        return Column(
                          children: [
                            RecentInvoicesList(
                              invoices: summary.recentInvoices,
                            ),
                            const SizedBox(height: AppTheme.spacing24),
                            RecentPaymentsList(
                              payments: summary.recentPayments,
                            ),
                          ],
                        );
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: RecentInvoicesList(
                              invoices: summary.recentInvoices,
                            ),
                          ),
                          const SizedBox(width: AppTheme.spacing24),
                          Expanded(
                            child: RecentPaymentsList(
                              payments: summary.recentPayments,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: AppTheme.spacing40),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard',
              style: AppTheme.headingLarge.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: AppTheme.spacing4),
            Text(
              'Overview of your business performance',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKpiGrid(summary) {
    final collectionRate = summary.metrics.totalAmount > 0
        ? (summary.metrics.totalPaid / summary.metrics.totalAmount * 100)
        : 0.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Determine number of columns based on width
        int crossAxisCount = 1;
        if (constraints.maxWidth >= 1200) {
          crossAxisCount = 4;
        } else if (constraints.maxWidth >= 768) {
          crossAxisCount = 2;
        }

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: AppTheme.spacing16,
          crossAxisSpacing: AppTheme.spacing16,
          childAspectRatio: 1.5,
          children: [
            SummaryStatCard(
              title: 'Total Invoiced',
              value: fmtMoney(summary.metrics.totalAmount),
              icon: Icons.receipt_long_rounded,
              color: AppTheme.primary,
              subtitle: '${summary.metrics.totalInvoices} invoices',
            ),
            SummaryStatCard(
              title: 'Total Received',
              value: fmtMoney(summary.metrics.totalPaid),
              icon: Icons.payments_rounded,
              color: AppTheme.success,
              subtitle: 'Paid amount',
            ),
            SummaryStatCard(
              title: 'Outstanding',
              value: fmtMoney(summary.metrics.outstanding),
              icon: Icons.schedule_rounded,
              color: AppTheme.warning,
              subtitle: 'Pending payment',
            ),
            SummaryStatCard(
              title: 'Collection Rate',
              value: '${collectionRate.toStringAsFixed(1)}%',
              icon: Icons.trending_up_rounded,
              color: collectionRate > 80 ? AppTheme.success : AppTheme.danger,
              subtitle: 'Payment efficiency',
              delta: '12%',
              isPositiveDelta: true,
            ),
          ],
        );
      },
    );
  }
}

