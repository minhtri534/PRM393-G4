import React, { useEffect, useState } from "react";
import DashboardLayout from "../../layouts/DashboardLayout";
import { Card } from "../../components/ui/Card";
import { Badge } from "../../components/ui/Badge";
import { adminService, type AdminSystemHealthResponse } from "../../services/adminService";
import { 
  Activity, 
  Database, 
  HardDrive, 
  Cpu, 
  Clock, 
  CheckCircle, 
  AlertCircle,
  RefreshCw,
  Loader2
} from "lucide-react";
import { Button } from "../../components/ui/Button";

const AdminSystemHealthPage: React.FC = () => {
  const [health, setHealth] = useState<AdminSystemHealthResponse | null>(null);
  const [loading, setLoading] = useState(true);

  const fetchHealth = async () => {
    setLoading(true);
    try {
      const res = await adminService.getSystemHealth();
      if (res.isSuccess) {
        setHealth(res.data);
      }
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchHealth();
    const interval = setInterval(fetchHealth, 30000); // Auto refresh every 30s
    return () => clearInterval(interval);
  }, []);

  if (loading && !health) {
    return (
      <DashboardLayout>
        <div className="h-full flex items-center justify-center">
          <Loader2 className="h-8 w-8 animate-spin text-blue-600" />
        </div>
      </DashboardLayout>
    );
  }

  return (
    <DashboardLayout>
      <div className="space-y-6 max-w-5xl mx-auto">
        <div className="flex justify-between items-center">
          <div>
            <h1 className="text-3xl font-bold text-gray-900">System Health</h1>
            <p className="text-gray-500">Real-time monitoring of system components</p>
          </div>
          <Button variant="outline" onClick={fetchHealth} disabled={loading}>
            <RefreshCw className={`h-4 w-4 mr-2 ${loading ? 'animate-spin' : ''}`} />
            Refresh
          </Button>
        </div>

        {/* STATUS SUMMARY */}
        <Card className={`p-6 border-l-4 ${health?.status === 'Healthy' ? 'border-l-green-500' : 'border-l-red-500'}`}>
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-4">
              <div className={`p-3 rounded-full ${health?.status === 'Healthy' ? 'bg-green-100 text-green-600' : 'bg-red-100 text-red-600'}`}>
                {health?.status === 'Healthy' ? <CheckCircle size={24} /> : <AlertCircle size={24} />}
              </div>
              <div>
                <p className="text-sm text-gray-500 uppercase font-semibold tracking-wider">Overall Status</p>
                <h2 className="text-2xl font-bold">{health?.status || 'Unknown'}</h2>
              </div>
            </div>
            <Badge variant={health?.status === 'Healthy' ? 'success' : 'danger'} className="px-4 py-1 text-sm">
              SYSTEM {health?.status?.toUpperCase()}
            </Badge>
          </div>
        </Card>

        {/* METRICS GRID */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
          <Card className="p-4 flex items-center gap-4">
            <div className="p-2 bg-blue-50 text-blue-600 rounded-lg">
              <Database size={20} />
            </div>
            <div>
              <p className="text-xs text-gray-500">Database</p>
              <p className="font-bold">{health?.databaseConnected ? 'Connected' : 'Disconnected'}</p>
            </div>
          </Card>

          <Card className="p-4 flex items-center gap-4">
            <div className="p-2 bg-purple-50 text-purple-600 rounded-lg">
              <HardDrive size={20} />
            </div>
            <div>
              <p className="text-xs text-gray-500">Storage</p>
              <p className="font-bold">{health?.storageAvailable ? 'Available' : 'Full/Error'}</p>
            </div>
          </Card>

          <Card className="p-4 flex items-center gap-4">
            <div className="p-2 bg-orange-50 text-orange-600 rounded-lg">
              <Cpu size={20} />
            </div>
            <div>
              <p className="text-xs text-gray-500">Memory Usage</p>
              <p className="font-bold">{(health?.memoryUsageMb ?? 0).toFixed(0)} MB</p>
            </div>
          </Card>

          <Card className="p-4 flex items-center gap-4">
            <div className="p-2 bg-green-50 text-green-600 rounded-lg">
              <Clock size={20} />
            </div>
            <div>
              <p className="text-xs text-gray-500">Uptime</p>
              <p className="font-bold">{((health?.uptimeSeconds || 0) / 3600).toFixed(1)} hours</p>
            </div>
          </Card>
        </div>
      </div>
    </DashboardLayout>
  );
};

export default AdminSystemHealthPage;
