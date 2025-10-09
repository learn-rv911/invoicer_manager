// src/features/dashboard/types.ts

export type DurationKey = 'all' | '30' | '90' | 'year' | 'custom';

export interface DashboardFilters {
  companyId?: number;
  clientId?: number;
  projectId?: number;
  duration: DurationKey; // default 'all'
  // optional for 'custom'
  from?: string; // YYYY-MM-DD
  to?: string;   // YYYY-MM-DD
}

export type DurationOption = {
  value: DurationKey;
  label: string;
};

export const DURATION_OPTIONS: DurationOption[] = [
  { value: 'all', label: "All Time" },
  { value: '30', label: "Last 30 Days" },
  { value: '90', label: "Last 90 Days" },
  { value: 'year', label: "This Year" },
  { value: 'custom', label: "Custom Range" },
];

