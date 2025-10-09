// src/features/dashboard/api.ts
import { http } from "../../api/http";
import { DashboardSummary } from "../../types/entities";
import { DashboardFilters, DurationKey } from "./types";

// ROOT CAUSE FIX: Added proper filter parameter types and separate API functions
// for invoices/payments instead of relying only on summary endpoint

type DashParams = {
  companyId?: number;
  clientId?: number;
  projectId?: number;
  from?: string;
  to?: string;
};

/**
 * Calculate date range based on duration filter
 */
function computeRange(duration: DurationKey): { from?: string; to?: string } {
  const today = new Date();
  const to = today.toISOString().slice(0, 10);

  if (duration === "30") {
    const d = new Date();
    d.setDate(d.getDate() - 30);
    return { from: d.toISOString().slice(0, 10), to };
  }
  if (duration === "90") {
    const d = new Date();
    d.setDate(d.getDate() - 90);
    return { from: d.toISOString().slice(0, 10), to };
  }
  if (duration === "year") {
    const d = new Date(today.getFullYear(), 0, 1); // Jan 1 of current year
    return { from: d.toISOString().slice(0, 10), to };
  }
  // 'all' or 'custom' returns empty (custom uses explicit from/to from filters)
  return {};
}

/**
 * Convert DashboardFilters to API params
 */
function filtersToParams(filters: DashboardFilters): DashParams {
  const params: DashParams = {};

  if (filters.companyId) params.companyId = filters.companyId;
  if (filters.clientId) params.clientId = filters.clientId;
  if (filters.projectId) params.projectId = filters.projectId;

  // Compute date range
  if (filters.duration === 'custom') {
    // Use explicit custom dates
    if (filters.from) params.from = filters.from;
    if (filters.to) params.to = filters.to;
  } else if (filters.duration !== 'all') {
    // Use computed range for preset durations
    const { from, to } = computeRange(filters.duration);
    if (from) params.from = from;
    if (to) params.to = to;
  }

  return params;
}

/**
 * Get dashboard summary with filters
 */
export async function getDashboardSummary(filters: DashboardFilters): Promise<DashboardSummary> {
  const params = filtersToParams(filters);

  // Convert to snake_case for backend
  const apiParams: Record<string, any> = {};
  if (params.companyId) apiParams.company_id = params.companyId;
  if (params.clientId) apiParams.client_id = params.clientId;
  if (params.projectId) apiParams.project_id = params.projectId;
  if (params.from) apiParams.from_date = params.from;
  if (params.to) apiParams.to_date = params.to;

  console.log("[DashboardAPI] GET /dashboard/summary with params:", apiParams);

  const { data } = await http.get("/dashboard/summary", { params: apiParams });
  return data as DashboardSummary;
}

/**
 * Get recent invoices with filters
 */
export async function getRecentInvoices(filters: DashboardFilters) {
  const params = filtersToParams(filters);

  const apiParams: Record<string, any> = {
    limit: 10,
  };
  if (params.companyId) apiParams.company_id = params.companyId;
  if (params.clientId) apiParams.client_id = params.clientId;
  if (params.projectId) apiParams.project_id = params.projectId;
  if (params.from) apiParams.from_date = params.from;
  if (params.to) apiParams.to_date = params.to;

  console.log("[DashboardAPI] GET /invoices with params:", apiParams);

  const { data } = await http.get("/invoices/", { params: apiParams });
  return data ?? [];
}

/**
 * Get recent payments with filters
 */
export async function getRecentPayments(filters: DashboardFilters) {
  const params = filtersToParams(filters);

  const apiParams: Record<string, any> = {
    limit: 10,
  };
  if (params.companyId) apiParams.company_id = params.companyId;
  if (params.clientId) apiParams.client_id = params.clientId;
  if (params.projectId) apiParams.project_id = params.projectId;
  if (params.from) apiParams.from_date = params.from;
  if (params.to) apiParams.to_date = params.to;

  console.log("[DashboardAPI] GET /payments with params:", apiParams);

  const { data } = await http.get("/payments/", { params: apiParams });
  return data ?? [];
}

// Re-export dropdown APIs from payments page for consistency
export {
  listCompanies,
  listClients,
  listProjects,
  type Company,
  type Client,
  type Project,
} from "../../pages/payments/api";
