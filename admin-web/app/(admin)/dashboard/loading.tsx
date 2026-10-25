export default function DashboardLoading() {
  return (
    <div className="p-6 lg:p-8 space-y-8 animate-pulse">
      {/* Header */}
      <div className="space-y-2">
        <div className="h-7 w-52 rounded-lg bg-fill" />
        <div className="h-4 w-72 rounded-lg bg-fill" />
      </div>
      {/* Stat cards */}
      <div className="grid grid-cols-2 md:grid-cols-3 xl:grid-cols-6 gap-4">
        {Array.from({ length: 6 }).map((_, i) => (
          <div key={i} className="h-28 rounded-card bg-fill border border-line" />
        ))}
      </div>
      {/* Content rows */}
      <div className="grid grid-cols-1 lg:grid-cols-5 gap-6">
        <div className="lg:col-span-3 h-80 rounded-card bg-fill border border-line" />
        <div className="lg:col-span-2 h-80 rounded-card bg-fill border border-line" />
      </div>
    </div>
  );
}
