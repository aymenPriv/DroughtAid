import { NavLink } from "react-router-dom";
import {
  LayoutDashboard,
  MapPinned,
  CloudSun,
  HandHeart,
  PackageCheck,
} from "lucide-react";

const menuItems = [
  {
    label: "Dashboard",
    path: "/",
    icon: LayoutDashboard,
  },
  {
    label: "Regions",
    path: "/regions",
    icon: MapPinned,
  },
  {
    label: "Drought Reports",
    path: "/drought-reports",
    icon: CloudSun,
  },
  {
    label: "Aid Requests",
    path: "/aid-requests",
    icon: HandHeart,
  },
  {
    label: "Allocations",
    path: "/allocations",
    icon: PackageCheck,
  },
];

export default function Sidebar() {
  return (
    <aside className="sidebar">
      <div className="sidebar-header">
        <div className="logo-box">DA</div>
        <div>
          <h2>DroughtAid</h2>
          <p>PL/SQL Intelligence</p>
        </div>
      </div>

      <nav className="sidebar-nav">
        {menuItems.map((item) => {
          const Icon = item.icon;

          return (
            <NavLink
              key={item.path}
              to={item.path}
              className={({ isActive }) =>
                isActive ? "nav-link active" : "nav-link"
              }
            >
              <Icon size={20} />
              <span>{item.label}</span>
            </NavLink>
          );
        })}
      </nav>

      <div className="sidebar-footer">
        <p>AI-Assisted Aid Allocation</p>
        <span>Oracle PL/SQL Project</span>
      </div>
    </aside>
  );
}