export default function EventsLoading() {
  return (
    <div className="p-6 lg:p-8 space-y-6 animate-pulse">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div className="space-y-2">
          <div className="h-7 w-40 rounded-lg bg-fill" />
          <div className="h-4 w-56 rounded-lg bg-fill" />
        </div>
        <div className="h-9 w-32 rounded-pill bg-fill" />
      </div>
      {/* Filters bar */}
      <div className="flex gap-3 flex-wrap">
        <div className="h-9 w-56 rounded-card bg-fill" />
        <div className="h-9 w-36 rounded-card bg-fill" />
        <div className="h-9 w-36 rounded-card bg-fill" />
        <div className="h-9 w-36 rounded-card bg-fill" />
        <div className="h-9 w-20 rounded-card bg-fill ml-auto" />
      </div>
      {/* Event grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
        {Array.from({ length: 8 }).map((_, i) => (
          <div key={i} className="h-56 rounded-card bg-fill border border-line" />
        ))}
      </div>
    </div>
  );
}
