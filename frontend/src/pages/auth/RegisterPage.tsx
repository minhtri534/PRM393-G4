import React, { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import { UserPlus, User, Mail, Lock, Phone, CreditCard, MapPin, Calendar, Users, AlertCircle, CheckCircle2 } from "lucide-react";
import AuthLayout from "../../layouts/AuthLayout";
import { Card } from "../../components/ui/Card";
import { Label } from "../../components/ui/Label";
import { Input } from "../../components/ui/Input";
import { Button } from "../../components/ui/Button";
import { authService } from "../../services/authService";

// Helper to display input errors
const ErrorMessage: React.FC<{ message?: string }> = ({ message }) => {
  if (!message) return null;
  return (
    <span className="flex items-center gap-1 mt-1 text-xs text-red-500 font-medium">
      <AlertCircle className="h-3 w-3" />
      {message}
    </span>
  );
};

const RegisterPage: React.FC = () => {
  const navigate = useNavigate();
  const [loading, setLoading] = useState(false);
  const [serverError, setServerError] = useState<string | null>(null);
  const [successMessage, setSuccessMessage] = useState<string | null>(null);
  const [step, setStep] = useState<'register' | 'verify'>('register');
  const [pendingEmail, setPendingEmail] = useState('');
  const [otpCode, setOtpCode] = useState('');
  const [devOtp, setDevOtp] = useState<string | null>(null);
  const [errors, setErrors] = useState<Record<string, string>>({});
  
  const [formData, setFormData] = useState({
    fullName: '',
    email: '',
    password: '',
    confirmPassword: '',
    phoneNumber: '',
    identifyNumber: '',
    gender: '',
    address: '',
    dateOfBirth: '',
  });

  const validate = () => {
    const newErrors: Record<string, string> = {};
    
    if (!formData.fullName.trim()) {
      newErrors.fullName = "Full name is required";
    } else if (formData.fullName.length > 150) {
      newErrors.fullName = "Full name must not exceed 150 characters";
    }
    
    if (!formData.email) {
      newErrors.email = "Email is required";
    } else if (!/\S+@\S+\.\S+/.test(formData.email)) {
      newErrors.email = "Invalid email address";
    } else if (formData.email.length > 320) {
      newErrors.email = "Email must not exceed 320 characters";
    }
    
    if (!formData.password) {
      newErrors.password = "Password is required";
    } else if (formData.password.length < 8) {
      newErrors.password = "Password must be at least 8 characters";
    } else if (formData.password.length > 128) {
      newErrors.password = "Password must not exceed 128 characters";
    }
    
    if (formData.password !== formData.confirmPassword) {
      newErrors.confirmPassword = "Password confirmation does not match";
    }

    if (formData.phoneNumber && formData.phoneNumber.length > 20) {
      newErrors.phoneNumber = "Phone number must not exceed 20 characters";
    }

    if (formData.identifyNumber && formData.identifyNumber.length > 20) {
      newErrors.identifyNumber = "ID number must not exceed 20 characters";
    }

    if (formData.address && formData.address.length > 300) {
      newErrors.address = "Address must not exceed 300 characters";
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
    // Clear error when user types
    if (errors[name]) {
      setErrors(prev => {
        const updated = { ...prev };
        delete updated[name];
        return updated;
      });
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setServerError(null);
    setSuccessMessage(null);
    setErrors({}); // Reset lỗi cũ

    if (!validate()) return;

    setLoading(true);
    try {
      const response = await authService.register({
        fullName: formData.fullName,
        email: formData.email,
        password: formData.password,
        phoneNumber: formData.phoneNumber || undefined,
        identifyNumber: formData.identifyNumber || undefined,
        gender: formData.gender || undefined,
        address: formData.address || undefined,
        dateOfBirth: formData.dateOfBirth || undefined,
      });

      if (response.isSuccess) {
        setPendingEmail(response.data?.email || formData.email);
        setDevOtp(response.data?.devOtp ?? null);
        setOtpCode(response.data?.devOtp ?? '');
        setStep('verify');
        setSuccessMessage(response.message || 'Verification code sent to your email.');
      } else {
          setServerError(response.message || "Registration failed");
      }
    } catch (err: any) {
      console.error('Register error:', err);
      
      // Xử lý lỗi validation từ ASP.NET Core (400 Bad Request)
      if (err.response?.status === 400 && err.response?.data?.errors) {
        const backendErrors = err.response.data.errors;
        const newErrors: Record<string, string> = {};
        
        // Map lỗi từ backend về frontend (Ví dụ: Email -> email)
        Object.keys(backendErrors).forEach(key => {
          const fieldName = key.charAt(0).toLowerCase() + key.slice(1);
          newErrors[fieldName] = backendErrors[key][0]; // Lấy câu thông báo lỗi đầu tiên
        });
        
        setErrors(newErrors);
        setServerError("Please review the form and correct errors.");
      } else {
        setServerError(err.response?.data?.message || "An error occurred while connecting to the server");
      }
    } finally {
      setLoading(false);
    }
  };

  const handleVerifyOtp = async (e: React.FormEvent) => {
    e.preventDefault();
    setServerError(null);
    setSuccessMessage(null);

    if (!/^\d{6}$/.test(otpCode.trim())) {
      setServerError('Please enter the 6-digit verification code.');
      return;
    }

    setLoading(true);
    try {
      const response = await authService.verifyEmailOtp({
        email: pendingEmail,
        otpCode: otpCode.trim(),
      });

      if (response.isSuccess) {
        setSuccessMessage('Email verified successfully! Redirecting to sign in...');
        setTimeout(() => navigate('/login'), 1500);
      } else {
        setServerError(response.message || 'Verification failed');
      }
    } catch (err: any) {
      setServerError(err.response?.data?.message || 'Verification failed');
    } finally {
      setLoading(false);
    }
  };

  const handleResendOtp = async () => {
    setServerError(null);
    setLoading(true);
    try {
      const response = await authService.resendVerificationOtp({ email: pendingEmail });
      if (response.isSuccess) {
        setDevOtp(response.data?.devOtp ?? null);
        if (response.data?.devOtp) {
          setOtpCode(response.data.devOtp);
        }
        setSuccessMessage(response.message || 'Verification code resent.');
      } else {
        setServerError(response.message || 'Could not resend verification code');
      }
    } catch (err: any) {
      setServerError(err.response?.data?.message || 'Could not resend verification code');
    } finally {
      setLoading(false);
    }
  };

  if (step === 'verify') {
    return (
      <AuthLayout title="Verify Email" subtitle="Enter the code sent to your inbox.">
        <Card className="w-full max-w-md p-8">
          <div className="flex items-center gap-3">
            <div className="h-10 w-10 rounded-xl bg-blue-100 flex items-center justify-center">
              <Mail className="h-5 w-5 text-blue-600" />
            </div>
            <div>
              <div className="text-sm text-gray-500">Almost done</div>
              <h2 className="text-xl font-semibold text-gray-900">Verify your email</h2>
            </div>
          </div>

          <p className="mt-4 text-sm text-gray-600">
            We sent a 6-digit code to <strong>{pendingEmail}</strong>.
          </p>

          {devOtp && (
            <div className="mt-4 p-3 bg-blue-50 border border-blue-200 text-blue-700 text-sm rounded-lg">
              Dev mode OTP: <strong>{devOtp}</strong>
            </div>
          )}

          {serverError && (
            <div className="mt-4 p-3 bg-red-50 border border-red-200 text-red-600 text-sm rounded-lg flex items-center gap-2">
              <AlertCircle className="h-4 w-4 shrink-0" />
              {serverError}
            </div>
          )}

          {successMessage && (
            <div className="mt-4 p-3 bg-green-50 border border-green-200 text-green-600 text-sm rounded-lg flex items-center gap-2">
              <CheckCircle2 className="h-4 w-4 shrink-0" />
              {successMessage}
            </div>
          )}

          <form className="mt-6 space-y-4" onSubmit={handleVerifyOtp}>
            <div>
              <Label htmlFor="otpCode">Verification code</Label>
              <Input
                id="otpCode"
                name="otpCode"
                type="text"
                inputMode="numeric"
                maxLength={6}
                leadingIcon={<Lock className="h-5 w-5" />}
                placeholder="123456"
                value={otpCode}
                onChange={(e) => setOtpCode(e.target.value.replace(/\D/g, '').slice(0, 6))}
              />
            </div>

            <Button type="submit" fullWidth variant="gradient" disabled={loading}>
              {loading ? 'Verifying...' : 'Verify & Continue'}
            </Button>

            <Button type="button" fullWidth variant="outline" disabled={loading} onClick={handleResendOtp}>
              Resend code
            </Button>
          </form>
        </Card>
      </AuthLayout>
    );
  }

  return (
    <AuthLayout title="Create Account" subtitle="Start managing data and tasks with ease.">
      <Card className="w-full max-w-2xl p-8">
        <div className="flex items-center gap-3">
          <div className="h-10 w-10 rounded-xl bg-green-100 flex items-center justify-center">
            <UserPlus className="h-5 w-5 text-green-600" />
          </div>
          <div>
            <div className="text-sm text-gray-500">Get started</div>
            <h2 className="text-xl font-semibold text-gray-900">Register an Account</h2>
          </div>
        </div>

        {serverError && (
          <div className="mt-4 p-3 bg-red-50 border border-red-200 text-red-600 text-sm rounded-lg flex items-center gap-2">
            <AlertCircle className="h-4 w-4 shrink-0" />
            {serverError}
          </div>
        )}

        {successMessage && (
          <div className="mt-4 p-3 bg-green-50 border border-green-200 text-green-600 text-sm rounded-lg flex items-center gap-2">
            <CheckCircle2 className="h-4 w-4 shrink-0" />
            {successMessage}
          </div>
        )}

        <form className="mt-8 space-y-6" onSubmit={handleSubmit} noValidate>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
            {/* Thông tin cơ bản */}
            <div className="space-y-5">
              <h3 className="text-sm font-medium text-gray-700 border-b pb-2">Account information</h3>
              <div>
                <Label htmlFor="fullName">Full name *</Label>
                <Input
                  id="fullName"
                  name="fullName"
                  type="text"
                  required
                  leadingIcon={<User className="h-5 w-5" />}
                  placeholder="John Doe"
                  value={formData.fullName}
                  onChange={handleChange}
                  className={errors.fullName ? "border-red-500 focus:ring-red-200" : ""}
                />
                <ErrorMessage message={errors.fullName} />
              </div>
              <div>
                <Label htmlFor="email">Email *</Label>
                <Input
                  id="email"
                  name="email"
                  type="email"
                  required
                  leadingIcon={<Mail className="h-5 w-5" />}
                  placeholder="example@email.com"
                  value={formData.email}
                  onChange={handleChange}
                  className={errors.email ? "border-red-500 focus:ring-red-200" : ""}
                />
                <ErrorMessage message={errors.email} />
              </div>
              <div>
                <Label htmlFor="password">Password *</Label>
                <Input
                  id="password"
                  name="password"
                  type="password"
                  required
                  leadingIcon={<Lock className="h-5 w-5" />}
                  placeholder="••••••••"
                  value={formData.password}
                  onChange={handleChange}
                  className={errors.password ? "border-red-500 focus:ring-red-200" : ""}
                />
                <ErrorMessage message={errors.password} />
              </div>
              <div>
                <Label htmlFor="confirmPassword">Confirm password *</Label>
                <Input
                  id="confirmPassword"
                  name="confirmPassword"
                  type="password"
                  required
                  leadingIcon={<Lock className="h-5 w-5" />}
                  placeholder="••••••••"
                  value={formData.confirmPassword}
                  onChange={handleChange}
                  className={errors.confirmPassword ? "border-red-500 focus:ring-red-200" : ""}
                />
                <ErrorMessage message={errors.confirmPassword} />
              </div>
            </div>

            {/* Thông tin cá nhân */}
            <div className="space-y-5">
              <h3 className="text-sm font-medium text-gray-700 border-b pb-2">Personal information</h3>
              <div>
                <Label htmlFor="phoneNumber">Phone number</Label>
                <Input
                  id="phoneNumber"
                  name="phoneNumber"
                  type="tel"
                  leadingIcon={<Phone className="h-5 w-5" />}
                  placeholder="0987xxxxxx"
                  value={formData.phoneNumber}
                  onChange={handleChange}
                  className={errors.phoneNumber ? "border-red-500 focus:ring-red-200" : ""}
                />
                <ErrorMessage message={errors.phoneNumber} />
              </div>
              <div>
                <Label htmlFor="identifyNumber">ID number</Label>
                <Input
                  id="identifyNumber"
                  name="identifyNumber"
                  type="text"
                  leadingIcon={<CreditCard className="h-5 w-5" />}
                  placeholder="031xxxxxxxx"
                  value={formData.identifyNumber}
                  onChange={handleChange}
                  className={errors.identifyNumber ? "border-red-500 focus:ring-red-200" : ""}
                />
                <ErrorMessage message={errors.identifyNumber} />
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <Label htmlFor="gender">Giới tính</Label>
                  <div className="relative">
                    <div className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400">
                      <Users className="h-5 w-5" />
                    </div>
                    <select
                      id="gender"
                      name="gender"
                      className="w-full h-11 rounded-xl border border-gray-300 bg-white pl-10 pr-3 py-2 text-gray-900 focus:border-blue-500 focus:ring-2 focus:ring-blue-200 outline-none appearance-none"
                      value={formData.gender}
                      onChange={handleChange}
                    >
                      <option value="">Choose...</option>
                      <option value="Male">Male</option>
                      <option value="Female">Female</option>
                      <option value="Other">Other</option>
                    </select>
                  </div>
                </div>
                <div>
                  <Label htmlFor="dateOfBirth">Date of birth</Label>
                  <Input
                    id="dateOfBirth"
                    name="dateOfBirth"
                    type="date"
                    leadingIcon={<Calendar className="h-5 w-5" />}
                    value={formData.dateOfBirth}
                    onChange={handleChange}
                  />
                </div>
              </div>
              <div>
                <Label htmlFor="address">Address</Label>
                <Input
                  id="address"
                  name="address"
                  type="text"
                  leadingIcon={<MapPin className="h-5 w-5" />}
                  placeholder="Số nhà, tên đường, quận/huyện..."
                  value={formData.address}
                  onChange={handleChange}
                />
              </div>
            </div>
          </div>

          <div className="pt-4 border-t">
            <div className="flex items-center gap-2 mb-6">
              <input id="terms" name="terms" type="checkbox" required className="h-4 w-4 rounded border-gray-300 text-green-600 focus:ring-green-500" />
              <span className="text-sm text-gray-700">I agree to the Terms and Conditions</span>
            </div>
            
            <Button type="submit" fullWidth variant="gradient" disabled={loading}>
              {loading ? "Processing..." : "Create account"}
            </Button>
            
            <div className="text-center mt-6 text-sm text-gray-600">
              Already have an account?{" "}
              <Link to="/login" className="text-blue-600 hover:text-blue-700">
                Sign in
              </Link>
            </div>
          </div>
        </form>
      </Card>
    </AuthLayout>
  );
};

export default RegisterPage;


