// src/features/invoices/components/LineItemsTable.tsx
import {useMemo} from "react";
import type {LineItemInput} from "../schema";
import {formatCurrency} from "../../../utils/currency";

type Props = {
    items: LineItemInput[];
    onChange: (next: LineItemInput[]) => void;
};

export default function LineItemsTable({items, onChange}: Props) {
    const subtotal = useMemo(
        () => items.reduce((sum, it) => sum + it.quantity * it.unitPrice, 0),
        [items]
    );

    const update = (index: number, patch: Partial<LineItemInput>) => {
        const next = [...items];
        next[index] = {...next[index], ...patch};
        onChange(next);
    };

    const remove = (index: number) => {
        const next = [...items];
        next.splice(index, 1);
        onChange(next);
    };

    const addRow = () => {
        onChange([
            ...items,
            {description: "", quantity: 1, unitPrice: 0},
        ]);
    };

    return (
        <div className="bg-white rounded-xl border border-gray-200">
            <div className="flex items-center justify-between px-4 py-3 border-b">
                <h3 className="font-semibold text-gray-900">Line Items</h3>
                <button
                    type="button"
                    onClick={addRow}
                    className="h-9 rounded-md px-3 bg-blue-600 text-white hover:bg-blue-700"
                >
                    Add Item
                </button>
            </div>

            <div className="overflow-x-auto">
                <table className="min-w-full text-sm">
                    <thead>
                    <tr className="text-left text-gray-500 border-b">
                        <th className="py-3.5 px-4">Description</th>
                        <th className="py-3.5 px-4 w-36">Quantity</th>
                        <th className="py-3.5 px-4 w-44">Unit Price</th>
                        <th className="py-3.5 px-4 w-44">Total</th>
                        <th className="py-3.5 px-4 w-28 text-right">Actions</th>
                    </tr>
                    </thead>
                    <tbody className="divide-y divide-gray-200">
                    {items.map((it, i) => {
                        const rowTotal = it.quantity * it.unitPrice;
                        return (
                            <tr key={i}>
                                <td className="py-3.5 px-4">
                                    <input
                                        value={it.description}
                                        onChange={(e) => update(i, {description: e.target.value})}
                                        placeholder="Description"
                                        className="w-full h-10 rounded-md border border-gray-300 px-3 focus:outline-none focus:ring-2 focus:ring-blue-500"
                                    />
                                </td>
                                <td className="py-3.5 px-4">
                                    <input
                                        type="number"
                                        min={1}
                                        value={Number.isFinite(it.quantity) ? it.quantity : 1}
                                        onChange={(e) => update(i, {quantity: Math.max(1, Number(e.target.value || 1))})}
                                        className="w-full h-10 rounded-md border border-gray-300 px-3 text-right focus:outline-none focus:ring-2 focus:ring-blue-500"
                                    />
                                </td>
                                <td className="py-3.5 px-4">
                                    <input
                                        type="number"
                                        min={0}
                                        step="0.01"
                                        value={Number.isFinite(it.unitPrice) ? it.unitPrice : 0}
                                        onChange={(e) => update(i, {unitPrice: Math.max(0, Number(e.target.value || 0))})}
                                        className="w-full h-10 rounded-md border border-gray-300 px-3 text-right focus:outline-none focus:ring-2 focus:ring-blue-500"
                                    />
                                </td>
                                <td className="py-3.5 px-4 font-medium">{formatCurrency(rowTotal)}</td>
                                <td className="py-3.5 px-4 text-right">
                                    <button
                                        type="button"
                                        onClick={() => remove(i)}
                                        disabled={items.length === 1}
                                        className="h-9 rounded-md px-3 border border-gray-300 bg-white hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
                                    >
                                        Delete
                                    </button>
                                </td>
                            </tr>
                        );
                    })}
                    {items.length === 0 && (
                        <tr>
                            <td className="py-4 px-4 text-gray-500" colSpan={5}>
                                No items yet. Click "Add Item" to start.
                            </td>
                        </tr>
                    )}
                    </tbody>
                    {items.length > 0 && (
                        <tfoot>
                        <tr className="border-t">
                            <td className="py-3.5 px-4 text-right font-medium" colSpan={3}>
                                Subtotal
                            </td>
                            <td className="py-3.5 px-4 font-semibold">{formatCurrency(subtotal)}</td>
                            <td/>
                        </tr>
                        </tfoot>
                    )}
                </table>
            </div>
        </div>
    );
}
