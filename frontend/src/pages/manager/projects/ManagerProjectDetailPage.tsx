import React, { useEffect, useState } from "react";
import { Link, useParams, useNavigate } from "react-router-dom";
import { 
  ArrowLeft, Archive, Calendar, FileText, Clock, Loader2, Plus, Tag, List,
  Users, BarChart3, Download, History, Settings, CheckCircle2, AlertCircle, Play, Pause, XCircle, Info
} from "lucide-react";
import DashboardLayout from "../../../layouts/DashboardLayout";
import { Card } from "../../../components/ui/Card";
import { Button } from "../../../components/ui/Button";
import { Badge } from "../../../components/ui/Badge";
import { Input } from "../../../components/ui/Input";
import { managerService } from "../../../services/managerService";
import { userService } from "../../../services/userService";
import type { UserSummaryResponse } from "../../../services/userService";
import type { 
  ProjectResponse, 
  DatasetResponse, 
  LabelResponse, 
  TaskResponse,
  TaskProgressResponse,
  QualityReportResponse,
  ExportResponse,
  CreateExportRequest,
  ActivityLogResponse,
  UserProjectRoleResponse,
  AnnotatorPerformanceResponse
} from "../../../types/manager";

type TabType = "overview" | "data" | "tasks" | "monitoring" | "exports" | "settings";

const YOLO_CLASS_OPTIONS = [
  { id: 0, name: "person" },
  { id: 1, name: "bicycle" },
  { id: 2, name: "car" },
  { id: 3, name: "motorcycle" },
  { id: 5, name: "bus" },
  { id: 7, name: "truck" },
  { id: 15, name: "cat" },
  { id: 16, name: "dog" },
  { id: 24, name: "backpack" },
  { id: 26, name: "handbag" },
  { id: 27, name: "tie" },
  { id: 39, name: "bottle" },
  { id: 56, name: "chair" },
  { id: 57, name: "couch" },
  { id: 58, name: "potted plant" },
  { id: 59, name: "bed" },
  { id: 60, name: "dining table" },
  { id: 62, name: "tv" },
  { id: 63, name: "laptop" },
  { id: 67, name: "cell phone" },
] as const;

const ProjectDetailPage: React.FC = () => {
  const { projectId } = useParams<{ projectId: string }>();
  const navigate = useNavigate();

  const [activeTab, setActiveTab] = useState<TabType>("overview");
  const [project, setProject] = useState<ProjectResponse | null>(null);
  const [datasets, setDatasets] = useState<DatasetResponse[]>([]);
  const [labels, setLabels] = useState<LabelResponse[]>([]);
  const [taskProgress, setTaskProgress] = useState<TaskProgressResponse | null>(null);
  const [tasks, setTasks] = useState<TaskResponse[]>([]);
  const [qualityReport, setQualityReport] = useState<QualityReportResponse | null>(null);
  const [exports, setExports] = useState<ExportResponse[]>([]);
  const [validationResult, setValidationResult] = useState<any>(null);
  const [activityLogs, setActivityLogs] = useState<ActivityLogResponse[]>([]);
  const [projectRoles, setProjectRoles] = useState<UserProjectRoleResponse[]>([]);
  const [annotatorPerformance, setAnnotatorPerformance] = useState<AnnotatorPerformanceResponse[]>([]);
  const [loading, setLoading] = useState(true);

  // Assign Member states
  const [isAssigningMember, setIsAssigningMember] = useState(false);
  const [newMemberUserId, setNewMemberUserId] = useState("");
  const [newMemberRoleId, setNewMemberRoleId] = useState("");
  const [userSearchQuery, setUserSearchQuery] = useState("");
  const [searchResults, setSearchResults] = useState<UserSummaryResponse[]>([]);
  const [isSearchingUsers, setIsSearchingUsers] = useState(false);

  // Form states
  const [newDatasetName, setNewDatasetName] = useState("");
  const [newLabelName, setNewLabelName] = useState("");
  const [newLabelYoloClassId, setNewLabelYoloClassId] = useState<string>("");
  const [selectedYoloPreset, setSelectedYoloPreset] = useState<string>("");
  const [guidelineText, setGuidelineText] = useState("");

  const [isActionLoading, setIsActionLoading] = useState(false);

  useEffect(() => {
    if (projectId) fetchData();
  }, [projectId, activeTab]);

  const fetchData = async () => {
    if (!projectId) return;
    setLoading(true);
    try {
      const [projRes, dsRes, lblRes, rolesRes] = await Promise.all([
        managerService.getProjectById(projectId),
        managerService.getDatasets(projectId),
        managerService.getLabels(projectId),
        managerService.getProjectRoles(projectId)
      ]);

      if (projRes.isSuccess) {
        setProject(projRes.data);
        setGuidelineText(projRes.data.guideline || "");
      }
      if (dsRes.isSuccess) setDatasets(dsRes.data || []);
      if (lblRes.isSuccess) setLabels(lblRes.data || []);
      if (rolesRes.isSuccess) setProjectRoles(rolesRes.data || []);

      // Fetch tab-specific data
      if (activeTab === "tasks") {
        const [progressRes, tasksRes] = await Promise.all([
          managerService.getTaskProgress(projectId),
          managerService.getProjectTasks(projectId)
        ]);
        if (progressRes.isSuccess) setTaskProgress(progressRes.data);
        if (tasksRes.isSuccess) setTasks(tasksRes.data || []);
      } else if (activeTab === "monitoring") {
        const [reportRes, performanceRes] = await Promise.all([
          managerService.getQualityReport(projectId),
          managerService.getAnnotatorPerformance(projectId)
        ]);
        if (reportRes.isSuccess) setQualityReport(reportRes.data);
        if (performanceRes.isSuccess) setAnnotatorPerformance(performanceRes.data || []);
      } else if (activeTab === "exports") {
        const res = await managerService.getProjectExports(projectId);
        if (res.isSuccess) setExports(res.data || []);
      } else if (activeTab === "settings") {
        const logsRes = await managerService.getActivityLogs(projectId);
        if (logsRes.isSuccess) setActivityLogs(logsRes.data || []);
      }
    } finally {
      setLoading(false);
    }
  };

  const handleUpdateGuideline = async () => {
    if (!projectId) return;
    setIsActionLoading(true);
    const res = await managerService.updateGuideline(projectId, guidelineText);
    if (res.isSuccess) alert("Guideline updated!");
    setIsActionLoading(false);
  };

  const handleCreateDataset = async () => {
    if (!projectId || !newDatasetName) return;
    setIsActionLoading(true);
    const res = await managerService.createDataset({ projectId, name: newDatasetName });
    if (res.isSuccess) {
      setNewDatasetName("");
      fetchData();
    }
    setIsActionLoading(false);
  };

  const handleCreateLabel = async () => {
    if (!projectId || !newLabelName.trim()) return;

    const parsedYoloClassId = Number.parseInt(newLabelYoloClassId, 10);
    if (!Number.isInteger(parsedYoloClassId) || parsedYoloClassId < 0) {
      alert("Please enter a valid YOLO Class ID (>= 0).");
      return;
    }

    if (labels.some((label) => label.yoloClassId === parsedYoloClassId)) {
      alert(`YOLO Class ID ${parsedYoloClassId} is already used in this project.`);
      return;
    }

    setIsActionLoading(true);
    const res = await managerService.createLabel({ 
      projectId, 
      name: newLabelName.trim(), 
      yoloClassId: parsedYoloClassId,
    });
    if (res.isSuccess) {
      setNewLabelName("");
      setNewLabelYoloClassId("");
      setSelectedYoloPreset("");
      fetchData();
    }
    setIsActionLoading(false);
  };

  const handleCreateExport = async (format: string) => {
    if (!projectId) {
      alert("Project ID is missing");
      return;
    }
    
    setIsActionLoading(true);
    try {
      const isYolo = format.toUpperCase() === "YOLO";
      const ext = isYolo ? "zip" : "json";
      
      const payload: CreateExportRequest = { 
        projectId: projectId, 
        format: format,
        exportPath: `exports/${projectId}/export_${new Date().getTime()}.${ext}`,
        labelFormat: format,
        includeFields: ["tasks", "annotations", "reviews", "labels"],
        filters: {}
      };

      console.log("Sending export request:", payload);
      
      const res = await managerService.createExport(payload);
      
      if (res.isSuccess) {
        alert("Export job started.");
        fetchData();
      } else {
        alert(res.message || "Export failed");
      }
    } catch (err: any) {
      console.error("Export error:", err);
      let errorMsg = err.message || "An unexpected error occurred";
      
      // Extract detailed validation errors if available
      if (err.response?.data?.errors) {
        const details = Object.entries(err.response.data.errors)
          .map(([field, msgs]) => `${field}: ${(msgs as string[]).join(', ')}`)
          .join('\n');
        errorMsg = `${err.response.data.message || 'Validation Error'}\n${details}`;
      } else if (err.response?.data?.message) {
        errorMsg = err.response.data.message;
      }
      
      alert(`Export failed: ${errorMsg}`);
    } finally {
      setIsActionLoading(false);
    }
  };

  const handleValidate = async () => {
    if (!projectId) return;
    setIsActionLoading(true);
    const res = await managerService.validateApprovedData(projectId);
    if (res.isSuccess) {
      setValidationResult(res.data);
    }
    setIsActionLoading(false);
  };

  const handleArchive = async () => {
    if (!projectId || !confirm("Are you sure you want to archive this project?")) return;
    const res = await managerService.archiveProject(projectId);
    if (res.isSuccess) {
      alert("Project archived.");
      navigate("/manager/projects");
    }
  };

  const handleOpenAssignMember = async () => {
    setNewMemberUserId("");
    setNewMemberRoleId("000000000000000000000003"); // Annotator
    setUserSearchQuery("");
    setSearchResults([]);
    setIsAssigningMember(true);
  };

  const handleSearchUsers = async (q: string) => {
    setUserSearchQuery(q);
    if (q.length < 2) {
      setSearchResults([]);
      return;
    }
    setIsSearchingUsers(true);
    try {
      const res = await userService.search(q);
      if (res.isSuccess) {
        setSearchResults(res.data);
      }
    } finally {
      setIsSearchingUsers(false);
    }
  };

  const handleSelectUser = (user: UserSummaryResponse) => {
    setNewMemberUserId(user.id);
    setUserSearchQuery(user.email);
    setSearchResults([]);
  };

  const handleAssignMember = async () => {
    if (!projectId || !newMemberUserId || !newMemberRoleId) {
      alert("Please select a user and a role.");
      return;
    }
    setIsActionLoading(true);
    try {
      const res = await managerService.assignProjectRole({
        projectId,
        userId: newMemberUserId,
        roleId: newMemberRoleId
      });
      if (res.isSuccess) {
        setIsAssigningMember(false);
        setNewMemberUserId("");
        fetchData();
      } else {
        alert(res.message || "Error assigning member.");
      }
    } catch (err) {
      alert(err instanceof Error ? err.message : "An unexpected error occurred.");
    } finally {
      setIsActionLoading(false);
    }
  };

  const handleAssignTask = async (taskId: string, annotatorId: string) => {
    if (!annotatorId) return;
    setIsActionLoading(true);
    const res = await managerService.assignTask(taskId, { annotatorId });
    if (res.isSuccess) {
      fetchData();
    } else {
      alert(res.message || "Error assigning task.");
    }
    setIsActionLoading(false);
  };

  const getStatusText = (status: number) => {
    switch (status) {
      case 0: return "Planned";
      case 1: return "Active";
      case 2: return "Paused";
      case 3: return "Completed";
      default: return "Unknown";
    }
  };

  const suggestedYoloByName = YOLO_CLASS_OPTIONS.find(
    (option) => option.name.toLowerCase() === newLabelName.trim().toLowerCase()
  );

  const isDuplicateYoloId = (() => {
    const value = Number.parseInt(newLabelYoloClassId, 10);
    if (!Number.isInteger(value) || value < 0) {
      return false;
    }
    return labels.some((label) => label.yoloClassId === value);
  })();

  if (loading && !project) {
    return (
      <DashboardLayout>
        <div className="h-full flex flex-col items-center justify-center text-gray-500 gap-3">
          <Loader2 className="h-10 w-10 animate-spin text-blue-600" />
          <p>Loading project details...</p>
        </div>
      </DashboardLayout>
    );
  }

  if (!project) return null;

  return (
    <DashboardLayout>
      <div className="max-w-7xl mx-auto space-y-6 pb-12 px-4 sm:px-6">

        {/* Header Section */}
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 bg-white p-6 rounded-2xl shadow-sm border border-gray-100">
          <div className="flex items-center gap-4">
            <Link to="/manager/projects" className="p-2 hover:bg-gray-100 rounded-full transition-colors">
              <ArrowLeft className="h-6 w-6 text-gray-600" />
            </Link>
            <div>
              <div className="flex gap-3 items-center flex-wrap">
                <h1 className="text-2xl sm:text-3xl font-bold text-gray-900">{project.name}</h1>
                <Badge variant={project.status === 1 ? "primary" : "secondary"}>
                  {getStatusText(project.status)}
                </Badge>
              </div>
              <p className="text-sm text-gray-500 font-mono mt-1">ID: {project.id}</p>
            </div>
          </div>

          <div className="flex gap-2">
            <Button variant="outline" size="sm" onClick={handleArchive} className="text-red-600 border-red-100 hover:bg-red-50">
              <Archive className="h-4 w-4 mr-2"/> Archive
            </Button>
          </div>
        </div>

        {/* Tabs Navigation */}
        <div className="flex flex-wrap gap-2 border-b border-gray-200">
          {[
            { id: "overview", label: "Overview", icon: FileText },
            { id: "data", label: "Data & Labels", icon: Tag },
            { id: "tasks", label: "Tasks", icon: CheckCircle2 },
            { id: "monitoring", label: "Monitoring", icon: BarChart3 },
            { id: "exports", label: "Exports", icon: Download },
            { id: "settings", label: "Settings", icon: Settings },
          ].map(tab => (
            <button
              key={tab.id}
              onClick={() => setActiveTab(tab.id as TabType)}
              className={`flex items-center gap-2 px-4 py-3 text-sm font-medium transition-colors border-b-2 -mb-px ${
                activeTab === tab.id 
                  ? "border-blue-600 text-blue-600" 
                  : "border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300"
              }`}
            >
              <tab.icon className="h-4 w-4" />
              {tab.label}
            </button>
          ))}
        </div>

        {/* Tab Content */}
        <div className="mt-6">
          
          {/* OVERVIEW TAB */}
          {activeTab === "overview" && (
            <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
              <div className="lg:col-span-2 space-y-6">
                <Card className="p-6">
                  <h3 className="text-lg font-bold mb-4 flex items-center gap-2">
                    <FileText className="h-5 w-5 text-blue-500" />
                    Guideline
                  </h3>
                  <textarea 
                    className="w-full min-h-[200px] p-4 bg-gray-50 rounded-xl border border-gray-200 focus:ring-2 focus:ring-blue-500 outline-none transition-all text-sm"
                    value={guidelineText}
                    onChange={e => setGuidelineText(e.target.value)}
                    placeholder="Enter project guidelines..."
                  />
                  <div className="mt-4 flex justify-end">
                    <Button onClick={handleUpdateGuideline} disabled={isActionLoading}>
                      {isActionLoading ? <Loader2 className="animate-spin h-4 w-4 mr-2" /> : <Plus className="h-4 w-4 mr-2" />}
                      Update Guideline
                    </Button>
                  </div>
                </Card>

                <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 text-sm">
                  <Card className="p-4 bg-gray-50 flex items-center gap-3">
                    <Calendar className="h-5 w-5 text-gray-400" />
                    <div>
                      <p className="text-gray-500 text-xs">Created At</p>
                      <p className="font-medium">{new Date(project.createdAt).toLocaleString()}</p>
                    </div>
                  </Card>
                  <Card className="p-4 bg-gray-50 flex items-center gap-3">
                    <Clock className="h-5 w-5 text-gray-400" />
                    <div>
                      <p className="text-gray-500 text-xs">Last Updated</p>
                      <p className="font-medium">{new Date(project.updatedAt).toLocaleString()}</p>
                    </div>
                  </Card>
                </div>
              </div>

              <div className="space-y-6">
                <Card className="p-6">
                  <h3 className="text-lg font-bold mb-4 flex items-center gap-2">
                    <Users className="h-5 w-5 text-purple-500" />
                    Project Team
                  </h3>
                  <div className="space-y-3">
                    {projectRoles.map(role => (
                      <div key={role.userId} className="flex items-center justify-between p-2 hover:bg-gray-50 rounded-lg transition-colors">
                        <div className="flex items-center gap-3">
                          <div className="h-8 w-8 bg-blue-100 text-blue-700 rounded-full flex items-center justify-center text-xs font-bold">
                            {role.roleName?.[0]?.toUpperCase() || 'U'}
                          </div>
                          <span className="text-sm font-medium" title={role.userEmail}>{role.userEmail || "Unknown Member"}</span>
                        </div>
                        <Badge variant="secondary" className="text-[10px] uppercase">{role.roleName}</Badge>
                      </div>
                    ))}
                    {projectRoles.length === 0 && (
                      <p className="text-center py-4 text-gray-400 text-sm">No members assigned yet.</p>
                    )}

                    {isAssigningMember ? (
                      <div className="mt-4 p-4 bg-gray-50 rounded-xl border border-gray-200 space-y-3 relative">
                        <p className="text-xs font-bold text-gray-500 uppercase">Search User to Assign</p>
                        <div className="relative">
                          <Input 
                            placeholder="Type name or email..."
                            className="text-sm"
                            value={userSearchQuery}
                            onChange={e => handleSearchUsers(e.target.value)}
                          />
                          {isSearchingUsers && (
                            <div className="absolute right-3 top-2.5">
                              <Loader2 className="animate-spin h-4 w-4 text-blue-500" />
                            </div>
                          )}
                          {searchResults.length > 0 && (
                            <div className="absolute z-10 w-full mt-1 bg-white border border-gray-200 rounded-lg shadow-lg max-h-48 overflow-y-auto">
                              {searchResults.map(user => (
                                <button
                                  key={user.id}
                                  className="w-full text-left p-2 hover:bg-gray-50 border-b border-gray-100 last:border-0"
                                  onClick={() => handleSelectUser(user)}
                                >
                                  <p className="text-sm font-medium">{user.fullName}</p>
                                  <p className="text-[10px] text-gray-500">{user.email} • {user.roleName}</p>
                                </button>
                              ))}
                            </div>
                          )}
                        </div>
                        <select 
                          className="w-full p-2 text-sm bg-white border border-gray-200 rounded-lg outline-none focus:ring-2 focus:ring-blue-500"
                          value={newMemberRoleId}
                          onChange={e => setNewMemberRoleId(e.target.value)}
                        >
                          <option value="000000000000000000000003">Annotator</option>
                          <option value="000000000000000000000004">Reviewer</option>
                        </select>
                        <div className="flex gap-2">
                          <Button size="sm" fullWidth onClick={handleAssignMember} disabled={isActionLoading || !newMemberUserId}>
                            {isActionLoading ? <Loader2 className="animate-spin h-4 w-4" /> : "Assign"}
                          </Button>
                          <Button size="sm" variant="ghost" fullWidth onClick={() => setIsAssigningMember(false)}>
                            Cancel
                          </Button>
                        </div>
                      </div>
                    ) : (
                      <Button variant="outline" fullWidth size="sm" className="mt-4" onClick={handleOpenAssignMember} disabled={isActionLoading}>
                        {isActionLoading ? <Loader2 className="animate-spin h-4 w-4 mr-2" /> : <Plus className="h-4 w-4 mr-2" />}
                        Assign Member
                      </Button>
                    )}
                  </div>
                </Card>
              </div>
            </div>
          )}

          {/* DATA & LABELS TAB */}
          {activeTab === "data" && (
            <div className="space-y-6">
              <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                {/* Datasets */}
                <Card className="p-6">
                  <div className="flex justify-between items-center mb-4">
                    <h3 className="text-lg font-bold flex items-center gap-2">
                      <List className="h-5 w-5 text-blue-500" />
                      Datasets
                    </h3>
                  </div>
                  <div className="flex gap-2 mb-4">
                    <Input 
                      placeholder="Dataset name..."
                      value={newDatasetName} 
                      onChange={e => setNewDatasetName(e.target.value)} 
                    />
                    <Button onClick={handleCreateDataset} disabled={isActionLoading}>
                      {isActionLoading ? <Loader2 className="animate-spin h-4 w-4"/> : <Plus className="h-4 w-4" />}
                    </Button>
                  </div>
                  <div className="space-y-2 max-h-[300px] overflow-y-auto pr-2">
                    {datasets.map(ds => (
                      <div key={ds.id} className="p-3 border rounded-xl bg-gray-50 flex justify-between items-center group hover:border-blue-200 transition-all">
                        <div>
                          <p className="font-semibold text-gray-900">{ds.name}</p>
                          <p className="text-[10px] text-gray-400">{ds.totalItems || 0} items</p>
                        </div>
                        <Link to={`/manager/datasets/${ds.id}`}>
                          <Button variant="ghost" size="sm">Details</Button>
                        </Link>
                      </div>
                    ))}
                    {datasets.length === 0 && <p className="text-gray-400 text-center py-8 text-sm">No datasets created yet.</p>}
                  </div>
                </Card>

                {/* Labels */}
                <Card className="p-6">
                  <h3 className="text-lg font-bold mb-4 flex items-center gap-2">
                    <Tag className="h-5 w-5 text-green-500" />
                    Label Classes
                  </h3>
                  <div className="space-y-2 mb-4">
                    <Input 
                      placeholder="Label name..."
                      value={newLabelName} 
                      onChange={e => setNewLabelName(e.target.value)} 
                    />

                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-2">
                      <select
                        className="w-full h-10 px-3 text-sm bg-white border border-gray-200 rounded-lg outline-none focus:ring-2 focus:ring-blue-500"
                        value={selectedYoloPreset}
                        onChange={(e) => {
                          const next = e.target.value;
                          setSelectedYoloPreset(next);
                          setNewLabelYoloClassId(next);
                        }}
                      >
                        <option value="">Pick model class (optional)</option>
                        {YOLO_CLASS_OPTIONS.map((option) => (
                          <option key={option.id} value={String(option.id)}>
                            {option.name} (ID {option.id})
                          </option>
                        ))}
                      </select>

                      <Input
                        type="number"
                        min={0}
                        placeholder="YOLO Class ID"
                        value={newLabelYoloClassId}
                        onChange={(e) => {
                          setNewLabelYoloClassId(e.target.value);
                          setSelectedYoloPreset("");
                        }}
                      />
                    </div>

                    {suggestedYoloByName && !newLabelYoloClassId && (
                      <p className="text-xs text-blue-600 flex items-center gap-1">
                        <Info className="h-3.5 w-3.5" />
                        Suggested ID for "{newLabelName.trim()}": {suggestedYoloByName.id}
                        <button
                          type="button"
                          className="underline"
                          onClick={() => {
                            setNewLabelYoloClassId(String(suggestedYoloByName.id));
                            setSelectedYoloPreset(String(suggestedYoloByName.id));
                          }}
                        >
                          Use this
                        </button>
                      </p>
                    )}

                    {isDuplicateYoloId && (
                      <p className="text-xs text-red-600">This YOLO Class ID is already used in this project.</p>
                    )}

                    <Button
                      onClick={handleCreateLabel}
                      disabled={isActionLoading || !newLabelName.trim() || !newLabelYoloClassId || isDuplicateYoloId}
                    >
                      {isActionLoading ? <Loader2 className="animate-spin h-4 w-4"/> : <Plus className="h-4 w-4" />}
                    </Button>
                  </div>
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 max-h-[300px] overflow-y-auto pr-2">
                    {labels.map(l => (
                      <div key={l.id} className="p-3 border rounded-xl bg-gray-50 flex items-center justify-between">
                        <span className="font-medium text-sm">{l.name}</span>
                        <Badge variant="outline">ID {l.yoloClassId}</Badge>
                      </div>
                    ))}
                    {labels.length === 0 && <p className="col-span-2 text-gray-400 text-center py-8 text-sm">No labels defined yet.</p>}
                  </div>
                </Card>
              </div>
            </div>
          )}

          {/* TASKS TAB */}
          {activeTab === "tasks" && (
            <div className="space-y-6">
              <div className="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-7 gap-4">
                {[
                  { label: "Total", val: taskProgress?.total, icon: List, color: "gray" },
                  { label: "Assigned", val: taskProgress?.assigned, icon: Clock, color: "blue" },
                  { label: "In Progress", val: taskProgress?.inProgress, icon: Play, color: "indigo" },
                  { label: "Submitted", val: taskProgress?.submitted, icon: CheckCircle2, color: "green" },
                  { label: "Paused", val: taskProgress?.paused, icon: Pause, color: "orange" },
                  { label: "Cancelled", val: taskProgress?.cancelled, icon: XCircle, color: "red" },
                  { label: "Rework", val: taskProgress?.rework, icon: AlertCircle, color: "amber" },
                ].map(stat => (
                  <Card key={stat.label} className="p-4 flex flex-col items-center justify-center text-center">
                    <stat.icon className={`h-5 w-5 text-${stat.color}-500 mb-2`} />
                    <p className="text-[10px] text-gray-500 uppercase font-bold tracking-wider">{stat.label}</p>
                    <p className="text-xl font-bold mt-1">{stat.val || 0}</p>
                  </Card>
                ))}
              </div>

              <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                <Card className="p-6 lg:col-span-2">
                  <div className="flex justify-between items-center mb-6">
                    <h3 className="text-lg font-bold flex items-center gap-2">
                      <List className="h-5 w-5 text-blue-500" />
                      Task List
                    </h3>
                    <Link to="/manager/tasks/create">
                      <Button size="sm">
                        <Plus className="h-4 w-4 mr-2" /> New Task
                      </Button>
                    </Link>
                  </div>
                  <div className="overflow-x-auto">
                    <table className="w-full text-left text-sm">
                      <thead>
                        <tr className="text-gray-400 border-b border-gray-100">
                          <th className="pb-4 font-medium">Task ID</th>
                          <th className="pb-4 font-medium">Annotator</th>
                          <th className="pb-4 font-medium">Status</th>
                          <th className="pb-4 font-medium text-right">Actions</th>
                        </tr>
                      </thead>
                      <tbody className="divide-y divide-gray-50">
                        {tasks.map(task => {
                          const annotator = projectRoles.find(r => r.userId === task.annotatorId);
                          return (
                            <tr key={task.id} className="group hover:bg-gray-50/50 transition-colors">
                              <td className="py-4 font-mono text-xs">{task.id.slice(-8)}</td>
                              <td className="py-4">
                                {task.annotatorId ? (
                                  <span className="text-sm font-medium" title={annotator?.userEmail}>{annotator?.userEmail || "Assigned"}</span>
                                ) : (
                                  <select 
                                    className="text-xs p-1 border rounded bg-white outline-none focus:ring-1 focus:ring-blue-500"
                                    onChange={(e) => handleAssignTask(task.id, e.target.value)}
                                    defaultValue=""
                                  >
                                    <option value="" disabled>Unassigned</option>
                                    {projectRoles
                                      .filter(r => r.roleName === "Annotator")
                                      .map(r => (
                                        <option key={r.userId} value={r.userId}>{r.userEmail || "Unknown"}</option>
                                      ))}
                                  </select>
                                )}
                              </td>
                              <td className="py-4">
                                <Badge variant={task.status === "Submitted" ? "success" : task.status === "InProgress" ? "primary" : "secondary"}>
                                  {task.status}
                                </Badge>
                              </td>
                              <td className="py-4 text-right">
                                <div className="flex justify-end gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                                  <Button variant="ghost" size="icon" className="h-8 w-8" title="Pause">
                                    <Pause className="h-3.5 w-3.5" />
                                  </Button>
                                  <Button variant="ghost" size="icon" className="h-8 w-8 text-red-500" title="Cancel">
                                    <XCircle className="h-3.5 w-3.5" />
                                  </Button>
                                </div>
                              </td>
                            </tr>
                          );
                        })}
                        {tasks.length === 0 && (
                          <tr>
                            <td colSpan={4} className="py-12 text-center text-gray-400 italic">No tasks created for this project.</td>
                          </tr>
                        )}
                      </tbody>
                    </table>
                  </div>
                </Card>

                <Card className="p-6 bg-blue-600 text-white border-none shadow-xl flex flex-col justify-between h-full">
                  <div>
                    <h3 className="text-xl font-bold mb-4">Bulk Operations</h3>
                    <p className="text-blue-100 text-sm mb-6 leading-relaxed">
                      Need to assign hundreds of items at once? Use the bulk assignment tool to select datasets and distribute them among your workforce.
                    </p>
                  </div>
                  <div className="space-y-3">
                    <Button fullWidth variant="secondary" className="bg-white/10 hover:bg-white/20 border-none text-white">
                      Reassign All Paused
                    </Button>
                    <Button fullWidth className="bg-white text-blue-600 hover:bg-blue-50 border-none font-bold">
                      Launch Bulk Wizard
                    </Button>
                  </div>
                </Card>
              </div>
            </div>
          )}

          {/* MONITORING TAB */}
          {activeTab === "monitoring" && (
            <div className="space-y-6">
              <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                <Card className="p-6">
                  <h4 className="text-sm font-bold text-gray-500 uppercase mb-4">Labeling Progress</h4>
                  <div className="space-y-4">
                    <div className="flex justify-between text-sm">
                      <span>Completion Rate</span>
                      <span className="font-bold">{qualityReport ? Math.round((qualityReport.progress.completedTasks / qualityReport.progress.totalTasks) * 100) : 0}%</span>
                    </div>
                    <div className="w-full bg-gray-100 rounded-full h-2">
                      <div className="bg-green-500 h-2 rounded-full" style={{ width: `${qualityReport ? (qualityReport.progress.completedTasks / qualityReport.progress.totalTasks) * 100 : 0}%` }}></div>
                    </div>
                  </div>
                </Card>

                <Card className="p-6">
                  <h4 className="text-sm font-bold text-gray-500 uppercase mb-4">Review Stats</h4>
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="text-3xl font-bold text-gray-900">{qualityReport?.reviewStats.totalReviews || 0}</p>
                      <p className="text-xs text-gray-500">Total Reviews</p>
                    </div>
                    <div className="text-right">
                      <p className="text-lg font-bold text-green-600">+{qualityReport?.reviewStats.approvedReviews || 0}</p>
                      <p className="text-lg font-bold text-red-600">-{qualityReport?.reviewStats.rejectedReviews || 0}</p>
                    </div>
                  </div>
                </Card>

                <Card className="p-6">
                  <h4 className="text-sm font-bold text-gray-500 uppercase mb-4">Quality Issues</h4>
                  <div className="flex items-center gap-4">
                    <div className="p-3 bg-red-100 text-red-600 rounded-xl">
                      <AlertCircle className="h-6 w-6" />
                    </div>
                    <div>
                      <p className="text-2xl font-bold text-gray-900">{qualityReport?.inconsistentLabelsCount || 0}</p>
                      <p className="text-xs text-gray-500">Inconsistent Labels</p>
                    </div>
                  </div>
                </Card>
              </div>

              <Card className="p-6">
                <h3 className="text-lg font-bold mb-6">Annotator Performance</h3>
                <div className="overflow-x-auto">
                  <table className="w-full text-left text-sm">
                    <thead>
                      <tr className="text-gray-400 border-b border-gray-100">
                        <th className="pb-4 font-medium">Annotator</th>
                        <th className="pb-4 font-medium">Assigned</th>
                        <th className="pb-4 font-medium">Submitted</th>
                        <th className="pb-4 font-medium">Completed</th>
                        <th className="pb-4 font-medium text-right">Success Rate</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-gray-50">
                      {annotatorPerformance.map(perf => (
                        <tr key={perf.annotatorId} className="group">
                          <td className="py-4">
                            <div className="flex items-center gap-3">
                              <div className="h-8 w-8 bg-blue-100 text-blue-700 rounded-full flex items-center justify-center text-[10px] font-bold">
                                {perf.annotatorEmail?.[0]?.toUpperCase() || 'U'}
                              </div>
                              <span className="font-medium" title={perf.annotatorEmail}>{perf.annotatorEmail || "Unknown Annotator"}</span>
                            </div>
                          </td>
                          <td className="py-4">{perf.assignedTasks}</td>
                          <td className="py-4 text-blue-600">{perf.submittedTasks}</td>
                          <td className="py-4 text-green-600">{perf.completedTasks}</td>
                          <td className="py-4 text-right font-bold text-gray-900">
                            {perf.assignedTasks > 0 ? Math.round((perf.completedTasks / perf.assignedTasks) * 100) : 0}%
                          </td>
                        </tr>
                      ))}
                      {annotatorPerformance.length === 0 && (
                        <tr>
                          <td colSpan={5} className="py-12 text-center text-gray-400 italic">No annotator activity recorded for this project.</td>
                        </tr>
                      )}
                    </tbody>
                  </table>
                </div>
              </Card>
            </div>
          )}

          {/* EXPORTS & LOGS TAB */}
          {activeTab === "exports" && (
            <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
              <div className="lg:col-span-2 space-y-6">
                <Card className="p-6">
                  <div className="flex justify-between items-center mb-6">
                    <h3 className="text-lg font-bold flex items-center gap-2">
                      <Download className="h-5 w-5 text-blue-500" />
                      Export Data
                    </h3>
                    <div className="flex gap-2">
                      <Button size="sm" variant="outline" onClick={handleValidate} disabled={isActionLoading}>
                        {isActionLoading ? <Loader2 className="animate-spin h-4 w-4 mr-2" /> : <CheckCircle2 className="h-4 w-4 mr-2" />}
                        Validate Data
                      </Button>
                      <Button size="sm" onClick={() => handleCreateExport("YOLO")}>Export YOLO</Button>
                    </div>
                  </div>

                  <div className="mb-8 p-4 bg-blue-50/50 rounded-2xl border border-blue-100/50">
                    <h4 className="text-sm font-bold text-blue-900 mb-2 flex items-center gap-2">
                      <Info className="h-4 w-4" />
                      What's inside a YOLO export?
                    </h4>
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-xs text-blue-800/80">
                      <div className="space-y-1">
                        <p className="font-bold text-blue-900">Structure:</p>
                        <p>• <span className="font-mono">classes.txt</span>: List of label names.</p>
                        <p>• <span className="font-mono">labels/</span>: Folder containing annotation files.</p>
                      </div>
                      <div className="space-y-1">
                        <p className="font-bold text-blue-900">Format:</p>
                        <p>• One <span className="font-mono">.txt</span> file per image.</p>
                        <p>• Normalized coordinates (0-1) for YOLO training.</p>
                      </div>
                    </div>
                  </div>

                  {validationResult && (
                    <div className={`p-4 rounded-xl mb-6 flex items-start gap-3 ${validationResult.isValid ? "bg-green-50 text-green-800 border border-green-100" : "bg-amber-50 text-amber-800 border border-amber-100"}`}>
                      {validationResult.isValid ? <CheckCircle2 className="h-5 w-5 mt-0.5" /> : <AlertCircle className="h-5 w-5 mt-0.5" />}
                      <div>
                        <p className="font-bold">Validation {validationResult.isValid ? "Passed" : "Warning"}</p>
                        <p className="text-sm">
                          {validationResult.reviewedAnnotationSets} / {validationResult.submittedAnnotationSets} annotation sets reviewed.
                          {!validationResult.isValid && " We recommend reviewing all submissions before exporting."}
                        </p>
                      </div>
                    </div>
                  )}

                  <div className="space-y-3">
                    <h4 className="text-xs font-bold text-gray-400 uppercase tracking-widest mb-2">Export History</h4>
                    {exports.map(exp => (
                      <div key={exp.id} className="p-4 border border-gray-100 rounded-2xl bg-gray-50 flex items-center justify-between group">
                        <div className="flex items-center gap-4">
                          <div className={`p-2 rounded-lg border border-gray-100 shadow-sm ${exp.format.toUpperCase() === 'YOLO' ? 'bg-amber-50' : 'bg-blue-50'}`}>
                            {exp.format.toUpperCase() === 'YOLO' ? <Archive className="h-5 w-5 text-amber-600" /> : <FileText className="h-5 w-5 text-blue-600" />}
                          </div>
                          <div>
                            <p className="font-bold text-gray-900 capitalize">{exp.format} Export</p>
                            <div className="flex items-center gap-2 mt-0.5">
                              <span className="text-[10px] bg-gray-100 px-1.5 py-0.5 rounded font-mono text-gray-500 uppercase">{exp.config.labelFormat}</span>
                              <span className="text-[10px] text-gray-400">•</span>
                              <p className="text-[10px] text-gray-400">{new Date(exp.createdAt).toLocaleString()}</p>
                            </div>
                          </div>
                        </div>
                        <div className="flex gap-2">
                          <Button variant="ghost" size="sm" onClick={() => managerService.downloadExport(exp.id)} className="text-blue-600 hover:bg-blue-50">
                            <Download size={14} className="mr-1.5" /> Download
                          </Button>
                        </div>
                      </div>
                    ))}
                    {exports.length === 0 && <p className="text-center py-12 text-gray-400 text-sm">No exports generated yet.</p>}
                  </div>
                </Card>
              </div>

              <Card className="p-6">
                <h3 className="text-lg font-bold mb-4 flex items-center gap-2">
                  <History className="h-5 w-5 text-gray-400" />
                  Activity Logs
                </h3>
                <div className="space-y-4 max-h-[500px] overflow-y-auto pr-2">
                  {activityLogs.map(log => (
                    <div key={log.id} className="relative pl-6 pb-4 border-l-2 border-gray-100 last:pb-0">
                      <div className="absolute left-[-5px] top-1 h-2 w-2 rounded-full bg-blue-500"></div>
                      <p className="text-xs font-bold text-gray-900 uppercase tracking-tighter">{log.action}</p>
                      <p className="text-xs text-gray-500 mt-1">{log.description}</p>
                      <p className="text-[10px] text-gray-300 mt-1">{new Date(log.createdAt).toLocaleString()}</p>
                    </div>
                  ))}
                  {activityLogs.length === 0 && <p className="text-center py-8 text-gray-400 text-sm italic">No activity recorded.</p>}
                </div>
              </Card>
            </div>
          )}

          {/* SETTINGS TAB */}
          {activeTab === "settings" && (
            <Card className="p-12 text-center bg-gray-50 border-dashed border-2">
              <Settings className="h-12 w-12 text-gray-300 mx-auto mb-4" />
              <h3 className="text-xl font-bold text-gray-900">Project Settings</h3>
              <p className="text-gray-500 mt-2 max-w-md mx-auto">
                Advanced project configuration, including status changes, API keys, and deep project deletion options will be available here.
              </p>
              <div className="mt-8 flex justify-center gap-4">
                 <Button variant="outline" className="text-red-600 border-red-200">Delete Project</Button>
                 <Button variant="secondary">Pause Project</Button>
              </div>
            </Card>
          )}

        </div>

      </div>
    </DashboardLayout>
  );
};

export default ProjectDetailPage;