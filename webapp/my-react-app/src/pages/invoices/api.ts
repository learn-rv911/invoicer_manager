// src/features/invoices/api.ts

import {CreateInvoiceInput} from "./schema";
import {http} from "../../api/http";

// Dropdown data
export type Company = { id: number; name: string; gst_percent?: number };
export type Client = { id: number; name: string; company_id: number };
export type Project = { id: number; name: string; company_id: number; client_id: number };

export async function listCompanies(): Promise<Company[]> {
    const {data} = await http.get("/companies?limit=1000&offset=0");
    return data ?? [];
}

export async function getCompany(id: number): Promise<Company> {
    const {data} = await http.get(`/companies/${id}`);
    return data;
}

export async function getNextInvoiceNumber(companyId: number, issueDate: string): Promise<{ next_sequence: number; prefix?: string }> {
    const {data} = await http.get("/invoices/next-number", {
        params: { company_id: companyId, issue_date: issueDate }
    });
    return data;
}

export async function listClients(companyId?: number): Promise<Client[]> {
    const params: Record<string, any> = {limit: 1000, offset: 0};
    if (companyId) params.company_id = companyId;
    const {data} = await http.get("/clients", {params});
    return data ?? [];
}

export async function listProjects(companyId?: number, clientId?: number): Promise<Project[]> {
    const params: Record<string, any> = {limit: 1000, offset: 0};
    if (companyId) params.company_id = companyId;
    if (clientId) params.client_id = clientId;
    const {data} = await http.get("/projects", {params});
    return data ?? [];
}

// Submit
export async function createInvoice(input: CreateInvoiceInput): Promise<{ id: number }> {
    // Fetch company details to get GST rate
    const company = await getCompany(input.companyId);
    const gstRateNum = company.gst_percent ?? 0;

    // Calculate subtotal and tax from total amount (tax-inclusive)
    const total = input.totalAmount;
    const subtotal = total / (1 + gstRateNum / 100);
    const tax = total - subtotal;

    // payload aligned to FastAPI InvoiceCreate
    const payload = {
        invoice_number: input.invoiceNumber,
        client_id: input.clientId,
        project_id: input.projectId,
        issue_date: input.issueDate,
        status: "draft",
        currency: "INR",
        gst_rate: gstRateNum,
        subtotal: Number(subtotal.toFixed(2)),
        tax: Number(tax.toFixed(2)),
        total: Number(total.toFixed(2)),
        notes: input.notes ?? "",
        // No line items - empty array
        items: [],
    };

    // DEBUG: log outgoing payload and base URL
    try {
        console.log('[InvoicesAPI] POST /invoices payload:', payload);
        console.log('[InvoicesAPI] baseURL:', (http.defaults.baseURL ?? 'undefined'));
        const {data} = await http.post("/invoices", payload);
        console.log('[InvoicesAPI] response:', data);
        return data;
    } catch (e: any) {
        // DEBUG: log axios error details
        const status = e?.response?.status;
        const respData = e?.response?.data;
        console.error('[InvoicesAPI] error status:', status);
        console.error('[InvoicesAPI] error data:', respData);
        console.error('[InvoicesAPI] error full:', e);
        throw e;
    }
}
