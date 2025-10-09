// src/features/invoices/CreateInvoicePage.tsx
import {useEffect, useMemo, useState} from "react";
import {useMutation, useQuery, useQueryClient} from "@tanstack/react-query";
import {zodResolver} from "@hookform/resolvers/zod";
import {useForm, Controller} from "react-hook-form";

import {
    createInvoiceSchema,
    type CreateInvoiceInput,
} from "./schema";
import {
    listCompanies,
    listClients,
    listProjects,
    createInvoice,
    getCompany,
    getNextInvoiceNumber,
} from "./api";
import {formatCurrency} from "../../utils/currency";
import {useNavigate} from "react-router-dom";

// GST options removed - now auto-fetched from company

export default function CreateInvoicePage() {
    const navigate = useNavigate();
    const qc = useQueryClient();

    // Form
    const {
        control,
        handleSubmit,
        watch,
        setValue,
        formState: {errors, isSubmitting},
    } = useForm<CreateInvoiceInput>({
        resolver: zodResolver(createInvoiceSchema),
        defaultValues: {
            companyId: 0,
            clientId: 0,
            projectId: 0,
            invoiceNumber: "",
            issueDate: new Date().toISOString().slice(0, 10),
            notes: "",
            totalAmount: undefined,
        },
    });

    const companyId = watch("companyId");
    const clientId = watch("clientId");
    const issueDate = watch("issueDate");
    const totalAmount = watch("totalAmount");

    // Dropdown queries
    const {data: companies = []} = useQuery({
        queryKey: ["companies:select"],
        queryFn: listCompanies,
    });

    const {data: clients = []} = useQuery({
        queryKey: ["clients:select", companyId],
        queryFn: () => listClients(companyId),
        enabled: !!companyId && companyId > 0,
    });

    const {data: projects = []} = useQuery({
        queryKey: ["projects:select", companyId, clientId],
        queryFn: () => listProjects(companyId, clientId),
        enabled: !!companyId && companyId > 0 && !!clientId && clientId > 0,
    });

    // Fetch selected company's GST rate
    const {data: selectedCompany, isLoading: companyLoading, error: companyError} = useQuery({
        queryKey: ["company:gst", companyId],
        queryFn: () => getCompany(companyId),
        enabled: !!companyId && companyId > 0,
    });

    // Auto-generate invoice number
    useEffect(() => {
        if (!companyId || companyId === 0 || !issueDate) {
            return;
        }

        getNextInvoiceNumber(companyId, issueDate)
            .then((response) => {
                const {next_sequence, prefix} = response;
                const year = new Date(issueDate).getFullYear() % 100;
                const seq = String(next_sequence).padStart(3, "0");
                const invoiceNum = `${prefix || "INV"}${year}#${seq}`;

                setValue("invoiceNumber", invoiceNum, {
                    shouldDirty: true,
                    shouldValidate: true
                });
                console.log(`[Invoice Number] Generated: ${invoiceNum}`);
            })
            .catch((err) => {
                console.error('[Invoice Number] Failed to generate:', err);
            });
    }, [companyId, issueDate, setValue]);

    // Totals calculation
    const {subtotal, tax, grand, gstRate} = useMemo(() => {
        const total = totalAmount ?? 0;
        const gst = selectedCompany?.gst_percent ?? 0;
        const sub = total / (1 + gst / 100);
        const t = total - sub;
        return {subtotal: sub, tax: t, grand: total, gstRate: gst};
    }, [totalAmount, selectedCompany]);

    // Submit
    const {mutateAsync} = useMutation({
        mutationFn: createInvoice,
        onError: (err) => {
            console.error('[CreateInvoice] mutate onError:', err);
            alert('Failed to create invoice. See console for details.');
        },
        onSuccess: async (resp) => {
            console.log('[CreateInvoice] mutate onSuccess response:', resp);
            await qc.invalidateQueries({queryKey: ["invoices"]});
        },
    });

    const onSubmit = async (values: CreateInvoiceInput) => {
        console.log('[CreateInvoice] submitting values:', values);
        try {
            await mutateAsync(values);
            console.log('[CreateInvoice] navigate after success');
            navigate("/invoices");
        } catch (e) {
            console.error('[CreateInvoice] mutate error (caught in onSubmit):', e);
            return;
        }
    };

    return (
        <form onSubmit={handleSubmit(onSubmit)} className="space-y-6">
            {/* Header */}
            <div>
                <h1 className="text-2xl font-bold text-gray-900">Create Invoice</h1>
                <p className="text-gray-600">Fill in the details below to create a new invoice.</p>
            </div>

            {/* Invoice details card */}
            <div className="bg-white rounded-xl border border-gray-200">
                <div className="p-6 grid grid-cols-1 md:grid-cols-2 gap-4">
                    {/* Company */}
                    <div>
                        <label className="block text-sm text-gray-600 mb-1">Select Company <span
                            className="text-red-600">*</span></label>
                        <Controller
                            control={control}
                            name="companyId"
                            render={({field}) => (
                                <select
                                    value={field.value || ""}
                                    className="h-10 w-full rounded-md border border-gray-300 px-3"
                                    onChange={(e) => {
                                        const val = e.target.value;
                                        const id = val ? Number(val) : 0;
                                        field.onChange(id);
                                        // reset dependent fields
                                        setValue("clientId", 0);
                                        setValue("projectId", 0);
                                    }}
                                >
                                    <option value="">Select Company</option>
                                    {companies.map((c) => (
                                        <option key={c.id} value={c.id}>
                                            {c.name}
                                        </option>
                                    ))}
                                </select>
                            )}
                        />
                        {errors.companyId && (
                            <p className="text-red-600 text-sm mt-1">{errors.companyId.message}</p>
                        )}
                    </div>

                    {/* Client */}
                    <div>
                        <label className="block text-sm text-gray-600 mb-1">Select Client <span
                            className="text-red-600">*</span></label>
                        <Controller
                            control={control}
                            name="clientId"
                            render={({field}) => (
                                <select
                                    value={field.value || ""}
                                    disabled={!companyId || companyId === 0}
                                    className="h-10 w-full rounded-md border border-gray-300 px-3 disabled:bg-gray-50"
                                    onChange={(e) => {
                                        const val = e.target.value;
                                        const id = val ? Number(val) : 0;
                                        field.onChange(id);
                                        setValue("projectId", 0);
                                    }}
                                >
                                    <option value="">Select Client</option>
                                    {clients.map((c) => (
                                        <option key={c.id} value={c.id}>
                                            {c.name}
                                        </option>
                                    ))}
                                </select>
                            )}
                        />
                        {errors.clientId && (
                            <p className="text-red-600 text-sm mt-1">{errors.clientId.message}</p>
                        )}
                    </div>

                    {/* Project (Required) */}
                    <div>
                        <label className="block text-sm text-gray-600 mb-1">Select Project <span
                            className="text-red-600">*</span></label>
                        <Controller
                            control={control}
                            name="projectId"
                            render={({field}) => (
                                <select
                                    value={field.value || ""}
                                    disabled={!companyId || companyId === 0 || !clientId || clientId === 0}
                                    className="h-10 w-full rounded-md border border-gray-300 px-3 disabled:bg-gray-50"
                                    onChange={(e) => {
                                        const val = e.target.value;
                                        const id = val ? Number(val) : 0;
                                        field.onChange(id);
                                    }}
                                >
                                    <option value="">Select Project</option>
                                    {projects.map((p) => (
                                        <option key={p.id} value={p.id}>
                                            {p.name}
                                        </option>
                                    ))}
                                </select>
                            )}
                        />
                        {errors.projectId && (
                            <p className="text-red-600 text-sm mt-1">{errors.projectId.message}</p>
                        )}
                    </div>

                    {/* Invoice number */}
                    <div>
                        <label className="block text-sm text-gray-600 mb-1">Invoice Number <span
                            className="text-red-600">*</span></label>
                        <Controller
                            control={control}
                            name="invoiceNumber"
                            render={({field}) => (
                                <input
                                    {...field}
                                    placeholder="e.g., INV25#001"
                                    className="h-10 w-full rounded-md border border-gray-300 px-3"
                                />
                            )}
                        />
                        {errors.invoiceNumber && (
                            <p className="text-red-600 text-sm mt-1">{errors.invoiceNumber.message}</p>
                        )}
                    </div>

                    {/* Date */}
                    <div>
                        <label className="block text-sm text-gray-600 mb-1">Invoice Date <span
                            className="text-red-600">*</span></label>
                        <Controller
                            control={control}
                            name="issueDate"
                            render={({field}) => (
                                <input
                                    type="date"
                                    {...field}
                                    className="h-10 w-full rounded-md border border-gray-300 px-3"
                                />
                            )}
                        />
                        {errors.issueDate && (
                            <p className="text-red-600 text-sm mt-1">{errors.issueDate.message}</p>
                        )}
                    </div>

                    {/* GST Rate Display (Auto from Company) */}
                    <div>
                        <label className="block text-sm text-gray-600 mb-1">GST Rate</label>
                        <div className="h-10 w-full rounded-md border border-gray-300 px-3 flex items-center bg-gray-50">
                            <span className="text-gray-700">
                                {companyLoading ? (
                                    'Loading...'
                                ) : companyError ? (
                                    'Error loading GST'
                                ) : selectedCompany ? (
                                    `${selectedCompany.gst_percent ?? 0}%`
                                ) : (
                                    'Select company first'
                                )}
                            </span>
                        </div>
                        <p className="text-xs text-gray-500 mt-1">
                            Automatically set from selected company
                        </p>
                    </div>
                </div>
            </div>

            {/* Total Amount Input */}
            <div className="bg-white rounded-xl border border-gray-200 p-6">
                <label className="block text-sm text-gray-600 mb-1">
                    Total Amount (tax-inclusive) <span className="text-red-600">*</span>
                </label>
                <Controller
                    control={control}
                    name="totalAmount"
                    render={({field}) => (
                        <input
                            type="number"
                            step="0.01"
                            min="0"
                            value={field.value ?? ""}
                            onChange={(e) => {
                                const v = e.target.value;
                                field.onChange(v === "" ? undefined : Number(v));
                            }}
                            placeholder="Enter total amount including tax"
                            className="h-10 w-full rounded-md border border-gray-300 px-3"
                        />
                    )}
                />
                {errors.totalAmount && (
                    <p className="text-red-600 text-sm mt-1">{errors.totalAmount.message}</p>
                )}
                <p className="text-xs text-gray-500 mt-1">
                    Enter the final total. Subtotal and tax will be calculated automatically.
                </p>
            </div>

            {/* Total card */}
            <div className="bg-white rounded-xl border border-gray-200 p-6 grid grid-cols-1 md:grid-cols-2 gap-6">
                <div className="space-y-3">
                    <div className="flex items-center justify-between">
                        <span className="text-gray-600">Subtotal</span>
                        <span className="font-medium">{formatCurrency(subtotal)}</span>
                    </div>
                    <div className="flex items-center justify-between">
                        <span className="text-gray-600">Tax ({gstRate}%)</span>
                        <span className="font-medium">{formatCurrency(tax)}</span>
                    </div>
                    <div className="flex items-center justify-between border-t pt-3">
                        <span className="text-gray-900 font-semibold">Grand Total</span>
                        <span className="text-gray-900 font-semibold">{formatCurrency(grand)}</span>
                    </div>
                </div>

                <div>
                    <label className="block text-sm text-gray-600 mb-1">Notes (Optional)</label>
                    <Controller
                        control={control}
                        name="notes"
                        render={({field}) => (
                            <textarea
                                {...field}
                                rows={5}
                                placeholder="Add any additional notes here..."
                                className="w-full rounded-md border border-gray-300 px-3 py-2"
                            />
                        )}
                    />
                </div>
            </div>

            {/* Actions */}
            <div className="flex justify-end gap-3">
                <button
                    type="button"
                    onClick={() => navigate("/invoices")}
                    className="h-10 rounded-md px-4 border border-gray-300 bg-white hover:bg-gray-50"
                >
                    Cancel
                </button>
                <button
                    type="submit"
                    disabled={isSubmitting}
                    className="h-10 rounded-md px-4 bg-blue-600 text-white hover:bg-blue-700 disabled:opacity-50"
                >
                    {isSubmitting ? "Creating..." : "Create Invoice"}
                </button>
            </div>
        </form>
    );
}
