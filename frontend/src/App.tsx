import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import ProtectedRoute from './components/auth/ProtectedRoute';

// Auth Pages
import LoginPage from './pages/auth/LoginPage';
import RegisterPage from './pages/auth/RegisterPage';
import ForgotPasswordPage from './pages/auth/ForgotPasswordPage';
import ResetPasswordPage from './pages/auth/ResetPasswordPage';
import ChangePasswordPage from './pages/auth/ChangePasswordPage';

// Manager Pages
import ManagerCreateProjectPage from './pages/manager/projects/ManagerCreateProjectPage';
import ManagerProjectListPage from './pages/manager/projects/ManagerProjectListPage';
import ManagerProjectDetailPage from './pages/manager/projects/ManagerProjectDetailPage';
import ManagerUploadDatasetPage from './pages/manager/datasets/ManagerUploadDatasetPage';
import ManagerDatasetListPage from './pages/manager/datasets/ManagerDatasetListPage';
import ManagerDatasetDetailPage from './pages/manager/datasets/ManagerDatasetDetailPage';
import ManagerCreateTaskPage from './pages/manager/tasks/ManagerCreateTaskPage';

// Reviewer Pages
import ReviewerRoutes from "./pages/reviewer";

// Annotator Pages
import AnnotatorRoutes from "./pages/annotator";

// Admin Pages
import AdminUserManagement from './pages/admin/AdminUserManagement';
import AdminSystemConfigPage from "./pages/admin/AdminSystemConfigPage";
import AdminSystemHealthPage from "./pages/admin/AdminSystemHealthPage";
import AdminLogsPage from "./pages/admin/AdminLogsPage";
import AdminResetUserPasswordPage from "./pages/admin/AdminResetUserPasswordPage";

// Common Pages
import ProfilePage from './pages/common/ProfilePage';
import NotificationsPage from './pages/common/NotificationsPage';


import './App.css';


function App() {
  return (
    <Router>
      <Routes>
        {/* Public Routes */}
        <Route path="/login" element={<LoginPage />} />
        <Route path="/register" element={<RegisterPage />} />
        <Route path="/forgot-password" element={<ForgotPasswordPage />} />
        <Route path="/reset-password" element={<ResetPasswordPage />} />
        
        {/* Common Protected Routes */}
        <Route path="/profile" element={<ProtectedRoute><ProfilePage /></ProtectedRoute>} />
        <Route path="/notifications" element={<ProtectedRoute><NotificationsPage /></ProtectedRoute>} />
        <Route path="/change-password" element={<ProtectedRoute><ChangePasswordPage /></ProtectedRoute>} />

        {/* Manager Routes */}
        <Route path="/manager/projects" element={<ProtectedRoute allowedRoles={['manager', 'admin']}><ManagerProjectListPage /></ProtectedRoute>} />
        <Route path="/manager/projects/create" element={<ProtectedRoute allowedRoles={['manager', 'admin']}><ManagerCreateProjectPage /></ProtectedRoute>} />
        <Route path="/manager/projects/:projectId" element={<ProtectedRoute allowedRoles={['manager', 'admin']}><ManagerProjectDetailPage /></ProtectedRoute>} />
        <Route path="/manager/datasets" element={<ProtectedRoute allowedRoles={['manager', 'admin']}><ManagerDatasetListPage /></ProtectedRoute>} />
        <Route path="/manager/datasets/upload" element={<ProtectedRoute allowedRoles={['manager', 'admin']}><ManagerUploadDatasetPage /></ProtectedRoute>} />
        <Route path="/manager/datasets/:datasetId" element={<ProtectedRoute allowedRoles={['manager', 'admin']}><ManagerDatasetDetailPage /></ProtectedRoute>} />
        <Route path="/manager/tasks/create" element={<ProtectedRoute allowedRoles={['manager', 'admin']}><ManagerCreateTaskPage /></ProtectedRoute>} />
        
        {/* Reviewer Routes */}
        <Route path="/reviewer/*" element={<ProtectedRoute allowedRoles={['reviewer', 'admin']}><ReviewerRoutes /></ProtectedRoute>} />

        {/* Annotator Routes */}
        <Route path="/annotator/*" element={<ProtectedRoute allowedRoles={['annotator', 'admin']}><AnnotatorRoutes /></ProtectedRoute>} />

        {/* Admin Routes */}
        <Route path="/admin/users" element={<ProtectedRoute allowedRoles={['admin']}><AdminUserManagement /></ProtectedRoute>} />
        <Route path="/admin/users/reset-password" element={<ProtectedRoute allowedRoles={['admin']}><AdminResetUserPasswordPage /></ProtectedRoute>} />
        <Route path="/admin/system-config" element={<ProtectedRoute allowedRoles={['admin']}><AdminSystemConfigPage /></ProtectedRoute>} />
        <Route path="/admin/system-health" element={<ProtectedRoute allowedRoles={['admin']}><AdminSystemHealthPage /></ProtectedRoute>} />
        <Route path="/admin/logs" element={<ProtectedRoute allowedRoles={['admin']}><AdminLogsPage /></ProtectedRoute>} />

        {/* Default Route */}
        <Route path="/" element={<Navigate to="/login" replace />} />
        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </Router>
  );
}

export default App;
