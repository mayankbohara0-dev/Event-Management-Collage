export default function RegistrationsLoading() {
  return (
    <div className="p-6 lg:p-8 space-y-6 animate-pulse">
      <div className="space-y-2">
        <div className="h-7 w-48 rounded-lg bg-fill" />
        <div className="h-4 w-64 rounded-lg bg-fill" />
      </div>
      <div className="h-12 rounded-card bg-fill" />
      <div className="rounded-card border border-line overflow-hidden">
        <div className="h-12 bg-fill border-b border-line" />
        {Array.from({ length: 10 }).map((_, i) => (
          <div key={i} className="h-14 border-b border-line/60 bg-card" />
        ))}
      </div>
    </div>
  );
}
