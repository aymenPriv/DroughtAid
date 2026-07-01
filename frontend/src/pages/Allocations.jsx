import { useEffect, useState } from "react";

import {
  allocateAid,
  getAidRequests,
  getAllocationAudit,
  getAllocations,
} from "../api";
import DataTable from "../components/DataTable";

export default function Allocations() {
  const [allocations, setAllocations] = useState([]);
  const [auditLogs, setAuditLogs] = useState([]);
  const [pendingRequests, setPendingRequests] = useState([]);
  const [form, setForm] = useState({
    request_id: "",
    operator_note: "",
  });

  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);
  const [message, setMessage] = useState("");
  const [error, setError] = useState("");

  async function loadData() {
    try {
      setLoading(true);
      setError("");

      const [allocationsData, auditData, pendingData] = await Promise.all([
        getAllocations(),
        getAllocationAudit(),
        getAidRequests("PENDING"),
      ]);

      setAllocations(allocationsData);
      setAuditLogs(auditData);
      setPendingRequests(pendingData);
    } catch (err) {
      setError(err.response?.data?.detail || "Failed to load allocation data.");
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
        request_id: Number(form.request_id),
        operator_note: form.operator_note || "Processed from React frontend",
      };

      const result = await allocateAid(payload);

      setMessage(
        `Allocation completed. Allocated quantity: ${result.allocated_quantity}`
      );

      setForm({
        request_id: "",
        operator_note: "",
      });

      await loadData();
    } catch (err) {
      setError(err.response?.data?.detail || "Failed to allocate aid.");
    } finally {
      setSubmitting(false);
    }
  }

  useEffect(() => {
    loadData();
  }, []);

  const allocationColumns = [
    { key: "allocation_id", label: "ID" },
    { key: "region_name", label: "Region" },
    { key: "item_name", label: "Aid Item" },
    { key: "requested_quantity", label: "Requested" },
    { key: "allocated_quantity", label: "Allocated" },
    { key: "priority_score", label: "Score" },
    {
      key: "allocation_status",
      label: "Status",
      render: (row) => (
        <span className={`badge ${String(row.allocation_status).toLowerCase()}`}>
          {row.allocation_status}
        </span>
      ),
    },
    { key: "allocation_date", label: "Date" },
  ];

  const auditColumns = [
    { key: "audit_id", label: "Audit ID" },
    { key: "allocation_id", label: "Allocation ID" },
    { key: "action_type", label: "Action" },
    { key: "description", label: "Description" },
    { key: "action_date", label: "Date" },
  ];

  if (loading) {
    return <div className="page-message">Loading allocations...</div>;
  }

  return (
    <div className="page">
      <div className="page-header">
        <div>
          <h1>Aid Allocations</h1>
          <p>
            Allocate aid using the PL/SQL procedure. Audit logs are created by
            the Oracle AFTER trigger.
          </p>
        </div>

        <button onClick={loadData} className="secondary-button">
          Refresh
        </button>
      </div>

      {error && <div className="alert error">{error}</div>}
      {message && <div className="alert success">{message}</div>}

      <div className="form-card">
        <h2>Process Aid Allocation</h2>

        <form onSubmit={handleSubmit} className="form-grid">
          <label>
            Pending Request
            <select
              name="request_id"
              value={form.request_id}
              onChange={handleChange}
              required
            >
              <option value="">Select pending request</option>
              {pendingRequests.map((request) => (
                <option key={request.request_id} value={request.request_id}>
                  #{request.request_id} — {request.region_name} —{" "}
                  {request.item_name} — Qty: {request.requested_quantity}
                </option>
              ))}
            </select>
          </label>

          <label>
            Operator Note
            <input
              type="text"
              name="operator_note"
              value={form.operator_note}
              onChange={handleChange}
              placeholder="Optional note"
            />
          </label>

          <button type="submit" className="primary-button" disabled={submitting}>
            {submitting ? "Allocating..." : "Allocate Aid"}
          </button>
        </form>
      </div>

      <div className="section-card">
        <div className="section-header">
          <h2>Allocation Records</h2>
          <p>These records come from the allocation details view.</p>
        </div>

        <DataTable columns={allocationColumns} data={allocations} />
      </div>

      <div className="section-card">
        <div className="section-header">
          <h2>Allocation Audit Log</h2>
          <p>These logs prove the AFTER INSERT trigger is working.</p>
        </div>

        <DataTable columns={auditColumns} data={auditLogs} />
      </div>
    </div>
  );
}