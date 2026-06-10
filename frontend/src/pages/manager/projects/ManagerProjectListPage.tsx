import React, { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import DashboardLayout from "../../../layouts/DashboardLayout";
import { Card } from "../../../components/ui/Card";
import { Button } from "../../../components/ui/Button";
import { Badge } from "../../../components/ui/Badge";
import { managerService } from "../../../services/managerService";
import type { ProjectResponse } from "../../../types/manager";
import { Plus, Folder, Calendar, Loader2, Archive } from "lucide-react";

const ManagerProjectListPage: React.FC = () => {
  const [projects, setProjects] = useState<ProjectResponse[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchProjects();
  }, []);

  const fetchProjects = async () => {
    setLoading(true);
    try {
      const res = await managerService.getProjects();
      if (res.isSuccess && res.data) {
        setProjects(res.data);
      } else {
        setProjects([]);
        alert(res.message || "Failed to load projects");
      }
    } catch (err) {
      alert(err instanceof Error ? err.message : "Error fetching projects");
      setProjects([]);
    } finally {
      setLoading(false);
    }
  };

  const handleArchive = async (id: string) => {
    if (!confirm("Are you sure you want to archive this project?")) return;

    try {
      const res = await managerService.archiveProject(id);
      if (res.isSuccess) {
        alert("Project archived successfully.");
        fetchProjects();
      } else {
        alert(res.message || "Error archiving project.");
      }
    } catch (err) {
      alert(err instanceof Error ? err.message : "Error archiving project");
    }
  };

  return (
    <DashboardLayout>
      <div className="space-y-6 max-w-6xl mx-auto">
        
        {/* Header */}
        <div className="flex justify-between items-center">
          <div>
            <h1 className="text-3xl font-bold text-gray-900">Project Management</h1>
            <p className="text-gray-500">View and manage data labeling projects</p>
          </div>
          <Link to="/manager/projects/create">
            <Button className="bg-blue-600 hover:bg-blue-700">
              <Plus className="h-4 w-4 mr-2" />
              Create Project
            </Button>
          </Link>
        </div>

        {/* Loading */}
        {loading ? (
          <div className="py-20 flex flex-col items-center justify-center text-gray-500 gap-3">
            <Loader2 className="h-8 w-8 animate-spin text-blue-600" />
            <p>Loading projects...</p>
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">

            {projects.map((project) => (
              <Card 
                key={project.id} 
                className="group hover:shadow-lg transition-all border-t-4 border-t-blue-600 flex flex-col"
              >
                <div className="p-6 space-y-4 flex-1">

                  {/* Icon + Status */}
                  <div className="flex justify-between items-start">
                    <div className="p-2 bg-blue-50 text-blue-600 rounded-lg">
                      <Folder className="h-6 w-6" />
                    </div>
                    <Badge variant={project.status === 0 ? "success" : "secondary"}>
                      {project.status === 0 ? "Active" : "Archived"}
                    </Badge>
                  </div>

                  {/* Info */}
                  <div>
                    <h3 className="text-xl font-bold text-gray-900 group-hover:text-blue-600 transition-colors">
                      {project.name}
                    </h3>
                    <p className="text-sm text-gray-500 line-clamp-2 mt-1 h-10">
                      {project.guideline || "No detailed guideline provided."}
                    </p>
                  </div>

                  {/* Date */}
                  <div className="pt-4 border-t flex justify-between items-center text-sm text-gray-500">
                    <div className="flex items-center gap-1">
                      <Calendar className="h-4 w-4" />
                      Created: {new Date(project.createdAt).toLocaleDateString("en-US")}
                    </div>
                  </div>
                </div>

                {/* Actions */}
                <div className="p-4 bg-gray-50 border-t grid grid-cols-2 gap-3">
                  <Link to={`/manager/projects/${project.id}`} className="w-full">
                    <Button variant="outline" className="w-full text-xs">
                      Details
                    </Button>
                  </Link>

                  <Button
                    variant="ghost"
                    className="text-gray-400 hover:text-red-500 text-xs"
                    onClick={() => handleArchive(project.id)}
                    disabled={project.status !== 0}
                  >
                    <Archive className="h-4 w-4 mr-1" />
                    Archive
                  </Button>
                </div>
              </Card>
            ))}

            {/* Empty state */}
            {projects.length === 0 && (
              <div className="col-span-full py-20 text-center bg-white rounded-xl border-2 border-dashed border-gray-200">
                <Folder className="h-12 w-12 text-gray-300 mx-auto mb-3" />
                <p className="text-gray-500">
                  No projects yet. Create your first project!
                </p>
              </div>
            )}

          </div>
        )}
      </div>
    </DashboardLayout>
  );
};

export default ManagerProjectListPage;