import React from 'react';
import { Navigate, useLocation } from 'react-router-dom';

interface ProtectedRouteProps {
  children: React.ReactNode;
  allowedRoles?: string[];
}

const ProtectedRoute: React.FC<ProtectedRouteProps> = ({ children, allowedRoles }) => {
  const location = useLocation();
  const token = localStorage.getItem('accessToken');
  const userRole = localStorage.getItem('role');

  if (!token) {
    // Redirect to login if not authenticated
    return <Navigate to="/login" state={{ from: location }} replace />;
  }

  if (allowedRoles && userRole && !allowedRoles.includes(userRole)) {
    // Redirect to unauthorized or home if role not allowed
    // For now, redirect to a default safe route
    const DEFAULT_ROUTE_BY_ROLE: Record<string, string> = {
      reviewer: "/reviewer",
      annotator: "/annotator/tasks",
      manager: "/manager/projects",
      admin: "/admin/users",
    };
    return <Navigate to={DEFAULT_ROUTE_BY_ROLE[userRole] || "/login"} replace />;
  }

  return <>{children}</>;
};

export default ProtectedRoute;
