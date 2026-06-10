import React, { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { Database, Search, UploadCloud, Loader2, FolderOpen } from "lucide-react";
import DashboardLayout from "../../../layouts/DashboardLayout";
import { Card } from "../../../components/ui/Card";
import { Button } from "../../../components/ui/Button";
import { Input } from "../../../components/ui/Input";
import { Badge } from "../../../components/ui/Badge";
import { managerService } from "../../../services/managerService";
import type { DatasetResponse } from "../../../types/manager";

const ManagerDatasetListPage: React.FC = () => {
  const [datasets, setDatasets] = useState<DatasetResponse[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState("");

  useEffect(() => {
    fetchData();
  }, []);

  const fetchData = async () => {
    setLoading(true);
    try {
      const projRes = await managerService.getProjects();
      if (projRes.isSuccess && projRes.data) {
        const allDatasets: DatasetResponse[] = [];
        const dsPromises = projRes.data.map(p => managerService.getDatasets(p.id));
        const dsResults = await Promise.all(dsPromises);

        dsResults.forEach(res => {
          if (res.isSuccess && res.data) {
            allDatasets.push(...res.data);
          }
        });

        setDatasets(allDatasets);
      }
    } finally {
      setLoading(false);
    }
  };

  const filteredDatasets = datasets.filter(ds =>
    ds.name.toLowerCase().includes(searchQuery.toLowerCase())
  );

  return (
    <DashboardLayout>
      <div className="space-y-8 max-w-7xl mx-auto">

        <div className="flex flex-col md:flex-row justify-between gap-4">
          <div>
            <h1 className="text-3xl font-bold text-gray-900">Dataset Management</h1>
            <p className="text-gray-500 mt-1">All datasets from your projects.</p>
          </div>

          <Link to="/manager/datasets/upload">
            <Button className="bg-blue-600 hover:bg-blue-700">
              <UploadCloud className="h-4 w-4 mr-2" />
              Upload Dataset
            </Button>
          </Link>
        </div>

        <Card className="p-6 shadow-sm overflow-hidden">

          <div className="flex items-center justify-between mb-8">
            <div className="w-full max-w-md relative">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 h-5 w-5" />
              <Input
                className="pl-10"
                placeholder="Search datasets..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
              />
            </div>
          </div>

          {loading ? (
            <div className="py-24 flex flex-col items-center text-gray-400 gap-3">
              <Loader2 className="animate-spin h-10 w-10 text-blue-600" />
              <p>Loading datasets...</p>
            </div>
          ) : (
            <div className="overflow-x-auto">
              <table className="w-full text-sm text-left">
                <thead className="bg-gray-50 border-b">
                  <tr>
                    <th className="px-6 py-4 text-xs font-bold text-gray-600 uppercase">Dataset</th>
                    <th className="px-6 py-4 text-xs font-bold text-gray-600 uppercase">Project ID</th>
                    <th className="px-6 py-4 text-xs font-bold text-gray-600 uppercase">Created At</th>
                    <th className="px-6 py-4 text-xs font-bold text-gray-600 uppercase text-right">Action</th>
                  </tr>
                </thead>

                <tbody className="divide-y">
                  {filteredDatasets.map((dataset) => (
                    <tr key={dataset.id} className="hover:bg-blue-50/20">
                      <td className="px-6 py-4">
                        <div className="flex items-center">
                          <div className="h-10 w-10 bg-blue-50 rounded-xl flex items-center justify-center text-blue-600">
                            <Database size={20} />
                          </div>
                          <div className="ml-4">
                            <div className="font-bold">{dataset.name}</div>
                            <div className="text-[10px] text-gray-400 font-mono">
                              ID: {dataset.id.slice(-8)}
                            </div>
                          </div>
                        </div>
                      </td>

                      <td className="px-6 py-4">
                        <Badge variant="secondary" className="font-mono text-[10px]">
                          {dataset.projectId.slice(-8)}
                        </Badge>
                      </td>

                      <td className="px-6 py-4 text-gray-500">
                        {new Date(dataset.createdAt).toLocaleDateString('en-US')}
                      </td>

                      <td className="px-6 py-4 text-right">
                        <Link to={`/manager/datasets/${dataset.id}`}>
                          <Button variant="ghost" size="sm" className="text-blue-600 hover:bg-blue-50">
                            View
                          </Button>
                        </Link>
                      </td>
                    </tr>
                  ))}

                  {filteredDatasets.length === 0 && (
                    <tr>
                      <td colSpan={4} className="py-20 text-center text-gray-400">
                        <FolderOpen className="h-12 w-12 mx-auto mb-3 text-gray-200" />
                        No datasets found.
                      </td>
                    </tr>
                  )}
                </tbody>

              </table>
            </div>
          )}
        </Card>
      </div>
    </DashboardLayout>
  );
};

export default ManagerDatasetListPage;