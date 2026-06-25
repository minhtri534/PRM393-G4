import React, { useEffect, useState } from "react";
import { Link, useParams } from "react-router-dom";
import { 
  ArrowLeft, Edit, Trash2, Database, Clock, BarChart, PlusCircle, 
  Upload, FileIcon, Loader2, Save, X, History as HistoryIcon
} from "lucide-react";
import DashboardLayout from "../../../layouts/DashboardLayout";
import { Card } from "../../../components/ui/Card";
import { Button } from "../../../components/ui/Button";
import { Input } from "../../../components/ui/Input";
import { managerService } from "../../../services/managerService";
import type { DatasetResponse, DatasetVersionResponse } from "../../../types/manager";

const ManagerDatasetDetailPage: React.FC = () => {
  const { datasetId } = useParams<{ datasetId: string }>();

  const [dataset, setDataset] = useState<DatasetResponse | null>(null);
  const [versions, setVersions] = useState<DatasetVersionResponse[]>([]);
  const [loading, setLoading] = useState(true);
  const [isActionLoading, setIsActionLoading] = useState(false);

  const [isEditingMetadata, setIsEditingMetadata] = useState(false);
  const [editedName, setEditedName] = useState("");

  const [selectedFiles, setSelectedFiles] = useState<File[]>([]);

  useEffect(() => {
    if (!datasetId) return;
    fetchData();
  }, [datasetId]);

  const fetchData = async () => {
    if (!datasetId) return;
    setLoading(true);
    const datasetRes = await managerService.getDatasetById(datasetId);
    const versionRes = await managerService.getDatasetVersions(datasetId);

    if (datasetRes.isSuccess) {
      setDataset(datasetRes.data);
      setEditedName(datasetRes.data.name);
    }
    if (versionRes.isSuccess) setVersions(versionRes.data);
    setLoading(false);
  };

  const handleUpdateMetadata = async () => {
    if (!datasetId) return;
    setIsActionLoading(true);
    const res = await managerService.updateDataset(datasetId, { name: editedName });
    if (res.isSuccess) {
      setIsEditingMetadata(false);
      fetchData();
    }
    setIsActionLoading(false);
  };

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files) {
      setSelectedFiles(Array.from(e.target.files));
    }
  };

  const handleUploadFiles = async () => {
    if (!datasetId || selectedFiles.length === 0) return;
    setIsActionLoading(true);
    const res = await managerService.uploadDatasetFiles(datasetId, selectedFiles);
    if (res.isSuccess) {
      alert("Files uploaded successfully!");
      setSelectedFiles([]);
      fetchData();
    } else {
      alert(res.message || res.errors?.[0] || "Failed to upload files");
    }
    setIsActionLoading(false);
  };

  const handleRestore = async (versionId: string) => {
    if (!confirm("Are you sure you want to restore this version?")) return;
    const res = await managerService.restoreDatasetVersion(versionId);
    if (res.isSuccess) {
      alert("Version restored successfully");
      fetchData();
    } else {
      alert(res.message || "Failed to restore version");
    }
  };

  const handleDelete = async () => {
    if (!datasetId) return;
    if (!confirm("Are you sure you want to delete this dataset?")) return;

    await managerService.deleteDataset(datasetId);
    window.location.href = "/manager/projects";
  };

  const handleCreateVersion = async () => {
    if (!datasetId) return;

    const versionName = prompt("Enter version name (e.g. v1.0.0, snapshot-2024-03-26):");
    if (!versionName) return;

    const res = await managerService.createDatasetVersion({
      datasetId,
      versionName: versionName.trim()
    });

    if (res.isSuccess) {
      fetchData();
    } else {
      alert(res.message || "Failed to create version");
    }
  };

  if (loading && !dataset) return (
    <DashboardLayout>
      <div className="h-full flex flex-col items-center justify-center text-gray-500 gap-3">
        <Loader2 className="h-10 w-10 animate-spin text-blue-600" />
        <p>Loading dataset details...</p>
      </div>
    </DashboardLayout>
  );

  if (!dataset) return null;

  return (
    <DashboardLayout>
      <div className="max-w-6xl mx-auto space-y-8 pb-12">

        {/* Header */}
        <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
          <div className="flex items-center gap-4">
            <Link to={`/manager/projects/${dataset.projectId}`} className="p-2 hover:bg-gray-100 rounded-full transition-colors">
              <ArrowLeft className="h-6 w-6 text-gray-600" />
            </Link>
            <div>
              {isEditingMetadata ? (
                <div className="flex gap-2">
                  <Input 
                    value={editedName} 
                    onChange={e => setEditedName(e.target.value)} 
                    className="text-2xl font-bold h-auto py-1"
                  />
                  <Button size="sm" onClick={handleUpdateMetadata} disabled={isActionLoading}>
                    {isActionLoading ? <Loader2 className="h-4 w-4 animate-spin" /> : <Save className="h-4 w-4" />}
                  </Button>
                  <Button size="sm" variant="ghost" onClick={() => setIsEditingMetadata(false)}>
                    <X className="h-4 w-4" />
                  </Button>
                </div>
              ) : (
                <div className="flex items-center gap-3">
                  <h1 className="text-3xl font-bold text-gray-900">{dataset.name}</h1>
                  <Button variant="ghost" size="icon" onClick={() => setIsEditingMetadata(true)}>
                    <Edit className="h-4 w-4 text-gray-400" />
                  </Button>
                </div>
              )}
              <p className="text-sm text-gray-500 font-mono mt-1">ID: {datasetId}</p>
            </div>
          </div>

          <div className="flex gap-3 w-full sm:w-auto">
            <Button
              variant="outline"
              className="text-red-600 border-red-100 hover:bg-red-50 flex-1 sm:flex-none"
              onClick={handleDelete}
            >
              <Trash2 className="h-4 w-4 mr-2" />
              Delete Dataset
            </Button>
          </div>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          
          <div className="lg:col-span-2 space-y-8">
            {/* Dataset Info */}
            <Card className="p-6">
              <h2 className="text-lg font-bold mb-4 flex items-center gap-2">
                <Database className="h-5 w-5 text-blue-500" />
                Information
              </h2>

              <div className="grid grid-cols-1 sm:grid-cols-3 gap-6 text-sm">
                <div className="p-4 bg-gray-50 rounded-xl">
                  <p className="text-gray-500 text-xs mb-1 uppercase font-bold tracking-wider">Items</p>
                  <p className="text-xl font-bold text-gray-900">{dataset.totalItems || 0}</p>
                </div>
                <div className="p-4 bg-gray-50 rounded-xl">
                  <p className="text-gray-500 text-xs mb-1 uppercase font-bold tracking-wider">Created</p>
                  <p className="font-medium text-gray-900">{new Date(dataset.createdAt).toLocaleDateString()}</p>
                </div>
                <div className="p-4 bg-gray-50 rounded-xl">
                  <p className="text-gray-500 text-xs mb-1 uppercase font-bold tracking-wider">Updated</p>
                  <p className="font-medium text-gray-900">{new Date(dataset.updatedAt).toLocaleDateString()}</p>
                </div>
              </div>
            </Card>

            {/* File Upload Section */}
            <Card className="p-6">
              <h3 className="text-lg font-bold mb-4 flex items-center gap-2">
                <Upload className="h-5 w-5 text-green-500" />
                Upload Data Items
              </h3>
              
              <div className="border-2 border-dashed border-gray-200 rounded-2xl p-10 text-center hover:border-blue-300 transition-all bg-gray-50/50">
                <input 
                  type="file" 
                  multiple 
                  id="file-upload" 
                  className="hidden" 
                  onChange={handleFileChange}
                />
                <label htmlFor="file-upload" className="cursor-pointer">
                  <div className="bg-white h-12 w-12 rounded-full shadow-sm flex items-center justify-center mx-auto mb-4 border border-gray-100">
                    <PlusCircle className="h-6 w-6 text-blue-600" />
                  </div>
                  <p className="text-gray-700 font-bold">Click to upload files</p>
                  <p className="text-gray-400 text-xs mt-1">Images, videos, or documents</p>
                </label>
              </div>

              {selectedFiles.length > 0 && (
                <div className="mt-6 space-y-4">
                  <div className="flex justify-between items-center">
                    <p className="text-sm font-bold">{selectedFiles.length} files selected</p>
                    <Button size="sm" onClick={handleUploadFiles} disabled={isActionLoading}>
                      {isActionLoading ? <Loader2 className="h-4 w-4 animate-spin mr-2" /> : <Upload className="h-4 w-4 mr-2" />}
                      Start Upload
                    </Button>
                  </div>
                  <div className="max-h-[200px] overflow-y-auto space-y-2 pr-2">
                    {selectedFiles.map((f, i) => (
                      <div key={i} className="flex items-center gap-3 p-2 bg-gray-50 rounded-lg border border-gray-100 text-xs">
                        <FileIcon className="h-4 w-4 text-gray-400" />
                        <span className="truncate flex-1">{f.name}</span>
                        <span className="text-gray-400">{(f.size / 1024).toFixed(1)} KB</span>
                      </div>
                    ))}
                  </div>
                </div>
              )}
            </Card>
          </div>

          {/* Versions Sidebar */}
          <div className="space-y-6">
            <Card className="p-6">
              <h3 className="text-lg font-bold mb-4 flex items-center gap-2">
                <HistoryIcon className="h-5 w-5 text-purple-500" />
                Versions
              </h3>

              <div className="space-y-3 max-h-[400px] overflow-y-auto pr-2">
                {versions.map((v) => (
                  <div key={v.id} className="p-3 bg-gray-50 rounded-xl border border-gray-100 flex justify-between items-center group hover:border-blue-200 transition-all">
                    <div>
                      <div className="font-bold text-gray-900">Version {v.versionName}</div>
                      <div className="text-[10px] text-gray-400">
                        {new Date(v.createdAt).toLocaleString()}
                      </div>
                    </div>
                    <Button variant="ghost" size="sm" onClick={() => handleRestore(v.id)} className="opacity-0 group-hover:opacity-100">
                      Restore
                    </Button>
                  </div>
                ))}
                {versions.length === 0 && <p className="text-gray-400 text-center py-8 text-sm italic">No versions created yet.</p>}
              </div>

              <Button fullWidth variant="outline" className="mt-6 border-blue-100 text-blue-600 hover:bg-blue-50" onClick={handleCreateVersion}>
                <PlusCircle className="h-4 w-4 mr-2" />
                Create Snapshot
              </Button>
            </Card>

            <Card className="p-6 bg-gray-900 text-white border-none shadow-xl">
              <h3 className="font-bold mb-2">Dataset Best Practices</h3>
              <p className="text-[11px] text-gray-400 leading-relaxed">
                Organize your datasets by versioning snapshots. This allows you to track changes and easily roll back to previous states if data quality issues are detected.
              </p>
            </Card>
          </div>

        </div>

      </div>
    </DashboardLayout>
  );
};

export default ManagerDatasetDetailPage;