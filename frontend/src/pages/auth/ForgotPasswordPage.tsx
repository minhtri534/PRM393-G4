import React, { useState } from "react";
import { Link } from "react-router-dom";
import { Mail, KeyRound, ArrowLeft, AlertCircle } from "lucide-react";
import AuthLayout from "../../layouts/AuthLayout";
import { Card } from "../../components/ui/Card";
import { Label } from "../../components/ui/Label";
import { Input } from "../../components/ui/Input";
import { Button } from "../../components/ui/Button";
import { authService } from "../../services/authService";

const ForgotPasswordPage: React.FC = () => {
  const [email, setEmail] = useState('');
  const [isSubmitted, setIsSubmitted] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    setLoading(true);

      try {
        const response = await authService.forgotPassword({ email });
        if (response.isSuccess) {
          setIsSubmitted(true);
        } else {
          setError(response.message || "An error occurred");
        }
      } catch (err: any) {
        console.error('Forgot password error:', err);
        setError(err.response?.data?.message || "Cannot connect to server");
      } finally {
        setLoading(false);
      }
  };

  return (
    <AuthLayout title="Password Recovery" subtitle="We'll help you regain access to your account." variant="simple">
      <Card className="w-full max-w-md p-8">
        <div className="flex items-center gap-3">
          <div className="h-10 w-10 rounded-xl bg-blue-100 flex items-center justify-center">
            <KeyRound className="h-5 w-5 text-blue-600" />
          </div>
          <div>
            <div className="text-sm text-gray-500">Account recovery</div>
            <h2 className="text-xl font-semibold text-gray-900">Forgot Password</h2>
          </div>
        </div>

        {error && (
          <div className="mt-4 p-3 bg-red-50 border border-red-200 text-red-600 text-sm rounded-lg flex items-center gap-2">
            <AlertCircle className="h-4 w-4 shrink-0" />
            {error}
          </div>
        )}

        {!isSubmitted ? (
          <form className="mt-8 space-y-5" onSubmit={handleSubmit}>
            <p className="text-sm text-gray-600">
              Enter the email address associated with your account and we'll send a link to reset your password.
            </p>
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
            
            <Button type="submit" fullWidth variant="gradient" disabled={loading}>
              {loading ? "Processing..." : "Send reset link"}
            </Button>
            
            <div className="text-center text-sm text-gray-600">
              <Link to="/login" className="inline-flex items-center gap-2 text-gray-600 hover:text-gray-900 transition-colors">
                <ArrowLeft className="h-4 w-4" /> Back to Login
              </Link>
            </div>
          </form>
        ) : (
          <div className="mt-8 space-y-5">
            <div className="rounded-lg bg-green-50 p-4 border border-green-100">
              <p className="text-sm text-green-800 text-center">
                If an account exists for <strong>{email}</strong>, you will receive a password reset link shortly.
              </p>
            </div>
            <Button fullWidth variant="outline" onClick={() => setIsSubmitted(false)}>
              Try a different email
            </Button>
            <div className="text-center text-sm text-gray-600">
              <Link to="/login" className="inline-flex items-center gap-2 text-gray-600 hover:text-gray-900 transition-colors">
                <ArrowLeft className="h-4 w-4" /> Back to Login
              </Link>
            </div>
          </div>
        )}
      </Card>
    </AuthLayout>
  );
};

export default ForgotPasswordPage;

