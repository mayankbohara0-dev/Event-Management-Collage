export default function FeedbackLoading() {
  return (
    <div className="p-6 lg:p-8 space-y-6 animate-pulse">
      <div className="space-y-2">
        <div className="h-7 w-40 rounded-lg bg-fill" />
        <div className="h-4 w-56 rounded-lg bg-fill" />
      </div>
      <div className="rounded-card border border-line overflow-hidden">
        <div className="h-12 bg-fill border-b border-line" />
        {Array.from({ length: 8 }).map((_, i) => (
          <div key={i} className="h-16 border-b border-line/60 bg-card" />
        ))}
      </div>
    </div>
  );
}
