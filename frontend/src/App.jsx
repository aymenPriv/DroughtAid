import { BrowserRouter, Routes, Route } from "react-router-dom";

import Sidebar from "./components/Sidebar";
import Dashboard from "./pages/Dashboard";
import Regions from "./pages/Regions";
import DroughtReports from "./pages/DroughtReports";
import AidRequests from "./pages/AidRequests";
import Allocations from "./pages/Allocations";

export default function App() {
  return (
    <BrowserRouter>
      <div className="app-shell">
        <Sidebar />

        <main className="main-content">
          <Routes>
            <Route path="/" element={<Dashboard />} />
            <Route path="/regions" element={<Regions />} />
            <Route path="/drought-reports" element={<DroughtReports />} />
            <Route path="/aid-requests" element={<AidRequests />} />
            <Route path="/allocations" element={<Allocations />} />
          </Routes>
        </main>
      </div>
    </BrowserRouter>
  );
}