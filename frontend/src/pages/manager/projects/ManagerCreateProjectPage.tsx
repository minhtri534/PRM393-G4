import React, { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import { ArrowLeft, PlusCircle, FileText, Loader } from "lucide-react";
import DashboardLayout from "../../../layouts/DashboardLayout";
import { Card } from "../../../components/ui/Card";
import { Label } from "../../../components/ui/Label";
import { Input } from "../../../components/ui/Input";
import { Button } from "../../../components/ui/Button";
import { Textarea } from "../../../components/ui/Textarea";
import { managerService } from "../../../services/managerService";
import type { CreateProjectRequest } from "../../../types/manager";

const ManagerCreateProjectPage: React.FC = () => {
  const navigate = useNavigate();
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const [formData, setFormData] = useState<CreateProjectRequest>({
    name: "",
    guideline: "",
  });

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
    const { name, value } = e.currentTarget;
    setFormData(prev => ({
      ...prev,
      [name]: value,
    }));
    setError(null);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!formData.name.trim()) {
      setError("Please enter a project name");
      return;
    }

    try {
      setLoading(true);
      const response = await managerService.createProject(formData);

      if (response.isSuccess) {
        navigate("/manager/projects");
      } else {
        setError(response.message || "Failed to create project");
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to create project");
    } finally {
      setLoading(false);
    }
  };

  return (
    <DashboardLayout>
      <div className="max-w-4xl mx-auto space-y-8">
        <div className="flex items-center gap-4">
          <Link to="/manager/projects" className="p-2 hover:bg-gray-100 rounded-full transition-colors">
            <ArrowLeft className="h-6 w-6 text-gray-600" />
          </Link>
          <div>
            <h1 className="text-3xl font-bold text-gray-900 tracking-tight">
              Create New Project
            </h1>
            <p className="text-gray-500 mt-1">
              Enter the details to create a new labeling project.
            </p>
          </div>
        </div>

        <form onSubmit={handleSubmit}>
          <Card variant="glass" className="p-8 space-y-8">
            <div className="space-y-6">
              <div>
                <Label htmlFor="name">
                  Project Name <span className="text-red-600">*</span>
                </Label>
                <Input
                  id="name"
                  name="name"
                  required
                  placeholder="E.g.: Product reviews sentiment analysis"
                  leadingIcon={<FileText className="h-5 w-5" />}
                  value={formData.name}
                  onChange={handleInputChange}
                />
              </div>

              <div>
                <Label htmlFor="guideline">Guidelines & Rules</Label>
                <Textarea
                  id="guideline"
                  name="guideline"
                  placeholder="Describe objectives, requirements, and instructions for annotators."
                  rows={5}
                  value={formData.guideline || ""}
                  onChange={handleInputChange}
                />
              </div>
            </div>

            {error && (
              <div className="text-red-600 text-sm font-medium">
                {error}
              </div>
            )}

            <div className="pt-8 flex justify-end gap-4">
              <Link to="/manager/projects">
                <Button type="button" variant="ghost" disabled={loading}>
                  Cancel
                </Button>
              </Link>

              <Button type="submit" variant="gradient" disabled={loading}>
                {loading ? (
                  <>
                    <Loader className="h-4 w-4 mr-2 animate-spin" />
                    Creating...
                  </>
                ) : (
                  <>
                    <PlusCircle className="h-4 w-4 mr-2" />
                    Create Project
                  </>
                )}
              </Button>
            </div>
          </Card>
        </form>
      </div>
    </DashboardLayout>
  );
};

export default ManagerCreateProjectPage;