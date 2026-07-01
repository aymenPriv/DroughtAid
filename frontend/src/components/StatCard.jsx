export default function StatCard({ title, value, subtitle, icon: Icon }) {
  return (
    <div className="stat-card">
      <div className="stat-card-content">
        <p>{title}</p>
        <h3>{value}</h3>
        {subtitle && <span>{subtitle}</span>}
      </div>

      {Icon && (
        <div className="stat-card-icon">
          <Icon size={24} />
        </div>
      )}
    </div>
  );
}