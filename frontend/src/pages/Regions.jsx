import { useEffect, useState } from "react";

import { getRegions, getRegionScore } from "../api";
import DataTable from "../components/DataTable";

export default function Regions() {
  const [regions, setRegions] = useState([]);
  const [selectedScore, setSelectedScore] = useState(null);
  const [loading, setLoading] = useState(true);
  const [scoreLoading, setScoreLoading] = useState(false);
  const [error, setError] = useState("");

  async function loadRegions() {
    try {
      setLoading(true);
      setError("");

      const data = await getRegions();
      setRegions(data);
    } catch (err) {
      setError(err.response?.data?.detail || "Failed to load regions.");
    } finally {
      setLoading(false);
    }
  }

  async function handleScore(regionId) {
    try {
      setScoreLoading(true);
      setError("");

      const data = await getRegionScore(regionId);
      setSelectedScore(data);
    } catch (err) {
      setError(err.response?.data?.detail || "Failed to calculate drought score.");
    } finally {
      setScoreLoading(false);
    }
  }

  useEffect(() => {
    loadRegions();
  }, []);

  const columns = [
    { key: "region_id", label: "ID" },
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
    {
      key: "actions",
      label: "Action",
      render: (row) => (
        <button
          className="small-button"
          onClick={() => handleScore(row.region_id)}
        >
          Calculate Score
        </button>
      ),
    },
  ];

  if (loading) {
    return <div className="page-message">Loading regions...</div>;
  }

  return (
    <div className="page">
      <div className="page-header">
        <div>
          <h1>Regions</h1>
          <p>View monitored regions and calculate drought priority scores.</p>
        </div>

        <button onClick={loadRegions} className="secondary-button">
          Refresh
        </button>
      </div>

      {error && <div className="alert error">{error}</div>}

      {selectedScore && (
        <div className="alert success">
          Region #{selectedScore.region_id} score:{" "}
          <strong>{selectedScore.drought_score}</strong> — Priority:{" "}
          <strong>{selectedScore.priority_level}</strong>
        </div>
      )}

      {scoreLoading && <div className="alert info">Calculating score...</div>}

      <div className="section-card">
        <div className="section-header">
          <h2>Region Drought Status</h2>
          <p>Data comes from the Oracle view and PL/SQL scoring function.</p>
        </div>

        <DataTable columns={columns} data={regions} />
      </div>
    </div>
  );
}