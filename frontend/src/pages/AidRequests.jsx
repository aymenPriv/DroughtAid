import { useEffect, useState } from "react";

import {
  getAidItems,
  getAidRequests,
  getRegions,
  submitAidRequest,
} from "../api";
import DataTable from "../components/DataTable";

export default function AidRequests() {
  const [requests, setRequests] = useState([]);
  const [regions, setRegions] = useState([]);
  const [aidItems, setAidItems] = useState([]);
  const [statusFilter, setStatusFilter] = useState("");
  const [form, setForm] = useState({
    region_id: "",
    aid_item_id: "",
    requested_quantity: "",
    urgency_level: "MEDIUM",
  });

  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);
  const [message, setMessage] = useState("");
  const [error, setError] = useState("");

  async function loadData(selectedStatus = statusFilter) {
    try {
      setLoading(true);
      setError("");

      const [requestsData, regionsData, aidItemsData] = await Promise.all([
        getAidRequests(selectedStatus),
        getRegions(),
        getAidItems(),
      ]);

      setRequests(requestsData);
      setRegions(regionsData);
      setAidItems(aidItemsData);
    } catch (err) {
      setError(err.response?.data?.detail || "Failed to load aid requests.");
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
        aid_item_id: Number(form.aid_item_id),
        requested_quantity: Number(form.requested_quantity),
        urgency_level: form.urgency_level,
      };

      const result = await submitAidRequest(payload);

      setMessage(
        `Aid request submitted successfully. Request ID: ${result.request.request_id}`
      );

      setForm({
        region_id: "",
        aid_item_id: "",
        requested_quantity: "",
        urgency_level: "MEDIUM",
      });

      setStatusFilter("");
      await loadData("");
    } catch (err) {
      setError(err.response?.data?.detail || "Failed to submit aid request.");
    } finally {
      setSubmitting(false);
    }
  }

  async function handleStatusFilter(event) {
    const value = event.target.value;
    setStatusFilter(value);
    await loadData(value);
  }

  useEffect(() => {
    loadData();
  }, []);

  const columns = [
    { key: "request_id", label: "ID" },
    { key: "region_name", label: "Region" },
    { key: "item_name", label: "Aid Item" },
    { key: "requested_quantity", label: "Quantity" },
    {
      key: "urgency_level",
      label: "Urgency",
      render: (row) => (
        <span className={`badge ${String(row.urgency_level).toLowerCase()}`}>
          {row.urgency_level}
        </span>
      ),
    },
    {
      key: "request_status",
      label: "Status",
      render: (row) => (
        <span className={`badge ${String(row.request_status).toLowerCase()}`}>
          {row.request_status}
        </span>
      ),
    },
    { key: "request_date", label: "Date" },
  ];

  if (loading) {
    return <div className="page-message">Loading aid requests...</div>;
  }

  return (
    <div className="page">
      <div className="page-header">
        <div>
          <h1>Aid Requests</h1>
          <p>
            Submit regional aid requests through the PL/SQL procedure.
          </p>
        </div>

        <button onClick={() => loadData()} className="secondary-button">
          Refresh
        </button>
      </div>

      {error && <div className="alert error">{error}</div>}
      {message && <div className="alert success">{message}</div>}

      <div className="form-card">
        <h2>Submit Aid Request</h2>

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
            Aid Item
            <select
              name="aid_item_id"
              value={form.aid_item_id}
              onChange={handleChange}
              required
            >
              <option value="">Select aid item</option>
              {aidItems.map((item) => (
                <option key={item.aid_item_id} value={item.aid_item_id}>
                  {item.item_name} — Stock: {item.quantity_available}
                </option>
              ))}
            </select>
          </label>

          <label>
            Requested Quantity
            <input
              type="number"
              name="requested_quantity"
              value={form.requested_quantity}
              onChange={handleChange}
              min="1"
              required
            />
          </label>

          <label>
            Urgency Level
            <select
              name="urgency_level"
              value={form.urgency_level}
              onChange={handleChange}
              required
            >
              <option value="LOW">LOW</option>
              <option value="MEDIUM">MEDIUM</option>
              <option value="HIGH">HIGH</option>
              <option value="EMERGENCY">EMERGENCY</option>
            </select>
          </label>

          <button type="submit" className="primary-button" disabled={submitting}>
            {submitting ? "Submitting..." : "Submit Request"}
          </button>
        </form>
      </div>

      <div className="section-card">
        <div className="section-header">
          <div>
            <h2>Aid Requests</h2>
            <p>Requests are loaded from Oracle and can be filtered by status.</p>
          </div>

          <select
            className="filter-select"
            value={statusFilter}
            onChange={handleStatusFilter}
          >
            <option value="">All statuses</option>
            <option value="PENDING">PENDING</option>
            <option value="APPROVED">APPROVED</option>
            <option value="PARTIAL">PARTIAL</option>
            <option value="REJECTED">REJECTED</option>
          </select>
        </div>

        <DataTable columns={columns} data={requests} />
      </div>
    </div>
  );
}