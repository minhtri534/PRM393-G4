import { useState } from "react";
import DashboardLayout from "../../layouts/DashboardLayout";
import { Card } from "../../components/ui/Card";
import { Button } from "../../components/ui/Button";
import { Input } from "../../components/ui/Input";

export default function AdminSystemConfigPage() {
  const [maintenanceMode, setMaintenanceMode] = useState(false);
  const [taskPrice, setTaskPrice] = useState("5");

  const handleSave = () => {
    alert("System configuration saved.");
  };

  return (
    <DashboardLayout>
      <div className="max-w-4xl mx-auto space-y-6">
        <h1 className="text-2xl font-bold">System Configuration</h1>

        <Card className="p-6 space-y-4">
          <div className="flex items-center justify-between">
            <span>Maintenance Mode</span>
            <Button
              variant="outline"
              onClick={() => setMaintenanceMode(!maintenanceMode)}
            >
              {maintenanceMode ? "Disable" : "Enable"}
            </Button>
          </div>

          <div>
            <label className="text-sm">Price per Task (USD)</label>
            <Input
              value={taskPrice}
              onChange={(e) => setTaskPrice(e.target.value)}
            />
          </div>

          <Button variant="gradient" onClick={handleSave}>
            Save Settings
          </Button>
        </Card>
      </div>
    </DashboardLayout>
  );
}
