import { useEffect, useState } from "react";
import {
  MapPinned,
  AlertTriangle,
  ClipboardList,
  Package,
  Truck,
} from "lucide-react";

import { getDashboard } from "../api";
import StatCard from "../components/StatCard";
import DataTable from "../components/DataTable";

export default function Dashboard() {
  const [summary, setSummary] = useState(null);
  const [regionStatus, setRegionStatus] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  async function loadDashboard() {
    try {
      setLoading(true);
      setError("");

      const data = await getDashboard();

      setSummary(data.summary);
      setRegionStatus(data.region_status || []);
    } catch (err) {
      setError(err.response?.data?.detail || "Failed to load dashboard data.");
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    loadDashboard();
  }, []);

  const columns = [
    { key: "region_name", label: "Region" },
    { key: "district_name", label: "District" },
    { key: "population", label: "Population" },
    { key: "vulnerability_score", label: "Vulnerability" },
    { key: "rainfall_mm", label: "Rainfall" },
    { key: "water_level_percent", label: "Water Level" },
    {
      key: "severity_level",
      label: "Severity",
      render: (row) => (
        <span className={`badge ${String(row.severity_level).toLowerCase()}`}>
          {row.severity_level || "N/A"}
        </span>
      ),
    },
  ];

  if (loading) {
    return <div className="page-message">Loading dashboard...</div>;
  }

  return (
    <div className="page">
      <div className="page-header">
        <div>
          <h1>Drought Intelligence Dashboard</h1>
          <p>Live overview of drought severity, aid demand, and allocation status.</p>
        </div>

        <button onClick={loadDashboard} className="secondary-button">
          Refresh
        </button>
      </div>

      {error && <div className="alert error">{error}</div>}

      <div className="stats-grid">
        <StatCard
          title="Total Regions"
          value={summary?.total_regions ?? 0}
          subtitle="Monitored areas"
          icon={MapPinned}
        />

        <StatCard
          title="Critical Reports"
          value={summary?.critical_reports ?? 0}
          subtitle="High drought danger"
          icon={AlertTriangle}
        />

        <StatCard
          title="Pending Requests"
          value={summary?.pending_requests ?? 0}
          subtitle="Awaiting allocation"
          icon={ClipboardList}
        />

        <StatCard
          title="Low Stock Items"
          value={summary?.low_stock_items ?? 0}
          subtitle="Need restocking"
          icon={Package}
        />

        <StatCard
          title="Total Aid Allocated"
          value={summary?.total_aid_allocated ?? 0}
          subtitle="All allocated units"
          icon={Truck}
        />
      </div>

      <div className="section-card">
        <div className="section-header">
          <h2>Regional Drought Status</h2>
          <p>Regions are ordered by severity and vulnerability score.</p>
        </div>

        <DataTable columns={columns} data={regionStatus} />
      </div>
    </div>
  );
}