import React, { useEffect, useState } from "react";
import { useNavigate, useLocation } from "react-router-dom";
import { ArrowLeft, PlusCircle, Users, Search, Loader2, CheckCircle } from "lucide-react";
import DashboardLayout from "../../../layouts/DashboardLayout";
import { Card } from "../../../components/ui/Card";
import { Label } from "../../../components/ui/Label";
import { Input } from "../../../components/ui/Input";
import { Button } from "../../../components/ui/Button";
import { managerService } from "../../../services/managerService";
import type { ProjectResponse, DatasetResponse, UserProjectRoleResponse } from "../../../types/manager";

const ManagerCreateTaskPage: React.FC = () => {
  const navigate = useNavigate();
  const location = useLocation();
  const queryParams = new URLSearchParams(location.search);
  const initialProjectId = queryParams.get("projectId") || "";

  const [projects, setProjects] = useState<ProjectResponse[]>([]);
  const [datasets, setDatasets] = useState<DatasetResponse[]>([]);
  const [annotators, setAnnotators] = useState<UserProjectRoleResponse[]>([]);
  const [loading, setLoading] = useState(true);
  const [loadingAnnotators, setLoadingAnnotators] = useState(false);
  const [submitting, setSubmitting] = useState(false);

  const [selectedProjectId, setSelectedProjectId] = useState(initialProjectId);
  const [selectedDatasetId, setSelectedDatasetId] = useState("");
  const [selectedAnnotatorId, setSelectedAnnotatorId] = useState("");
  const [searchQuery, setSearchQuery] = useState("");

  useEffect(() => {
    fetchInitialData();
  }, []);

  useEffect(() => {
    if (selectedProjectId) {
      fetchDatasets(selectedProjectId);
      fetchAnnotators(selectedProjectId);
    } else {
      setDatasets([]);
      setAnnotators([]);
    }
  }, [selectedProjectId]);

  const fetchInitialData = async () => {
    setLoading(true);
    try {
      const projRes = await managerService.getProjects();

      if (projRes.isSuccess && projRes.data) {
        setProjects(projRes.data);
      } else {
        setProjects([]);
      }
    } catch (err) {
      alert(err instanceof Error ? err.message : "Error loading data");
    } finally {
      setLoading(false);
    }
  };

  const fetchDatasets = async (pid: string) => {
    try {
      const res = await managerService.getDatasets(pid);
      if (res.isSuccess && res.data) {
        setDatasets(res.data);
        if (res.data.length > 0) {
          setSelectedDatasetId(res.data[0].id);
        }
      } else {
        setDatasets([]);
      }
    } catch {
      setDatasets([]);
    }
  };

  const fetchAnnotators = async (pid: string) => {
    setLoadingAnnotators(true);
    try {
      const res = await managerService.getProjectRoles(pid);
      if (res.isSuccess && res.data) {
        // Filter only Annotators
        setAnnotators(res.data.filter(r => r.roleName === "Annotator"));
      } else {
        setAnnotators([]);
      }
    } catch {
      setAnnotators([]);
    } finally {
      setLoadingAnnotators(false);
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!selectedProjectId || !selectedDatasetId || !selectedAnnotatorId) {
      alert("Please select Project, Dataset and Annotator");
      return;
    }

    setSubmitting(true);

    try {
      const res = await managerService.bulkCreateTasksByDataset({
        projectId: selectedProjectId,
        datasetId: selectedDatasetId,
        annotatorId: selectedAnnotatorId
      });

      if (res.isSuccess) {
        if (res.data === 0) {
          alert(res.message || "No new data items to assign.");
        } else {
          alert(`${res.data} tasks created successfully!`);
          navigate(`/manager/projects/${selectedProjectId}`);
        }
      } else {
        alert(res.message || "Error creating tasks");
      }
    } catch (err) {
      alert(err instanceof Error ? err.message : "Error creating tasks");
    } finally {
      setSubmitting(false);
    }
  };

  const filteredAnnotators = annotators.filter(a =>
    a.userEmail?.toLowerCase().includes(searchQuery.toLowerCase()) ||
    a.userId?.toLowerCase().includes(searchQuery.toLowerCase())
  );

  if (loading) {
    return (
      <DashboardLayout>
        <div className="h-full flex flex-col items-center justify-center text-gray-500 gap-3">
          <Loader2 className="h-10 w-10 animate-spin text-blue-600" />
          <p>Loading data...</p>
        </div>
      </DashboardLayout>
    );
  }

  return (
    <DashboardLayout>
      <div className="max-w-4xl mx-auto space-y-8 pb-12">
        
        {/* Header */}
        <div className="flex items-center gap-4">
          <Button variant="ghost" onClick={() => navigate(-1)}>
            <ArrowLeft className="h-6 w-6" />
          </Button>
          <div>
            <h1 className="text-3xl font-bold">Create Task</h1>
            <p className="text-gray-500">Assign data to annotator</p>
          </div>
        </div>

        <form onSubmit={handleSubmit}>
          <Card className="p-8 space-y-8">

            {/* Project + Dataset */}
            <div className="grid grid-cols-2 gap-6">
              <div>
                <Label>Project</Label>
                <select
                  className="w-full h-11 border rounded"
                  value={selectedProjectId}
                  onChange={(e) => setSelectedProjectId(e.target.value)}
                >
                  <option value="">Select project</option>
                  {projects.map(p => (
                    <option key={p.id} value={p.id}>{p.name}</option>
                  ))}
                </select>
              </div>

              <div>
                <Label>Dataset</Label>
                <select
                  className="w-full h-11 border rounded"
                  value={selectedDatasetId}
                  onChange={(e) => setSelectedDatasetId(e.target.value)}
                >
                  <option value="">Select dataset</option>
                  {datasets.map(d => (
                    <option key={d.id} value={d.id}>
                      {d.name} ({d.totalItems ?? 0} items)
                    </option>
                  ))}
                </select>
              </div>
            </div>

            {/* Annotator */}
            <div>
              <Label>Select Annotator</Label>

              <Input
                placeholder="Search..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
              />

              <div className="mt-3 max-h-60 overflow-y-auto space-y-2">
                {loadingAnnotators ? (
                  <div className="flex justify-center py-4">
                    <Loader2 className="animate-spin h-5 w-5 text-blue-600" />
                  </div>
                ) : filteredAnnotators.map(user => (
                  <div
                    key={user.userId}
                    className={`p-3 border rounded cursor-pointer flex justify-between items-center ${
                      selectedAnnotatorId === user.userId ? "bg-blue-100 border-blue-300" : "hover:bg-gray-50"
                    }`}
                    onClick={() => setSelectedAnnotatorId(user.userId)}
                  >
                    <span>{user.userEmail || "Unknown"}</span>
                    {selectedAnnotatorId === user.userId && <CheckCircle size={16} className="text-blue-600" />}
                  </div>
                ))}
                {!loadingAnnotators && filteredAnnotators.length === 0 && (
                  <p className="text-center py-4 text-gray-400 text-sm">
                    {selectedProjectId ? "No annotators found in this project." : "Please select a project first."}
                  </p>
                )}
              </div>
            </div>

            {/* Submit */}
            <div className="flex justify-end gap-4">
              <Button type="button" variant="ghost" onClick={() => navigate(-1)}>
                Cancel
              </Button>
              <Button type="submit" disabled={submitting}>
                {submitting ? <Loader2 className="animate-spin h-4 w-4 mr-2" /> : <PlusCircle className="h-4 w-4 mr-2" />}
                Create Task
              </Button>
            </div>

          </Card>
        </form>
      </div>
    </DashboardLayout>
  );
};

export default ManagerCreateTaskPage;