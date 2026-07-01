import { useEffect, useState } from "react";

import {
  addDroughtReport,
  getDroughtReports,
  getRegions,
} from "../api";
import DataTable from "../components/DataTable";

export default function DroughtReports() {
  const [reports, setReports] = useState([]);
  const [regions, setRegions] = useState([]);
  const [form, setForm] = useState({
    region_id: "",
    rainfall_mm: "",
    water_level_percent: "",
    vegetation_index: "",
  });
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);
  const [message, setMessage] = useState("");
  const [error, setError] = useState("");

  async function loadData() {
    try {
      setLoading(true);
      setError("");

      const [reportsData, regionsData] = await Promise.all([
        getDroughtReports(),
        getRegions(),
      ]);

      setReports(reportsData);
      setRegions(regionsData);
    } catch (err) {
      setError(err.response?.data?.detail || "Failed to load drought reports.");
    } finally {
      setLoading(false);
    }
  }

  function handleChange(event) {
    const { name, value } = event.target;

    setForm((prev) => ({
      ...prev,
      [name]: value,
    }));
  }

  async function handleSubmit(event) {
    event.preventDefault();

    try {
      setSubmitting(true);
      setError("");
      setMessage("");

      const payload = {
        region_id: Number(form.region_id),
        rainfall_mm: Number(form.rainfall_mm),
        water_level_percent: Number(form.water_level_percent),
        vegetation_index: Number(form.vegetation_index),
      };

      const result = await addDroughtReport(payload);

      setMessage(
        `Report added successfully. Trigger assigned severity: ${result.report.severity_level}`
      );

      setForm({
        region_id: "",
        rainfall_mm: "",
        water_level_percent: "",
        vegetation_index: "",
      });

      await loadData();
    } catch (err) {
      setError(err.response?.data?.detail || "Failed to add drought report.");
    } finally {
      setSubmitting(false);
    }
  }

  useEffect(() => {
    loadData();
  }, []);

  const columns = [
    { key: "report_id", label: "ID" },
    { key: "region_name", label: "Region" },
    { key: "rainfall_mm", label: "Rainfall" },
    { key: "water_level_percent", label: "Water Level" },
    { key: "vegetation_index", label: "Vegetation" },
    {
      key: "severity_level",
      label: "Severity",
      render: (row) => (
        <span className={`badge ${String(row.severity_level).toLowerCase()}`}>
          {row.severity_level}
        </span>
      ),
    },
    { key: "report_date", label: "Date" },
  ];

  if (loading) {
    return <div className="page-message">Loading drought reports...</div>;
  }

  return (
    <div className="page">
      <div className="page-header">
        <div>
          <h1>Drought Reports</h1>
          <p>
            Add drought measurements. The Oracle BEFORE trigger automatically
            sets severity.
          </p>
        </div>

        <button onClick={loadData} className="secondary-button">
          Refresh
        </button>
      </div>

      {error && <div className="alert error">{error}</div>}
      {message && <div className="alert success">{message}</div>}

      <div className="form-card">
        <h2>Add Drought Report</h2>

        <form onSubmit={handleSubmit} className="form-grid">
          <label>
            Region
            <select
              name="region_id"
              value={form.region_id}
              onChange={handleChange}
              required
            >
              <option value="">Select region</option>
              {regions.map((region) => (
                <option key={region.region_id} value={region.region_id}>
                  {region.region_name}
                </option>
              ))}
            </select>
          </label>

          <label>
            Rainfall mm
            <input
              type="number"
              step="0.01"
              name="rainfall_mm"
              value={form.rainfall_mm}
              onChange={handleChange}
              min="0"
              required
            />
          </label>

          <label>
            Water Level %
            <input
              type="number"
              step="0.01"
              name="water_level_percent"
              value={form.water_level_percent}
              onChange={handleChange}
              min="0"
              max="100"
              required
            />
          </label>

          <label>
            Vegetation Index
            <input
              type="number"
              step="0.01"
              name="vegetation_index"
              value={form.vegetation_index}
              onChange={handleChange}
              min="0"
              max="1"
              required
            />
          </label>

          <button type="submit" className="primary-button" disabled={submitting}>
            {submitting ? "Saving..." : "Add Report"}
          </button>
        </form>
      </div>

      <div className="section-card">
        <div className="section-header">
          <h2>Recent Drought Reports</h2>
          <p>Reports are loaded directly from Oracle.</p>
        </div>

        <DataTable columns={columns} data={reports} />
      </div>
    </div>
  );
}