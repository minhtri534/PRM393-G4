import React, { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { Card } from "../../components/ui/Card";
import { Badge } from "../../components/ui/Badge";
import DashboardLayout from "../../layouts/DashboardLayout";
import { Button } from "../../components/ui/Button";
import { List, PlayCircle, Loader2 } from "lucide-react";
import { reviewerService } from "../../services/reviewerService";
import type { ReviewerSubmittedTaskResponse } from "../../services/reviewerService";

const ReviewerTaskListPage: React.FC = () => {
  const [tasks, setTasks] = useState<ReviewerSubmittedTaskResponse[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const load = async () => {
      setLoading(true);
      try {
        const res = await reviewerService.getSubmittedTasks();
        if (res.isSuccess) {
          setTasks(res.data || []);
        }
      } finally {
        setLoading(false);
      }
    };

    load();
  }, []);

  return (
    <DashboardLayout>
      <div className="max-w-6xl mx-auto space-y-6">
        <div>
          <h1 className="text-3xl font-bold text-gray-900 tracking-tight">Review Tasks</h1>
          <p className="text-gray-500 mt-1">List of tasks waiting for your review.</p>
        </div>

        <Card variant="glass" className="p-6">
          {loading ? (
            <div className="py-14 flex flex-col items-center justify-center text-gray-600 gap-3">
              <Loader2 className="w-8 h-8 animate-spin text-blue-600" />
              <p>Loading review tasks...</p>
            </div>
          ) : (
            <div className="space-y-4">
              {tasks.length === 0 && (
                <div className="p-12 text-center bg-gray-50 rounded-xl border-2 border-dashed border-gray-200">
                  <List className="h-12 w-12 text-gray-300 mx-auto mb-3" />
                  <p className="text-gray-500">There are no tasks to review.</p>
                </div>
              )}
              {tasks.map((task) => (
                <Card key={task.id} className="p-5 flex items-center justify-between hover:shadow-md transition-all border border-gray-100">
                  <div className="flex items-center gap-4">
                    <div className="p-3 bg-green-50 text-green-600 rounded-lg">
                      <List className="h-6 w-6" />
                    </div>
                    <div>
                      <h3 className="font-bold text-lg text-gray-900">Review Task #{task.id.slice(-6)}</h3>
                      <div className="flex items-center gap-3 text-sm text-gray-500 mt-1">
                        <span className="bg-gray-100 px-2 py-0.5 rounded text-xs font-semibold uppercase">Project: {task.projectName}</span>
                        <span>•</span>
                        <span>Annotator: {task.annotatorName}</span>
                        <span>•</span>
                        <span>Annotations: {task.annotationCount}</span>
                      </div>
                    </div>
                  </div>
                  <div className="flex items-center gap-4">
                    <Badge variant="primary">Pending Review</Badge>
                    <Link to={`/reviewer/task/${task.id}`}>
                      <Button variant="primary" className="bg-green-600 hover:bg-green-700">
                        <PlayCircle className="h-4 w-4 mr-2" />
                        Start Review
                      </Button>
                    </Link>
                  </div>
                </Card>
              ))}
            </div>
          )}
        </Card>
      </div>
    </DashboardLayout>
  );
};

export default ReviewerTaskListPage;
