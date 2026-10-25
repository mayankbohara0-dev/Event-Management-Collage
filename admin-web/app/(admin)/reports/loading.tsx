export default function ReportsLoading() {
  return (
    <div className="p-6 lg:p-8 space-y-6 animate-pulse">
      <div className="space-y-2">
        <div className="h-7 w-40 rounded-lg bg-fill" />
        <div className="h-4 w-56 rounded-lg bg-fill" />
      </div>
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {Array.from({ length: 4 }).map((_, i) => (
          <div key={i} className="h-64 rounded-card bg-fill border border-line" />
        ))}
      </div>
    </div>
  );
}
