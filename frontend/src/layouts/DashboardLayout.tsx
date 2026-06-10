import React, { useState, useEffect } from 'react';
import { Link, useLocation } from 'react-router-dom';
import { useNavigate } from "react-router-dom";

import {
  LayoutDashboard,
  CheckSquare,
  History,
  Settings,
  LogOut,
  Bell,
  Search,
  Menu,
  X,
  MessageSquare,
  Users,
  ClipboardList,
  Sparkles,
  ShieldCheck
} from 'lucide-react';
import Logo from '../components/ui/Logo';
import { Button } from '../components/ui/Button';
import Background from '../components/Background';
import { INITIAL_NOTIFICATIONS } from '../data/mockData';

type Props = {
  children: React.ReactNode;
};

const NAV_BY_ROLE = {
  reviewer: [
    { label: 'Dashboard', icon: LayoutDashboard, path: '/reviewer' },
  ],

  annotator: [
    { label: 'Task List', icon: ClipboardList, path: '/annotator/tasks' }, 
  ],

  manager: [
    { label: 'Projects', icon: ClipboardList, path: '/manager/projects' }, 
    { label: 'Datasets', icon: ShieldCheck, path: '/manager/datasets' },  
  ],

  admin: [
    { label: 'User Management', icon: Users, path: '/admin/users' },
    { label: 'System Config', icon: Settings, path: '/admin/system-config' },
    { label: 'System Health', icon: ShieldCheck, path: '/admin/system-health' },
    { label: 'System Logs', icon: History, path: '/admin/logs' },
  ],
};

type UserRole = keyof typeof NAV_BY_ROLE;

export default function DashboardLayout({ children }: Props) {
  const navigate = useNavigate();
  const location = useLocation();

  const handleLogout = () => {
    localStorage.clear();
    navigate("/login");
  };

  const currentRole = (localStorage.getItem("role") || "reviewer").toLowerCase();
  const userName = localStorage.getItem("fullName") || "User";
  const navItems = NAV_BY_ROLE[currentRole as keyof typeof NAV_BY_ROLE] || [];

  const [isSidebarOpen, setIsSidebarOpen] = useState(false);
  const [showNotificationPreview, setShowNotificationPreview] = useState(false);
  const unreadCount = INITIAL_NOTIFICATIONS.filter(n => !n.isRead).length;
  const latestUnread = INITIAL_NOTIFICATIONS.find(n => !n.isRead);
  
  useEffect(() => {
    // Show preview if there are unread messages and we're not on the notifications page
    if (unreadCount > 0 && location.pathname !== '/notifications') {
      const timer = setTimeout(() => {
        setShowNotificationPreview(true);
      }, 500); // Small delay for effect
      return () => clearTimeout(timer);
    } else {
      setShowNotificationPreview(false);
    }
  }, [unreadCount, location.pathname]);

  return (
    <div className="relative min-h-screen flex overflow-hidden">
      <Background showVisuals={false} />
      
      {/* Mobile Sidebar Overlay */}
      {isSidebarOpen && (
        <div 
          className="fixed inset-0 bg-gray-900/50 z-40 lg:hidden backdrop-blur-sm"
          onClick={() => setIsSidebarOpen(false)}
        />
      )}

      {/* Sidebar */}
      <aside 
        className={`
          fixed inset-y-0 left-0 z-50 w-64 
          bg-white/70 backdrop-blur-xl border-r border-white/20 shadow-xl
          transform transition-transform duration-200 ease-in-out
          ${isSidebarOpen ? 'translate-x-0' : '-translate-x-full lg:translate-x-0'}
        `}
      >
        <div className="h-full flex flex-col">
          {/* Logo Area */}
          <div className="h-16 flex items-center px-6 border-b border-white/10">
            <Logo size="sm" showSlogan={false} />
          </div>

          {/* Navigation */}
          <div className="flex-1 overflow-y-auto py-6 px-3 space-y-1">
            {navItems.map((item) => {
              const isActive = location.pathname === item.path;
              return (
                <Link
                  key={item.path}
                  to={item.path}
                  className={`
                    flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium transition-all duration-200
                    ${isActive 
                      ? 'bg-gradient-to-r from-brand/10 to-palette-violet/10 text-brand shadow-sm border border-brand/10' 
                      : 'text-gray-600 hover:bg-white/50 hover:text-gray-900 hover:shadow-sm'
                    }
                  `}
                >
                  <item.icon className={`h-5 w-5 ${isActive ? 'text-brand' : 'text-gray-400'}`} />
                  {item.label}
                </Link>
              );
            })}
          </div>

          {/* User Profile & Logout */}
          <div className="p-4 border-t border-white/10 bg-white/30">
            <Link to="/profile" className="flex items-center gap-3 mb-4 px-2 hover:bg-white/50 p-2 rounded-lg transition-colors group">
              <div className="h-9 w-9 rounded-full bg-gradient-to-tr from-brand to-palette-violet flex items-center justify-center text-white text-sm font-semibold shadow-lg shadow-brand/20 group-hover:scale-105 transition-transform">
                {userName.charAt(0).toUpperCase()}
              </div>
              <div className="flex-1 min-w-0">
                <p className="text-sm font-medium text-gray-900 truncate">{userName}</p>
                <p className="text-xs text-gray-500 truncate capitalize">{currentRole}</p>
              </div>
            </Link>
            <Button 
              variant="ghost" 
              className="w-full justify-start text-gray-500 hover:text-red-600 hover:bg-red-50/50"
              onClick={handleLogout}
            >
              <LogOut className="h-4 w-4 mr-2" />
              Sign out
            </Button>
          </div>
        </div>
      </aside>

      {/* Main Content */}
      <div className="flex-1 flex flex-col min-w-0 relative z-10 lg:pl-64 transition-all duration-200">
        {/* Top Header */}
        <header className="h-16 bg-white/70 backdrop-blur-xl border-b border-white/20 flex items-center justify-between px-4 sm:px-6 lg:px-8 sticky top-0 z-30 shadow-sm">
          <div className="flex items-center gap-4">
            <button 
              onClick={() => setIsSidebarOpen(true)}
              className="lg:hidden p-2 -ml-2 text-gray-500 hover:bg-white/50 rounded-lg"
            >
              <Menu className="h-6 w-6" />
            </button>
            <div className="hidden sm:flex relative">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
              <input 
                type="text"
                placeholder="Search tasks, projects..."
                className="pl-9 pr-4 py-2 bg-white/50 border border-white/30 rounded-lg text-sm focus:ring-2 focus:ring-brand/20 focus:bg-white w-64 transition-all placeholder:text-gray-400"
              />
            </div>
          </div>

          <div className="flex items-center gap-3 relative">
            {/* Notification Preview Popover */}
            {showNotificationPreview && latestUnread && (
              <div className="absolute top-14 right-0 w-80 bg-white shadow-2xl border border-gray-100 rounded-2xl p-4 z-[100] animate-in fade-in slide-in-from-top-2 duration-300 ring-1 ring-black/5">
                <div className="absolute -top-2 right-5 w-4 h-4 bg-white border-t border-l border-gray-100 rotate-45" />
                <div className="flex items-start gap-3">
                  <div className="p-2 rounded-xl bg-brand/10 text-brand shrink-0">
                    <MessageSquare className="h-5 w-5" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="flex items-start justify-between">
                      <p className="text-sm font-semibold text-gray-900">New Message</p>
                      <button 
                        onClick={() => setShowNotificationPreview(false)}
                        className="text-gray-400 hover:text-gray-600 -mt-1 -mr-1 p-1"
                      >
                        <X className="h-4 w-4" />
                      </button>
                    </div>
                    <p className="text-xs text-gray-600 mt-1 line-clamp-2">{latestUnread.message}</p>
                    <div className="mt-3 flex items-center justify-between">
                      <span className="text-[10px] text-gray-400">{latestUnread.timestamp}</span>
                      <Link 
                        to="/notifications" 
                        className="text-xs font-medium text-brand hover:text-brand/80 flex items-center gap-1"
                        onClick={() => setShowNotificationPreview(false)}
                      >
                        View all 
                        <span className="bg-brand/10 text-brand px-1.5 py-0.5 rounded-full text-[10px]">{unreadCount}</span>
                      </Link>
                    </div>
                  </div>
                </div>
              </div>
            )}

            <Link to="/notifications" className="relative p-2 text-gray-400 hover:text-gray-600 hover:bg-white/50 rounded-lg transition-colors">
              <Bell className="h-5 w-5" />
              {unreadCount > 0 && (
                <span className="absolute top-2 right-2 h-2 w-2 bg-red-500 rounded-full border-2 border-white animate-pulse" />
              )}
            </Link>
          </div>
        </header>

        {/* Page Content */}
        <main className="flex-1 overflow-y-auto p-4 sm:p-6 lg:p-8">
          <div className="mx-auto max-w-6xl">
            {children}
          </div>
        </main>
      </div>
    </div>
  );
}
