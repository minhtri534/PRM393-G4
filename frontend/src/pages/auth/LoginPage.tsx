import React, { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import { LogIn, Mail, Lock, AlertCircle } from "lucide-react";
import AuthLayout from "../../layouts/AuthLayout";
import { Card } from "../../components/ui/Card";
import { Label } from "../../components/ui/Label";
import { Input } from "../../components/ui/Input";
import { Button } from "../../components/ui/Button";
import { authService } from "../../services/authService";

const LoginPage: React.FC = () => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const navigate = useNavigate();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    setLoading(true);

    try {
      const response = await authService.login({ email, password });
      handleLoginSuccess(response);
    } catch (err: any) {
      console.error('Login error:', err);
      setError(err.response?.data?.message || "Invalid email or password");
    } finally {
      setLoading(false);
    }
  };

  const handleLoginSuccess = (response: any) => {
    if (response.isSuccess && response.data) {
      localStorage.setItem("accessToken", response.data.accessToken);
      localStorage.setItem("refreshToken", response.data.refreshToken);
      localStorage.setItem("userId", response.data.user.id);
      localStorage.setItem("fullName", response.data.user.fullName);
      localStorage.setItem("email", response.data.user.email);
      
      const role = (response.data.user.roleName || "Annotator").toLowerCase(); 
      localStorage.setItem("role", role);

      const DEFAULT_ROUTE_BY_ROLE: Record<string, string> = {
        reviewer: "/reviewer",
        annotator: "/annotator/tasks",
        manager: "/manager/projects",
        admin: "/admin/users",
      };
      
      navigate(DEFAULT_ROUTE_BY_ROLE[role] || "/annotator/tasks");
    } else {
      setError(response.message || "Login failed");
    }
  };

  const handleGoogleLogin = () => {
    // In production, use @react-oauth/google
    // This block demonstrates handling an idToken from Google
    alert("This feature requires a Google Cloud Client ID. Configure it in appsettings.json and install the frontend Google OAuth library.");
  };

  return (
    <AuthLayout title="Sign in to continue" subtitle="Access projects, tasks, and analytics in one place.">
      <Card className="w-full max-w-md p-8">
        <div className="flex items-center gap-3">
          <div className="h-10 w-10 rounded-xl bg-blue-100 flex items-center justify-center">
            <LogIn className="h-5 w-5 text-blue-600" />
          </div>
          <div>
            <div className="text-sm text-gray-500">Welcome back</div>
            <h2 className="text-xl font-semibold text-gray-900">Sign in</h2>
          </div>
        </div>

        {error && (
          <div className="mt-4 p-3 bg-red-50 border border-red-200 text-red-600 text-sm rounded-lg flex items-center gap-2">
            <AlertCircle className="h-4 w-4 shrink-0" />
            {error}
          </div>
        )}

        <form className="mt-8 space-y-5" onSubmit={handleSubmit}>
          <div>
            <Label htmlFor="email">Email</Label>
            <Input
              id="email"
              name="email"
              type="email"
              required
              leadingIcon={<Mail className="h-5 w-5" />}
              placeholder="example@email.com"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
            />
          </div>
          <div>
            <Label htmlFor="password">Password</Label>
            <Input
              id="password"
              name="password"
              type="password"
              required
              leadingIcon={<Lock className="h-5 w-5" />}
              placeholder="••••••••"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
            />
          </div>
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2">
              <input id="remember" type="checkbox" className="h-4 w-4 rounded border-gray-300 text-blue-600 focus:ring-blue-500" />
              <span className="text-sm text-gray-700">Remember me</span>
            </div>
            <Link to="/forgot-password" className="text-sm text-blue-600 hover:text-blue-700">
              Forgot password?
            </Link>
          </div>
          <Button type="submit" fullWidth variant="gradient" disabled={loading}>
            {loading ? "Processing..." : "Sign In"}
          </Button>

          <div className="relative my-6">
            <div className="absolute inset-0 flex items-center">
              <div className="w-full border-t border-gray-200"></div>
            </div>
            <div className="relative flex justify-center text-sm">
              <span className="px-2 bg-white text-gray-500">Or continue with</span>
            </div>
          </div>

          <button
            type="button"
            onClick={handleGoogleLogin}
            className="w-full flex items-center justify-center gap-3 px-4 py-2 border border-gray-300 rounded-xl bg-white text-gray-700 font-medium hover:bg-gray-50 transition-colors"
          >
            <img src="https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg" alt="Google" className="w-5 h-5" />
            Continue with Google
          </button>

          <div className="text-center mt-6 text-sm text-gray-600">
            Don't have an account?{" "}
            <Link to="/register" className="text-blue-600 hover:text-blue-700">
              Create one now
            </Link>
          </div>
        </form>
      </Card>
    </AuthLayout>
  );
};

export default LoginPage;
