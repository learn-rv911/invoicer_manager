// src/features/dashboard/components/FiltersBar.tsx
// ROOT CAUSE FIX: Converted from uncontrolled (internal useState) to fully controlled component
// Now receives filters as props and emits changes via onChange callback
import { DashboardFilters, DURATION_OPTIONS, DurationKey } from "../types";

type Company = { id: number; name: string };
type Client = { id: number; name: string };
type Project = { id: number; name: string };

type FiltersBarProps = {
  filters: DashboardFilters;
  onChange: (next: DashboardFilters) => void;
  companies: Company[];
  clients: Client[];
  projects: Project[];
};

export default function FiltersBar({
  filters,
  onChange,
  companies,
  clients,
  projects,
}: FiltersBarProps) {
  // Helper to merge partial updates
  const set = (patch: Partial<DashboardFilters>) =>
    onChange({ ...filters, ...patch });

  return (
    <div className="bg-white border border-gray-200 rounded-xl p-4">
      <div className="flex flex-col gap-3 md:flex-row md:items-center md:gap-4">
        {/* Company Filter */}
        <select
          id="filter-company"
          className="h-10 rounded-md border border-gray-300 px-3 min-w-[180px] text-gray-900 focus:outline-none focus:ring-2 focus:ring-blue-500"
          value={filters.companyId ?? ""}
          onChange={(e) => {
            const id = e.target.value ? Number(e.target.value) : undefined;
            // Reset dependent fields when company changes
            set({ companyId: id, clientId: undefined, projectId: undefined });
          }}
        >
          <option value="">Company: All</option>
          {companies.map((c) => (
            <option key={c.id} value={c.id}>
              {c.name}
            </option>
          ))}
        </select>

        {/* Client Filter */}
        <select
          id="filter-client"
          className="h-10 rounded-md border border-gray-300 px-3 min-w-[180px] text-gray-900 disabled:bg-gray-50 disabled:cursor-not-allowed focus:outline-none focus:ring-2 focus:ring-blue-500"
          value={filters.clientId ?? ""}
          disabled={!filters.companyId}
          onChange={(e) => {
            const id = e.target.value ? Number(e.target.value) : undefined;
            // Reset project when client changes
            set({ clientId: id, projectId: undefined });
          }}
        >
          <option value="">Client: All</option>
          {clients.map((c) => (
            <option key={c.id} value={c.id}>
              {c.name}
            </option>
          ))}
        </select>

        {/* Project Filter */}
        <select
          id="filter-project"
          className="h-10 rounded-md border border-gray-300 px-3 min-w-[180px] text-gray-900 disabled:bg-gray-50 disabled:cursor-not-allowed focus:outline-none focus:ring-2 focus:ring-blue-500"
          value={filters.projectId ?? ""}
          disabled={!filters.companyId || !filters.clientId}
          onChange={(e) => {
            const id = e.target.value ? Number(e.target.value) : undefined;
            set({ projectId: id });
          }}
        >
          <option value="">Project: All</option>
          {projects.map((p) => (
            <option key={p.id} value={p.id}>
              {p.name}
            </option>
          ))}
        </select>

        {/* Duration Filter */}
        <select
          id="filter-duration"
          className="h-10 rounded-md border border-gray-300 px-3 min-w-[180px] text-gray-900 focus:outline-none focus:ring-2 focus:ring-blue-500"
          value={filters.duration}
          onChange={(e) => {
            const d = e.target.value as DurationKey;
            set({
              duration: d,
              // Clear custom dates when switching away from custom
              ...(d !== "custom" ? { from: undefined, to: undefined } : {}),
            });
          }}
        >
          {DURATION_OPTIONS.map((opt) => (
            <option key={opt.value} value={opt.value}>
              {opt.label}
            </option>
          ))}
        </select>

        {/* Custom Date Range Inputs */}
        {filters.duration === "custom" && (
          <div className="flex gap-2">
            <input
              type="date"
              className="h-10 rounded-md border border-gray-300 px-3 text-gray-900 focus:outline-none focus:ring-2 focus:ring-blue-500"
              value={filters.from ?? ""}
              onChange={(e) => set({ from: e.target.value })}
              placeholder="From"
            />
            <input
              type="date"
              className="h-10 rounded-md border border-gray-300 px-3 text-gray-900 focus:outline-none focus:ring-2 focus:ring-blue-500"
              value={filters.to ?? ""}
              onChange={(e) => set({ to: e.target.value })}
              placeholder="To"
            />
          </div>
        )}
      </div>
    </div>
  );
}
