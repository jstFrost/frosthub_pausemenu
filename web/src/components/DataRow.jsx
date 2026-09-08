const DataRow = ({ label, value, accent }) => (
  <div className="flex justify-between items-baseline gap-[14px] py-[11px] border-b border-[rgba(255,255,255,0.06)] last:border-0 last:pb-0">
    <span className="fh-meta shrink-0">{label}</span>
    <span
      className="text-[14px] font-medium tracking-[0.5px] truncate"
      style={accent ? { color: 'var(--accent)' } : undefined}
    >
      {value ?? '—'}
    </span>
  </div>
)

export default DataRow
