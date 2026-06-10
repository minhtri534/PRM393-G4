import React from 'react';
import { Card } from '../../components/ui/Card';
import { Button } from '../../components/ui/Button';
import { Input } from '../../components/ui/Input';
import DashboardLayout from '../../layouts/DashboardLayout';
import { Search, KeyRound } from 'lucide-react';

const AdminResetUserPasswordPage: React.FC = () => {
  return (
    <DashboardLayout>
      <div className="max-w-2xl mx-auto space-y-6">
        <div>
          <h1 className="text-3xl font-bold text-gray-900 tracking-tight">Reset User Password</h1>
          <p className="text-gray-500 mt-1">Search and reset password for any account within the system.</p>
        </div>

        <Card variant="glass" className="p-8 space-y-6">
          {/* Search User */}
          <div className="space-y-2">
            <label htmlFor="user-search" className="font-medium">Find User</label>
            <div className="flex gap-2">
              <Input id="user-search" placeholder="Enter email, username, or ID..." />
              <Button variant="outline"><Search className="h-4 w-4 mr-2"/> Search</Button>
            </div>
          </div>

          {/* User Info & Reset Action */}
          <div className="bg-gray-50 p-4 rounded-lg border space-y-4">
            <div className="flex justify-between items-center">
                <div>
                    <p className="font-semibold">Nguyễn Văn A</p>
                    <p className="text-sm text-gray-500">nguyenvana@example.com</p>
                </div>
                <Button variant="secondary" className="bg-red-500 text-white hover:bg-red-600">
                    <KeyRound className="h-4 w-4 mr-2"/>
                    Reset Password
                </Button>
            </div>
          </div>

        </Card>
      </div>
    </DashboardLayout>
  );
};

export default AdminResetUserPasswordPage;
