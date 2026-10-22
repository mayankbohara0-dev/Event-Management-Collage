"use client";

import React, { useState } from "react";
import {
  ColumnDef,
  flexRender,
  getCoreRowModel,
  getPaginationRowModel,
  useReactTable,
  RowSelectionState,
  VisibilityState,
} from "@tanstack/react-table";
import {
  ChevronLeft,
  ChevronRight,
  SlidersHorizontal,
  Columns,
  Search,
} from "lucide-react";
import { cn } from "@/lib/utils";
import { Button } from "./Button";
import { Input } from "./Input";
import { Checkbox } from "./Checkbox";

interface DataTableProps<TData, TValue> {
  columns: ColumnDef<TData, TValue>[];
  data: TData[];
  searchPlaceholder?: string;
  onSearchChange?: (value: string) => void;
  bulkActions?: (selectedRows: TData[]) => React.ReactNode;
  onRowClick?: (row: TData) => void;
  isLoading?: boolean;
  emptyState?: React.ReactNode;
}

export function DataTable<TData, TValue>({
  columns,
  data,
  searchPlaceholder = "Search...",
  onSearchChange,
  bulkActions,
  onRowClick,
  isLoading = false,
  emptyState,
}: DataTableProps<TData, TValue>) {
  const [rowSelection, setRowSelection] = useState<RowSelectionState>({});
  const [columnVisibility, setColumnVisibility] = useState<VisibilityState>({});
  const [density, setDensity] = useState<"comfortable" | "compact">("comfortable");
  const [searchValue, setSearchValue] = useState("");
  const [showColumnChooser, setShowColumnChooser] = useState(false);

  const table = useReactTable({
    data,
    columns,
    state: {
      rowSelection,
      columnVisibility,
    },
    enableRowSelection: true,
    onRowSelectionChange: setRowSelection,
    onColumnVisibilityChange: setColumnVisibility,
    getCoreRowModel: getCoreRowModel(),
    getPaginationRowModel: getPaginationRowModel(),
  });

  const selectedRows = table
    .getSelectedRowModel()
    .rows.map((r) => r.original);

  const selectedCount = Object.keys(rowSelection).length;

  return (
    <div className="w-full space-y-3">
      {/* Table Toolbar */}
      <div className="flex flex-col sm:flex-row items-stretch sm:items-center justify-between gap-3">
        <div className="flex items-center gap-2 flex-1 max-w-sm">
          <Input
            placeholder={searchPlaceholder}
            value={searchValue}
            leftIcon={<Search size={16} />}
            onChange={(e) => {
              setSearchValue(e.target.value);
              onSearchChange?.(e.target.value);
            }}
            className="h-9 text-xs"
          />
        </div>

        <div className="flex items-center gap-2 shrink-0">
          {/* Density Toggle */}
          <Button
            variant="outline"
            size="sm"
            onClick={() =>
              setDensity(density === "comfortable" ? "compact" : "comfortable")
            }
            title="Toggle table density"
            className="h-9 px-3 text-xs"
          >
            <SlidersHorizontal size={14} className="mr-1.5" />
            {density === "comfortable" ? "Compact" : "Comfortable"}
          </Button>

          {/* Column Chooser Popover */}
          <div className="relative">
            <Button
              variant="outline"
              size="sm"
              onClick={() => setShowColumnChooser(!showColumnChooser)}
              className="h-9 px-3 text-xs"
            >
              <Columns size={14} className="mr-1.5" />
              Columns
            </Button>

            {showColumnChooser && (
              <div className="absolute right-0 top-full mt-2 w-48 bg-card rounded-card border border-line shadow-floating p-2 z-30">
                <p className="text-xs font-semibold text-ink px-2 py-1 mb-1 border-b border-line">
                  Toggle Columns
                </p>
                <div className="max-h-48 overflow-y-auto space-y-1 p-1">
                  {table
                    .getAllLeafColumns()
                    .filter((col) => col.id !== "select")
                    .map((col) => (
                      <label
                        key={col.id}
                        className="flex items-center gap-2 px-2 py-1 text-xs text-ink-2 hover:bg-fill rounded cursor-pointer capitalize"
                      >
                        <Checkbox
                          checked={col.getIsVisible()}
                          onCheckedChange={(val) => col.toggleVisibility(val)}
                        />
                        {col.id}
                      </label>
                    ))}
                </div>
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Floating Bulk Action Bar */}
      {selectedCount > 0 && bulkActions && (
        <div className="bg-ink text-white px-4 py-2.5 rounded-pill flex items-center justify-between shadow-floating animate-in fade-in slide-in-from-bottom-2 duration-180">
          <span className="text-xs font-semibold px-2">
            {selectedCount} item{selectedCount > 1 ? "s" : ""} selected
          </span>
          <div className="flex items-center gap-2">
            {bulkActions(selectedRows)}
            <Button
              variant="ghost"
              size="sm"
              onClick={() => table.resetRowSelection()}
              className="text-white/80 hover:text-white hover:bg-white/10 text-xs h-7 px-2.5"
            >
              Deselect All
            </Button>
          </div>
        </div>
      )}

      {/* Table Container */}
      <div className="bg-card rounded-card border border-line shadow-sm overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-sm text-ink">
            {/* Sticky Header */}
            <thead className="bg-page/70 border-b border-line text-xs uppercase tracking-wider text-ink-2 font-semibold select-none sticky top-0 z-10 backdrop-blur-sm">
              {table.getHeaderGroups().map((headerGroup) => (
                <tr key={headerGroup.id}>
                  {headerGroup.headers.map((header) => (
                    <th
                      key={header.id}
                      className={cn(
                        "px-4 font-medium",
                        density === "compact" ? "py-2.5" : "py-3.5"
                      )}
                    >
                      {header.isPlaceholder
                        ? null
                        : flexRender(
                            header.column.columnDef.header,
                            header.getContext()
                          )}
                    </th>
                  ))}
                </tr>
              ))}
            </thead>

            {/* Table Body */}
            <tbody className="divide-y divide-line/60">
              {isLoading ? (
                Array.from({ length: 5 }).map((_, i) => (
                  <tr key={i} className="animate-pulse">
                    {columns.map((_, colIndex) => (
                      <td
                        key={colIndex}
                        className={cn(
                          "px-4",
                          density === "compact" ? "py-2.5" : "py-4"
                        )}
                      >
                        <div className="h-4 bg-fill rounded w-3/4" />
                      </td>
                    ))}
                  </tr>
                ))
              ) : table.getRowModel().rows?.length ? (
                table.getRowModel().rows.map((row) => (
                  <tr
                    key={row.id}
                    onClick={() => onRowClick?.(row.original)}
                    className={cn(
                      "hover:bg-fill/40 transition-colors",
                      row.getIsSelected() && "bg-brand-tint/30",
                      onRowClick && "cursor-pointer"
                    )}
                  >
                    {row.getVisibleCells().map((cell) => (
                      <td
                        key={cell.id}
                        className={cn(
                          "px-4 text-xs font-normal",
                          density === "compact" ? "py-2.5" : "py-3.5"
                        )}
                      >
                        {flexRender(
                          cell.column.columnDef.cell,
                          cell.getContext()
                        )}
                      </td>
                    ))}
                  </tr>
                ))
              ) : (
                <tr>
                  <td colSpan={columns.length} className="p-8 text-center">
                    {emptyState || (
                      <p className="text-sm text-ink-3">No records found</p>
                    )}
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>

        {/* Pagination Bar */}
        <div className="flex items-center justify-between px-4 py-3 border-t border-line/60 bg-page/30 text-xs text-ink-2">
          <div className="flex items-center gap-2">
            <span>
              Page {table.getState().pagination.pageIndex + 1} of{" "}
              {Math.max(1, table.getPageCount())}
            </span>
            <span className="text-ink-3">
              ({data.length} total item{data.length !== 1 ? "s" : ""})
            </span>
          </div>

          <div className="flex items-center gap-1.5">
            <Button
              variant="outline"
              size="sm"
              onClick={() => table.previousPage()}
              disabled={!table.getCanPreviousPage()}
              className="h-8 px-2.5"
            >
              <ChevronLeft size={14} />
            </Button>
            <Button
              variant="outline"
              size="sm"
              onClick={() => table.nextPage()}
              disabled={!table.getCanNextPage()}
              className="h-8 px-2.5"
            >
              <ChevronRight size={14} />
            </Button>
          </div>
        </div>
      </div>
    </div>
  );
}
