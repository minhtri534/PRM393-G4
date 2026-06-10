export type ReviewTaskStatus = "pending" | "approved" | "returned";

export interface ReviewTask {
  id: string;
  annotator: string;
  datasetName: string;
  submittedAt: string;
  status: ReviewTaskStatus;
  guideline: string;
  labels: string[];
  systemFlag?: boolean;
}

export const REVIEW_TASKS: ReviewTask[] = [
  {
    id: "task-001",
    annotator: "Nguyen Van A",
    datasetName: "Traffic Dataset",
    submittedAt: "2026-02-10",
    status: "pending",
    guideline: "Label all vehicles correctly. No overlapping boxes.",
    labels: ["Car", "Truck", "Car", "Bike"],
    systemFlag: false
  },
  {
    id: "task-002",
    annotator: "Tran Thi B",
    datasetName: "Retail Dataset",
    submittedAt: "2026-02-11",
    status: "pending",
    guideline: "All products must have bounding box.",
    labels: ["Bottle", "Bottle", "Bottle"],
    systemFlag: true
  }
];
