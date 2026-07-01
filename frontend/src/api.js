import axios from "axios";

const API_BASE_URL = "http://127.0.0.1:8000";

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    "Content-Type": "application/json",
  },
});

export async function getDashboard() {
  const response = await api.get("/api/dashboard");
  return response.data;
}

export async function getRegions() {
  const response = await api.get("/api/regions");
  return response.data;
}

export async function getRegionScore(regionId) {
  const response = await api.get(`/api/regions/${regionId}/score`);
  return response.data;
}

export async function getAidItems() {
  const response = await api.get("/api/aid-items");
  return response.data;
}

export async function getDroughtReports() {
  const response = await api.get("/api/drought-reports");
  return response.data;
}

export async function addDroughtReport(data) {
  const response = await api.post("/api/drought-reports", data);
  return response.data;
}

export async function getAidRequests(status = "") {
  const url = status ? `/api/aid-requests?status=${status}` : "/api/aid-requests";
  const response = await api.get(url);
  return response.data;
}

export async function submitAidRequest(data) {
  const response = await api.post("/api/aid-requests", data);
  return response.data;
}

export async function getAllocations() {
  const response = await api.get("/api/allocations");
  return response.data;
}

export async function allocateAid(data) {
  const response = await api.post("/api/allocations", data);
  return response.data;
}

export async function getAllocationAudit() {
  const response = await api.get("/api/allocations/audit");
  return response.data;
}

export default api;