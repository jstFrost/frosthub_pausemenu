const Panel = ({ title, delay = '', className = '', children }) => (
  <section className={`fh-panel fh-in ${delay} p-[20px] flex flex-col ${className}`}>
    {title && <h3 className="fh-eyebrow mb-[10px]">{title}</h3>}
    {children}
  </section>
)

export default Panel
