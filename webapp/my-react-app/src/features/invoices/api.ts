import {http} from "../../api/http";
import type {Invoice} from "../../types/entities";

export const listInvoices = async (
    q?: string,
    status?: string,
    client_id?: number,
    project_id?: number,
    company_id?: number,
    skip = 0,
    limit = 20
): Promise<Invoice[]> => {
    const {data} = await http.get("/invoices/", {params: {q, status, client_id, project_id, company_id, skip, limit}});
    return data as Invoice[];
};

export async function deleteInvoice(id: number): Promise<void> {
    await http.delete(`/invoices/${id}`);
}
