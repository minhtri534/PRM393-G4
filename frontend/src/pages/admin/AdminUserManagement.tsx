import React, { useState, useEffect } from 'react';
import DashboardLayout from '../../layouts/DashboardLayout';
import { Button } from '../../components/ui/Button';
import { Input } from '../../components/ui/Input';
import { userService, type UserResponse } from '../../services/userService';
import { roleService, type RoleResponse } from '../../services/roleService';
import { adminService } from '../../services/adminService';
import {
  Users,
  Search,
  Key,
  CheckCircle,
  XCircle,
  RefreshCw,
  Trash2,
  Edit,
  Shield,
  Loader2,
  Badge
} from 'lucide-react';

const AdminUserManagement: React.FC = () => {
  const [users, setUsers] = useState<UserResponse[]>([]);
  const [roles, setRoles] = useState<RoleResponse[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState('');
  const [resettingId, setResettingId] = useState<string | null>(null);
  const [newUserName, setNewUserName] = useState('');
  const [newUserEmail, setNewUserEmail] = useState('');
  const [newUserPassword, setNewUserPassword] = useState('');
  const [newUserRole, setNewUserRole] = useState('');

  useEffect(() => {
    fetchData();
  }, []);

  const fetchData = async () => {
    setLoading(true);
    try {
      const [userRes, roleRes] = await Promise.all([
        userService.getAll(),
        roleService.getAll()
      ]);
      if (userRes.isSuccess) setUsers(userRes.data);
      if (roleRes.isSuccess) {
        setRoles(roleRes.data);
        if (roleRes.data.length > 0) setNewUserRole(roleRes.data[0].id);
      }
    } finally {
      setLoading(false);
    }
  };

  const filteredUsers = users.filter(user =>
    user.fullName.toLowerCase().includes(searchQuery.toLowerCase()) ||
    user.email.toLowerCase().includes(searchQuery.toLowerCase())
  );

  // =============================
  // CREATE USER (UC-99)
  // =============================
  const handleCreateUser = async () => {
    if (!newUserName || !newUserEmail || !newUserPassword || !newUserRole) {
      alert('Please fill in all fields: Name, Email, Password and Role.');
      return;
    }

    const res = await userService.create({
      fullName: newUserName,
      email: newUserEmail,
      password: newUserPassword,
      roleId: newUserRole,
      status: 0
    });

    if (res.isSuccess) {
      setNewUserName('');
      setNewUserEmail('');
      setNewUserPassword('');
      alert('New user created successfully!');
      fetchData();
    } else {
      alert(res.message || 'Error creating user.');
    }
  };

  // =============================
  // UPDATE ROLE (UC-101 + UC-105)
  // =============================
  const handleChangeRole = async (userId: string, roleId: string) => {
    const res = await adminService.assignRole(userId, { roleId });
    if (res.isSuccess) {
      alert('Role updated successfully!');
      fetchData();
    } else {
      alert(res.message || 'Error updating role.');
    }
  };

  // =============================
  // DISABLE USER (UC-102)
  // =============================
  const handleDisableUser = async (userId: string) => {
    if (!confirm('Are you sure you want to disable this user?')) return;
    
    const res = await adminService.disableUser(userId);
      if (res.isSuccess) {
      alert('User disabled.');
      fetchData();
    } else {
      alert(res.message || 'Error disabling user.');
    }
  };

  // =============================
  // DELETE USER (UC-103)
  // =============================
  const handleDeleteUser = async (id: string) => {
    if (!confirm('This action is irreversible. Are you sure you want to delete this user?')) return;

    const res = await userService.delete(id);
    if (res.isSuccess) {
      alert('User removed from the system.');
      fetchData();
    } else {
      alert(res.message || 'Error deleting user.');
    }
  };

  // =============================
  // RESET PASSWORD
  // =============================
  const handleResetPassword = async (userId: string) => {
    const newPassword = prompt('Enter a new password for this user:');
    if (!newPassword) return;

    setResettingId(userId);
    try {
      const res = await adminService.resetUserPassword(userId, { newPassword });
        if (res.isSuccess) {
        alert('Password reset successfully!');
      } else {
        alert(res.message || 'Error resetting password.');
      }
    } finally {
      setResettingId(null);
    }
  };

  return (
    <DashboardLayout>
      <div className="space-y-8 max-w-6xl mx-auto">

        {/* HEADER */}
        <div>
          <h1 className="text-3xl font-bold">User Management (Admin)</h1>
          <p className="text-gray-500">Manage accounts, roles and active status</p>
        </div>

        {/* CREATE USER FORM */}
        <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-100 space-y-4">
          <h2 className="font-semibold text-gray-700 flex items-center gap-2">
            <Users className="h-5 w-5 text-blue-600" />
            Create New Account
          </h2>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-4">
            <Input
              placeholder="Full name"
              value={newUserName}
              onChange={(e) => setNewUserName(e.target.value)}
            />
            <Input
              placeholder="Email"
              value={newUserEmail}
              onChange={(e) => setNewUserEmail(e.target.value)}
            />
            <Input
              type="password"
              placeholder="Password"
              value={newUserPassword}
              onChange={(e) => setNewUserPassword(e.target.value)}
            />
            <select
              className="border border-gray-200 rounded-lg px-3 h-10 text-sm focus:ring-2 focus:ring-blue-500 outline-none"
              value={newUserRole}
              onChange={(e) => setNewUserRole(e.target.value)}
            >
              {roles.map(role => (
                <option key={role.id} value={role.id}>{role.name}</option>
              ))}
            </select>

            <Button onClick={handleCreateUser} className="bg-blue-600 hover:bg-blue-700">
              Create
            </Button>
          </div>
        </div>

        {/* SEARCH */}
        <div className="flex gap-4 items-center bg-white p-2 rounded-lg shadow-sm border border-gray-100">
          <Search className="h-5 w-5 text-gray-400 ml-2" />
            <Input
            className="border-none focus:ring-0 shadow-none"
            placeholder="Search by name or email..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
          />
        </div>

        {/* USER TABLE */}
        <div className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
          {loading ? (
              <div className="p-12 flex flex-col items-center justify-center gap-3 text-gray-500">
              <Loader2 className="animate-spin h-8 w-8 text-blue-600" />
              <p>Loading users...</p>
            </div>
          ) : (
            <>
              <table className="w-full text-sm text-left">
                <thead className="bg-gray-50 text-gray-600 uppercase text-xs font-bold">
                  <tr>
                    <th className="p-4">Thông tin người dùng</th>
                    <th>Vai trò</th>
                    <th>Trạng thái</th>
                    <th className="p-4 text-center">Thao tác</th>
                  </tr>
                </thead>

                <tbody className="divide-y divide-gray-100">
                  {filteredUsers.map(user => (
                    <tr key={user.id} className="hover:bg-blue-50/30 transition-colors">
                      <td className="p-4">
                        <div className="font-semibold text-gray-900">{user.fullName}</div>
                        <div className="text-gray-500 text-xs">{user.email}</div>
                      </td>

                      <td>
                        <select
                          className="border border-gray-200 rounded px-2 py-1 text-xs bg-white focus:ring-1 focus:ring-blue-500 outline-none"
                          value={user.roleId}
                          onChange={(e) =>
                            handleChangeRole(user.id, e.target.value)
                          }
                        >
                          {roles.map(role => (
                            <option key={role.id} value={role.id}>{role.name}</option>
                          ))}
                        </select>
                      </td>

                      <td>
                        {user.status === 0 ? (
                          <Badge className="gap-1 bg-green-100 text-green-800">
                            <CheckCircle size={12} /> Đang hoạt động
                          </Badge>
                        ) : (
                          <Badge className="gap-1 bg-gray-100 text-gray-800">
                            <XCircle size={12} /> Đã khóa
                          </Badge>
                        )}
                      </td>

                      <td className="p-4">
                        <div className="flex justify-center gap-1">
                          <Button
                            variant="ghost"
                            size="sm"
                            title="Đặt lại mật khẩu"
                            className="text-blue-600 hover:bg-blue-100"
                            onClick={() => handleResetPassword(user.id)}
                            disabled={resettingId === user.id}
                          >
                            {resettingId === user.id ? (
                              <RefreshCw className="animate-spin h-4 w-4" />
                            ) : (
                              <Key className="h-4 w-4" />
                            )}
                          </Button>

                          <Button
                            variant="ghost"
                            size="sm"
                            title="Vô hiệu hóa"
                            className={`${user.status === 0 ? 'text-yellow-600 hover:bg-yellow-100' : 'text-gray-300'}`}
                            onClick={() => handleDisableUser(user.id)}
                            disabled={user.status !== 0}
                          >
                            <Shield className="h-4 w-4" />
                          </Button>

                          <Button
                            variant="ghost"
                            size="sm"
                            title="Xóa người dùng"
                            className="text-red-600 hover:bg-red-100"
                            onClick={() => handleDeleteUser(user.id)}
                          >
                            <Trash2 className="h-4 w-4" />
                          </Button>
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>

              {filteredUsers.length === 0 && (
                <div className="p-12 text-center text-gray-400 italic">
                  Không tìm thấy người dùng nào phù hợp.
                </div>
              )}
            </>
          )}
        </div>
      </div>
    </DashboardLayout>
  );
};

export default AdminUserManagement;
