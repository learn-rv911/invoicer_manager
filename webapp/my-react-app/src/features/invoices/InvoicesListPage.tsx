import {useMemo, useState} from "react";
import {useQuery, useMutation, useQueryClient} from "@tanstack/react-query";
import {listInvoices, deleteInvoice} from "./api";
import {listClients} from "../clients/api";
import {listCompanies} from "../companies/api";
import {listProjects} from "../projects/api";
import {formatCurrency} from "../../utils/currency";
import {formatDate} from "../../utils/date";
import ConfirmDialog from "../../components/ConfirmDialog";
import {useToast} from "../../components/Toast";

/** Helper types so we can accept either an array or { items, total } */
type Invoice = any; // replace with your real Invoice type if available
type InvoicesResponse = Invoice[] | { items: Invoice[]; total: number };

const InvoicesListPage = () => {
    // Filters & paging
    const [query, setQuery] = useState("");
    const [status, setStatus] = useState<string | undefined>(undefined);
    const [companyId, setCompanyId] = useState<number | undefined>(undefined);
    const [clientId, setClientId] = useState<number | undefined>(undefined);
    const [projectId, setProjectId] = useState<number | undefined>(undefined);
    const [duration, setDuration] = useState<string>("");
    const [page, setPage] = useState(0);
    const limit = 10;

    // Delete dialog state
    const [confirmOpen, setConfirmOpen] = useState(false);
    const [targetId, setTargetId] = useState<number | null>(null);
    const qc = useQueryClient();
    const {setToast, Toast} = useToast();

    const {data, isLoading, error} = useQuery<InvoicesResponse>({
        queryKey: ["invoices", {query, status, companyId, clientId, projectId, page}],
        queryFn: () =>
            listInvoices(
                query || undefined,
                status || undefined,
                clientId,
                projectId,
                companyId,
                page * limit,
                limit
            ),
    });

    const {data: companies} = useQuery({
        queryKey: ["companies:for-select"],
        queryFn: () => listCompanies(undefined, 0, 100),
    });

    const {data: clients} = useQuery({
        queryKey: ["clients:for-select", companyId],
        queryFn: () => listClients(undefined, companyId, 0, 100),
        enabled: true,
    });

    const {data: projects} = useQuery({
        queryKey: ["projects:for-select", companyId, clientId],
        queryFn: () => listProjects(undefined, companyId, clientId, undefined, 0, 100),
        enabled: true,
    });

    // Delete mutation with optimistic update
    const {mutateAsync: removeInvoice} = useMutation({
        mutationFn: async (id: number) => await deleteInvoice(id),
        onMutate: async (id) => {
            // Cancel outgoing refetches
            await qc.cancelQueries({queryKey: ["invoices"]});
            
            // Snapshot the previous value
            const queryKey = ["invoices", {query, status, companyId, clientId, projectId, page}];
            const prev = qc.getQueryData<InvoicesResponse>(queryKey);
            
            // Optimistically update by filtering out the deleted invoice
            if (prev) {
                const items = Array.isArray(prev) ? prev : prev.items ?? [];
                const optimisticItems = items.filter((i: any) => i.id !== id);
                const optimisticData = Array.isArray(prev) 
                    ? optimisticItems 
                    : {...prev, items: optimisticItems, total: (prev.total ?? 0) - 1};
                qc.setQueryData(queryKey, optimisticData);
            }
            
            return {prev, queryKey};
        },
        onError: (_err, _id, ctx) => {
            // Rollback on error
            if (ctx?.prev && ctx?.queryKey) {
                qc.setQueryData(ctx.queryKey, ctx.prev);
            }
            setToast("Failed to delete invoice.");
        },
        onSuccess: () => {
            setToast("Invoice deleted successfully.");
            // Invalidate dashboard and other related queries
            qc.invalidateQueries({queryKey: ["dashboard:summary"]}).catch(() => {});
            qc.invalidateQueries({queryKey: ["dash:summary"]}).catch(() => {});
        },
    });

    // Normalize data -> items & total
    const items: Invoice[] = Array.isArray(data) ? data : data?.items ?? [];
    const total: number = Array.isArray(data) ? items.length : data?.total ?? 0;

    const clientIdToName = useMemo(() => {
        const map = new Map<number, string>();
        (clients || []).forEach((c: any) => map.set(c.id, c.name));
        return map;
    }, [clients]);

    const projectIdToName = useMemo(() => {
        const map = new Map<number, string>();
        (projects || []).forEach((p: any) => map.set(p.id, p.name));
        return map;
    }, [projects]);

    const filtered = useMemo(() => {
        if (!duration) return items;
        const now = new Date();
        let from: Date | undefined;

        if (duration === "30") {
            from = new Date();
            from.setDate(now.getDate() - 30);
        } else if (duration === "90") {
            from = new Date();
            from.setDate(now.getDate() - 90);
        } else if (duration === "year") {
            from = new Date(now.getFullYear(), 0, 1);
        }
        if (!from) return items;

        return items.filter((inv: any) => {
            const d = new Date(inv.issue_date);
            return d >= from! && d <= now;
        });
    }, [items, duration]);

    // Show pagination only when the dataset is large
    const showPagination = total > 100;

    // Shared class for uniform selects
    const selectClass =
        "h-10 w-48 rounded-md border border-gray-300 px-3 bg-white text-gray-900";

    return (
        <div className="space-y-6">
            {/* Title + CTA */}
            <div className="flex items-center justify-between">
                <h1 className="text-2xl font-bold text-gray-900">Invoices</h1>
                <a href="/invoices/new" className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 shadow">
                    + Create New Invoice
                </a>
            </div>

            {/* Filters */}
            <div
                className="bg-white border border-gray-200 rounded-xl p-4 flex flex-col gap-3 md:flex-row md:items-center md:gap-4">
                {/* Search grows, dropdowns are fixed width */}
                <div className="flex-1">
                    <input
                        value={query}
                        onChange={(e) => {
                            setPage(0);
                            setQuery(e.target.value);
                        }}
                        placeholder="Search invoices..."
                        className="w-full h-10 rounded-md border border-gray-300 px-3 bg-white text-gray-900 placeholder:text-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-500"
                    />
                </div>

                <select
                    value={companyId ? String(companyId) : ""}
                    onChange={(e) => {
                        setPage(0);
                        const v = e.target.value ? Number(e.target.value) : undefined;
                        setCompanyId(v);
                        setClientId(undefined);
                        setProjectId(undefined);
                    }}
                    className={selectClass}
                >
                    <option value="">Company: All</option>
                    {(companies || []).map((c: any) => (
                        <option key={c.id} value={c.id}>
                            {c.name}
                        </option>
                    ))}
                </select>

                <select
                    value={status ?? ""}
                    onChange={(e) => {
                        setPage(0);
                        setStatus(e.target.value || undefined);
                    }}
                    className={selectClass}
                >
                    <option value="">Status: All</option>
                    <option value="paid">Paid</option>
                    <option value="sent">Sent</option>
                    <option value="draft">Draft</option>
                    <option value="overdue">Overdue</option>
                </select>

                <select
                    value={clientId ? String(clientId) : ""}
                    onChange={(e) => {
                        setPage(0);
                        const v = e.target.value ? Number(e.target.value) : undefined;
                        setClientId(v);
                        setProjectId(undefined);
                    }}
                    className={selectClass}
                >
                    <option value="">Client: All</option>
                    {(clients || []).map((c: any) => (
                        <option key={c.id} value={c.id}>
                            {c.name}
                        </option>
                    ))}
                </select>

                <select
                    value={projectId ? String(projectId) : ""}
                    onChange={(e) => {
                        setPage(0);
                        setProjectId(e.target.value ? Number(e.target.value) : undefined);
                    }}
                    className={selectClass}
                >
                    <option value="">Project: All</option>
                    {(projects || []).map((p: any) => (
                        <option key={p.id} value={p.id}>
                            {p.name}
                        </option>
                    ))}
                </select>

                <select
                    value={duration}
                    onChange={(e) => {
                        setPage(0);
                        setDuration(e.target.value);
                    }}
                    className={selectClass}
                >
                    <option value="">All Time</option>
                    <option value="30">Last 30 days</option>
                    <option value="90">Last 90 days</option>
                    <option value="year">This year</option>
                </select>
            </div>

            {/* Table */}
            <div className="bg-white rounded-lg shadow">
                <div className="p-6">
                    {isLoading && <p className="text-gray-600">Loading...</p>}
                    {error && <p className="text-red-600">Failed to load invoices.</p>}

                    {!isLoading && !error && (
                        <div className="overflow-auto">
                            <table className="min-w-full text-sm">
                                <thead>
                                <tr className="text-left text-gray-600 border-b border-gray-200">
                                    <th className="py-3.5 pr-4">Invoice #</th>
                                    <th className="py-3.5 pr-4">Date</th>
                                    <th className="py-3.5 pr-4">Client</th>
                                    <th className="py-3.5 pr-4">Project</th>
                                    <th className="py-3.5 pr-4">Amount</th>
                                    <th className="py-3.5 pr-4">Status</th>
                                    <th className="py-3.5 pr-4 text-right">Actions</th>
                                </tr>
                                </thead>
                                <tbody className="divide-y divide-gray-200">
                                {(filtered || []).map((inv: any) => (
                                    <tr key={inv.id}>
                                        <td className="py-3.5 pr-4 font-medium text-gray-900">
                                            {inv.invoice_number}
                                        </td>
                                        <td className="py-3.5 pr-4">
                                            {formatDate(inv.issue_date)}
                                        </td>
                                        <td className="py-3.5 pr-4">
                                            {clientIdToName.get(inv.client_id) ?? inv.client_id}
                                        </td>
                                        <td className="py-3.5 pr-4">
                                            {projectIdToName.get(inv.project_id) ?? inv.project_id}
                                        </td>
                                        <td className="py-3.5 pr-4 font-medium">
                                            {formatCurrency(inv.total)}
                                        </td>
                                        <td className="py-3.5 pr-4">
                        <span
                            className={`px-2 py-1 rounded-full text-xs font-semibold ${
                                inv.status === "paid"
                                    ? "bg-green-100 text-green-800"
                                    : inv.status === "sent"
                                        ? "bg-blue-100 text-blue-800"
                                        : inv.status === "draft"
                                            ? "bg-gray-100 text-gray-800"
                                            : "bg-red-100 text-red-800"
                            }`}
                        >
                          {inv.status[0].toUpperCase() + inv.status.slice(1)}
                        </span>
                                        </td>
                                        <td className="py-3.5 pr-4 text-right">
                                            <div className="inline-flex items-center gap-3">
                                                <button className="text-blue-600 hover:underline">
                                                    View
                                                </button>
                                                <button
                                                    className={`text-red-600 hover:underline ${
                                                        inv.status === "paid" 
                                                            ? "opacity-50 cursor-not-allowed" 
                                                            : ""
                                                    }`}
                                                    disabled={inv.status === "paid"}
                                                    title={inv.status === "paid" ? "Cannot delete paid invoices" : "Delete invoice"}
                                                    onClick={() => {
                                                        if (inv.status === "paid") return;
                                                        setTargetId(inv.id);
                                                        setConfirmOpen(true);
                                                    }}
                                                >
                                                    Delete
                                                </button>
                                            </div>
                                        </td>
                                    </tr>
                                ))}

                                {(items || []).length === 0 && (
                                    <tr>
                                        <td className="py-4 text-gray-600" colSpan={7}>
                                            No invoices found.
                                        </td>
                                    </tr>
                                )}
                                </tbody>
                            </table>
                        </div>
                    )}
                </div>
            </div>

            {/* Pagination — only render if total > 100 */}
            {showPagination && (
                <div className="flex items-center justify-between text-sm text-gray-700">
                    <div>Page {page + 1}</div>
                    <div className="space-x-2">
                        <button
                            className="px-3 py-1 rounded border border-gray-300 bg-white disabled:opacity-50"
                            disabled={page === 0}
                            onClick={() => setPage((p) => Math.max(0, p - 1))}
                        >
                            Previous
                        </button>
                        <button
                            className="px-3 py-1 rounded border border-gray-300 bg-white disabled:opacity-50"
                            // next button stays enabled while you implement total/hasMore logic
                            onClick={() => setPage((p) => p + 1)}
                        >
                            Next
                        </button>
                    </div>
                </div>
            )}

            {/* Confirm Delete Dialog */}
            <ConfirmDialog
                open={confirmOpen}
                title="Delete invoice?"
                message="This action cannot be undone. Are you sure you want to delete this invoice?"
                confirmText="Delete"
                cancelText="Cancel"
                onCancel={() => {
                    setConfirmOpen(false);
                    setTargetId(null);
                }}
                onConfirm={async () => {
                    if (targetId != null) {
                        await removeInvoice(targetId);
                    }
                    setConfirmOpen(false);
                    setTargetId(null);
                }}
            />

            {/* Toast Notifications */}
            <Toast />
        </div>
    );
};

export default InvoicesListPage;
