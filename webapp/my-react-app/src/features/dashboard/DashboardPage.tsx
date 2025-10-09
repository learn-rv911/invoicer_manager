// src/features/dashboard/DashboardPage.tsx
// ROOT CAUSE FIX: Now properly manages filter state and fetches all data sources
// (summary, invoices, payments) with applied filters. Dropdown options fetched separately.
import {useState} from "react";
import {useQuery} from "@tanstack/react-query";
import {
    getDashboardSummary,
    getRecentInvoices,
    getRecentPayments,
    listCompanies,
    listClients,
    listProjects,
} from "./api";
import {formatCurrency} from "../../utils/currency";
import {formatDate} from "../../utils/date";
import FiltersBar from "./components/FiltersBar";
import {DashboardFilters} from "./types";

const DashboardPage = () => {
    // Filter state (default: all time, all entities)
    const [filters, setFilters] = useState<DashboardFilters>({duration: "all"});

    // Fetch dropdown options (independent of filters)
    const {data: companies = []} = useQuery({
        queryKey: ["companies:select"],
        queryFn: listCompanies,
    });

    const {data: clients = []} = useQuery({
        queryKey: ["clients:select", filters.companyId],
        queryFn: () => listClients(filters.companyId),
        enabled: !!filters.companyId,
    });

    const {data: projects = []} = useQuery({
        queryKey: ["projects:select", filters.companyId, filters.clientId],
        queryFn: () => listProjects(filters.companyId, filters.clientId),
        enabled: !!filters.companyId && !!filters.clientId,
    });

    // Fetch dashboard data (changes trigger refetch via queryKey dependency)
    const {data: summaryData, isLoading: loadingSummary, error: errorSummary} = useQuery({
        queryKey: ["dashboard:summary", filters],
        queryFn: () => getDashboardSummary(filters),
    });

    const {data: recentInvoices = [], isLoading: loadingInvoices} = useQuery({
        queryKey: ["dashboard:recentInvoices", filters],
        queryFn: () => getRecentInvoices(filters),
    });

    const {data: recentPayments = [], isLoading: loadingPayments} = useQuery({
        queryKey: ["dashboard:recentPayments", filters],
        queryFn: () => getRecentPayments(filters),
    });

    const isLoading = loadingSummary || loadingInvoices || loadingPayments;

    if (isLoading && !summaryData) {
        return (
            <div className="space-y-6">
                <div>
                    <h1 className="text-2xl font-bold text-gray-900">Dashboard</h1>
                    <p className="text-gray-600">Loading dashboard data...</p>
                </div>
                <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                    {[1, 2, 3].map((i) => (
                        <div key={i} className="bg-white p-6 rounded-lg shadow animate-pulse">
                            <div className="h-4 bg-gray-200 rounded w-1/2 mb-2"></div>
                            <div className="h-8 bg-gray-200 rounded w-1/3"></div>
                        </div>
                    ))}
                </div>
            </div>
        );
    }

    if (errorSummary) {
        return (
            <div className="space-y-6">
                <div>
                    <h1 className="text-2xl font-bold text-gray-900">Dashboard</h1>
                    <p className="text-gray-600">Error loading dashboard data</p>
                </div>
                <div className="bg-red-50 border border-red-200 text-red-600 px-4 py-3 rounded-md">
                    Failed to load dashboard data. Please try again.
                </div>
            </div>
        );
    }

    const metrics = summaryData?.metrics || {
        total_invoices: 0,
        total_amount: 0,
        total_paid: 0,
        outstanding: 0,
    };

    const totalRecentPaymentsSum = recentPayments.reduce((sum: number, p: any) => sum + (p?.amount || 0), 0);
    const totalDueSum = recentInvoices
        .filter((inv: any) => {
            if (!inv?.due_date) return false;
            const due = new Date(inv.due_date as string);
            const now = new Date();
            const in30 = new Date();
            in30.setDate(now.getDate() + 30);
            return due >= now && due <= in30;
        })
        .reduce((sum: number, inv: any) => sum + (inv?.total || 0), 0);

    return (
        <div className="space-y-6">
            {/* Page header with actions */}
            <div className="flex items-center justify-between">
                <div>
                    <h1 className="text-3xl font-bold text-gray-900">Dashboard</h1>
                    <p className="text-gray-600">Welcome to your invoice management dashboard</p>
                </div>
                <div className="flex items-center gap-3">
                    <a
                        href="/invoices/new"
                        className="hidden sm:inline-flex items-center rounded-lg bg-blue-600 px-4 py-2 text-white hover:bg-blue-700 shadow"
                    >
                        Create New Invoice
                    </a>
                    <a
                        href="/payments/new"
                        className="hidden sm:inline-flex items-center rounded-lg bg-white px-4 py-2 text-gray-900 border border-gray-200 hover:bg-gray-50 shadow-sm"
                    >
                        Create New Payment
                    </a>
                </div>
            </div>

            {/* Filters Bar - now controlled by this component */}
            <FiltersBar
                filters={filters}
                onChange={setFilters}
                companies={companies}
                clients={clients}
                projects={projects}
            />

            {/* Summary Metrics */}
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-100">
                    <h3 className="text-sm font-medium text-gray-600">Invoice Amount</h3>
                    <p className="mt-2 text-4xl font-bold text-gray-900">{formatCurrency(metrics.outstanding)}</p>
                </div>
                <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-100">
                    <h3 className="text-sm font-medium text-gray-600">Received payment</h3>
                    <p className="mt-2 text-4xl font-bold text-gray-900">{formatCurrency(totalRecentPaymentsSum)}</p>
                </div>
                <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-100">
                    <h3 className="text-sm font-medium text-gray-600">Total pending</h3>
                    <p className="mt-2 text-4xl font-bold text-gray-900">{formatCurrency(totalDueSum)}</p>
                </div>
            </div>

            {/* Recent Lists */}
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                {/* Recent Invoices */}
                <div className="bg-white rounded-xl shadow-sm border border-gray-100">
                    <div className="p-6">
                        <h3 className="text-lg font-medium text-gray-900 mb-4">Recent Invoices</h3>
                        {loadingInvoices ? (
                            <p className="text-gray-500">Loading...</p>
                        ) : recentInvoices.length > 0 ? (
                            <div className="space-y-3">
                                {recentInvoices.slice(0, 5).map((invoice: any) => (
                                    <div key={invoice.id}
                                         className="flex items-center justify-between py-2 border-b border-gray-100 last:border-b-0">
                                        <div>
                                            <p className="text-sm font-medium text-gray-900">{invoice.invoice_number}</p>
                                            <p className="text-xs text-gray-500">{formatDate(invoice.issue_date)}</p>
                                        </div>
                                        <div className="text-right">
                                            <p className="text-sm font-medium text-gray-900">{formatCurrency(invoice.total)}</p>
                                            <span
                                                className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${
                                                    invoice.status === 'paid' ? 'bg-green-100 text-green-800' :
                                                        invoice.status === 'sent' ? 'bg-blue-100 text-blue-800' :
                                                            invoice.status === 'draft' ? 'bg-gray-100 text-gray-800' :
                                                                'bg-red-100 text-red-800'
                                                }`}>
                        {invoice.status}
                      </span>
                                        </div>
                                    </div>
                                ))}
                            </div>
                        ) : (
                            <p className="text-gray-500">No invoices found for selected filters</p>
                        )}
                    </div>
                </div>

                {/* Recent Payments */}
                <div className="bg-white rounded-xl shadow-sm border border-gray-100">
                    <div className="p-6">
                        <h3 className="text-lg font-medium text-gray-900 mb-4">Recent Payments</h3>
                        {loadingPayments ? (
                            <p className="text-gray-500">Loading...</p>
                        ) : recentPayments.length > 0 ? (
                            <div className="space-y-3">
                                {recentPayments.slice(0, 5).map((payment: any) => (
                                    <div key={payment.id}
                                         className="flex items-center justify-between py-2 border-b border-gray-100 last:border-b-0">
                                        <div>
                                            <p className="text-sm font-medium text-gray-900">{payment.payment_number}</p>
                                            <p className="text-xs text-gray-500">{formatDate(payment.payment_date)}</p>
                                        </div>
                                        <div className="text-right">
                                            <p className="text-sm font-medium text-gray-900">{formatCurrency(payment.amount)}</p>
                                            <p className="text-xs text-gray-500">{payment.method || 'N/A'}</p>
                                        </div>
                                    </div>
                                ))}
                            </div>
                        ) : (
                            <p className="text-gray-500">No payments found for selected filters</p>
                        )}
                    </div>
                </div>
            </div>
        </div>
    );
};

export default DashboardPage;
