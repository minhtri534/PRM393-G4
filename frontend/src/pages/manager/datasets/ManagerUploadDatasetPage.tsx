import React, { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { ArrowLeft, UploadCloud } from "lucide-react";
import DashboardLayout from "../../../layouts/DashboardLayout";
import { Card } from "../../../components/ui/Card";
import { Label } from "../../../components/ui/Label";
import { Input } from "../../../components/ui/Input";
import { Button } from "../../../components/ui/Button";
import { managerService } from "../../../services/managerService";

const ManagerUploadDatasetPage: React.FC = () => {
  const [files, setFiles] = useState<File[]>([]);
  const [name, setName] = useState("");
  const [projectId, setProjectId] = useState("");
  const [projects, setProjects] = useState<any[]>([]);

  useEffect(() => {
    const fetchProjects = async () => {
      const res = await managerService.getProjects();
      if (res.isSuccess) setProjects(res.data);
    };
    fetchProjects();
  }, []);

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files) {
      setFiles(Array.from(e.target.files));
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!name || !projectId) {
      alert("Please fill all required fields.");
      return;
    }

    if (files.length === 0) {
      alert("Please select files to upload.");
      return;
    }

    try {
      // Step 1: Create dataset
      const dsRes = await managerService.createDataset({
        name,
        projectId
      });

      if (!dsRes.isSuccess) {
        alert("Failed to create dataset");
        return;
      }

      const datasetId = dsRes.data.id;

      // Step 2: Upload files
      const uploadRes = await managerService.uploadDatasetFiles(datasetId, files);

      if (!uploadRes.isSuccess) {
        alert(uploadRes.message || uploadRes.errors?.[0] || "Failed to upload files");
        return;
      }

      alert("Upload successful!");
      window.location.href = "/manager/datasets";
    } catch (err: any) {
      alert(err.response?.data?.message || err.response?.data?.errors?.[0] || "Something went wrong.");
    }
  };

  return (
    <DashboardLayout>
      <div className="max-w-3xl mx-auto space-y-8">

        <div className="flex items-center gap-4">
          <Link to="/manager/datasets" className="p-2 hover:bg-gray-100 rounded-full">
            <ArrowLeft className="h-6 w-6 text-gray-600" />
          </Link>
          <div>
            <h1 className="text-3xl font-bold">Upload Dataset</h1>
            <p className="text-gray-500">Add new dataset to your project.</p>
          </div>
        </div>

        <form onSubmit={handleSubmit}>
          <Card className="p-8 space-y-8">

            {/* Dataset Info */}
            <div className="space-y-6">

              <div>
                <Label>Dataset Name</Label>
                <Input
                  value={name}
                  onChange={(e) => setName(e.target.value)}
                  placeholder="Example: Chest X-ray Dataset"
                  required
                />
              </div>

              <div>
                <Label>Project</Label>
                <select
                  className="w-full border rounded-md p-2"
                  value={projectId}
                  onChange={(e) => setProjectId(e.target.value)}
                  required
                >
                  <option value="">Select project</option>
                  {projects.map(p => (
                    <option key={p.id} value={p.id}>{p.name}</option>
                  ))}
                </select>
              </div>

            </div>

            {/* Upload */}
            <div className="border-t pt-8">
              <Label className="text-lg font-semibold flex items-center gap-2">
                <UploadCloud className="h-5 w-5 text-blue-500" />
                Upload Files
              </Label>

              <div className="mt-4 border-2 border-dashed rounded-lg p-10 text-center">
                <input type="file" multiple onChange={handleFileChange} />
              </div>

              {files.length > 0 && (
                <div className="mt-4">
                  <p className="font-medium">Selected Files:</p>
                  {files.map((file, i) => (
                    <div key={i} className="text-sm text-gray-600">
                      {file.name}
                    </div>
                  ))}
                </div>
              )}
            </div>

            <div className="flex justify-end gap-4">
              <Link to="/manager/datasets">
                <Button type="button" variant="ghost">Cancel</Button>
              </Link>
              <Button type="submit">
                <UploadCloud className="h-4 w-4 mr-2" />
                Upload
              </Button>
            </div>

          </Card>
        </form>
      </div>
    </DashboardLayout>
  );
};

export default ManagerUploadDatasetPage;