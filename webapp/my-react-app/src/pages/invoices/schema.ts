import {z} from "zod";

/**
 * ✅ Simplified invoice schema - total amount only, GST auto-fetched from company
 * No GST selection field - automatically uses company's GST rate
 */
export const createInvoiceSchema = z.object({
    companyId: z.number().int().gt(0, "Company is required"),
    clientId: z.number().int().gt(0, "Client is required"),
    projectId: z.number().int().gt(0, "Project is required"),
    invoiceNumber: z.string().trim().min(1, "Invoice number is required"),
    issueDate: z.string().regex(/^\d{4}-\d{2}-\d{2}$/, "Use YYYY-MM-DD"),
    notes: z.string().optional(),
    totalAmount: z.number().positive("Total amount must be greater than 0"),
});

export type CreateInvoiceInput = z.infer<typeof createInvoiceSchema>;
