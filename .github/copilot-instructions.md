# Fullstack Project Context: C# .NET & React (Shadcn UI)
# PROJECT OVERVIEW: DATA LABELING SUPPORT SYSTEM (DLSS)
1. Executive Summary
Data Labeling Support System (DLSS) là một nền tảng quản lý quy trình gán nhãn dữ liệu toàn diện (End-to-End). Hệ thống cho phép các tổ chức quản lý dự án, dữ liệu thô, đội ngũ nhân sự và quy trình kiểm soát chất lượng nhằm tạo ra các bộ dữ liệu chuẩn (Ground Truth) cho AI. Điểm khác biệt của hệ thống nằm ở khả năng hỗ trợ gán nhãn bằng AI (AI-assisted), quản lý phiên bản dữ liệu và tích hợp module tài chính (Cost & Payment) cho cả khách hàng (Project) và cộng tác viên (Workforce).

2. System Actors
Manager: Chủ dự án, người thiết lập cấu trúc nhãn, quản lý dataset, điều phối task và giám sát tiến độ/chất lượng.

Annotator (Người gán nhãn): Thực hiện gán nhãn thủ công hoặc sử dụng gợi ý từ AI, xử lý phản hồi từ Reviewer.

Reviewer (Người kiểm duyệt): Kiểm tra tính chính xác, tính nhất quán của nhãn và đưa ra phản hồi (Reject/Approve).

Admin: Quản trị hệ thống, cấu hình phân quyền, giám sát logs, cấu hình biểu phí và phê duyệt thanh toán tổng thể.

3. Core Modules & Domain Model
Hệ thống được tổ chức thành 13 Epic chính, tập trung vào các thực thể (Entities) sau:

A. Project & Data Management (Epic 3, 4, 5)
Project: Đơn vị quản lý cao nhất, chứa các Guideline, cấu hình nhãn và ngân sách.

Dataset & Versioning: Quản lý dữ liệu thô. Hỗ trợ import từ nguồn ngoài và lưu vết phiên bản (Versioning) để đảm bảo tính toàn vẹn dữ liệu.

Label Configuration: Định nghĩa các Label Set, Category và Annotation Type (Bbox, Polygon, Tagging, v.v.).

B. Workforce & Task Orchestration (Epic 6, 7, 10)
Task Lifecycle: Từ lúc khởi tạo -> Gán (Assign) -> Đang làm (In-progress) -> Tạm dừng (Pause) -> Nộp (Submit).

Labeling Engine: Giao diện làm việc của Annotator, hỗ trợ lưu nháp (Draft) và xử lý vòng lặp sửa lỗi (Rework Loop) dựa trên feedback của Reviewer.

C. AI-Assisted Labeling (Epic 8)
Tích hợp Model AI để gợi ý nhãn (Pre-labeling). Annotator đóng vai trò kiểm chứng (Accept/Modify/Reject), giúp tăng tốc độ gán nhãn gấp nhiều lần.

D. Quality Assurance (QA) & Monitoring (Epic 9)
Quy trình Review chéo.

Công cụ phát hiện nhãn không nhất quán (Inconsistent Labels) và báo cáo hiệu suất (Performance Report).

E. Financial & Payment Governance (Epic 11, 12)
Project Side: Quản lý ngân sách dự án, ước tính chi phí, hóa đơn (Invoice) và thanh toán từ phía khách hàng.

Workforce Side: Tính toán thu nhập cho Annotator/Reviewer dựa trên số lượng nhãn/task đã được Approve. Xử lý tranh chấp (Dispute) thanh toán.

F. Administration & Security (Epic 1, 2, 13)
Quản lý danh tính (Identity Management), phân quyền dựa trên Role (RBAC).

Hệ thống Audit Log ghi lại mọi tác động vào dữ liệu và cấu hình hệ thống.

4. Primary Workflows
Setup: Admin tạo User -> Manager tạo Project -> Upload Dataset -> Cấu hình Label Set & Guideline.

Execution: Manager tạo Task & Assign cho Annotator -> Annotator thực hiện gán nhãn (có sự hỗ trợ của AI) -> Submit.

Review: Reviewer kiểm tra -> (Approve -> Kết thúc task) HOẶC (Reject -> Task quay lại Annotator để sửa).

Export: Dữ liệu sau khi qua Review được Validate và Export theo định dạng yêu cầu (JSON, CSV, XML...).

Settlement: Hệ thống tính toán chi phí dự án và thu nhập cho nhân sự dựa trên kết quả cuối cùng.

5. Technical Constraints & Logic
Data Integrity: Dữ liệu đã gán nhãn và được Approve phải được khóa để đảm bảo tính nhất quán khi Export.

Concurrency: Xử lý tranh chấp khi nhiều Annotator cùng thực hiện các task trong một dataset lớn.

AI Integration: Flow AI gợi ý phải có tính năng "Preview" trước khi lưu vào database chính thức.

## 🛠 1. Tech Stack Summary
- **Backend:** C# (.NET 8/9+), ASP.NET Core Web API.
- **Frontend:** ReactJS (Vite), TypeScript, Tailwind CSS.
- **UI & UX:** Shadcn UI (Radix UI), Lucide React (Icons), Framer Motion (Animations).
- **Data Management:** EF Core (SQL Server), TanStack Query (React Query), Axios.
- **Architecture:** Clean Architecture, Layered Pattern (Controller-Service-Repository).

## 🤖 2. Model Roles & Instructions

### 🎨 Frontend Specialist (Preferred: Claude Sonnet 4.5)
- **UI Components:** Always use **Shadcn UI** components. Assume they are located in `@/components/ui`.
- **Modern UX:** Use **Framer Motion** for subtle entrance animations (e.g., `initial={{ opacity: 0, y: 10 }}`).
- **Icons:** Use **Lucide React** icons exclusively.
- **Data Fetching:** Use **TanStack Query** for caching, loading states, and error handling.
- **Styling:** Use **Tailwind CSS** following a mobile-first approach.
- **Types:** Strictly use **TypeScript Interfaces** that match Backend DTOs.
- **Canvas Interaction:** Use **react-konva** for drawing bounding boxes and polygons. Focus on coordinate scaling between the displayed image and the original image size.

## 📂 Frontend Structure (ReactJS / Vite)
Follow this folder structure for the Frontend:
- **components/**: Shared UI components (Atomic design).
- **pages/**: Main views (Dashboard, Editor, Project List).
- **hooks/**: Custom hooks for logic (Annotation tools, API fetching).
- **services/**: API calls using Axios.
- **stores/**: Global state management (Zustand/Redux).
- **types/**: TypeScript interfaces (match Backend DTOs).
- **utils/**: Helper functions (Coordinate scaling, Image formatting).
- **lib/**: Library configurations (Canvas engine, Axios instances).
- **schemas/**: Zod validation schemas for forms.
- **contexts/ & providers/**: Global React contexts (Auth, Theme).

### ⚙️ Backend Specialist (Preferred: GPT-5.2)
- **Modern C#:** Use **Primary Constructors**, **File-scoped namespaces**, and **Records** for DTOs.
- **Logic Flow:** Use **Result Pattern** (`Result<T>` or `ServiceResponse<T>`) instead of throwing exceptions for business logic.
- **Validation:** Use **FluentValidation** for all incoming request models.
- **Database:** Use **EF Core** with LINQ. Use `.AsNoTracking()` for read-only queries.
- **Mapping:** Use **AutoMapper** or **Mapster** to convert Entities to DTOs.
- **Security:** Ensure JWT-based authentication and Role-based authorization are implemented.
- **Large Data Handling:** Optimize API for handling large image datasets and JSON blobs for complex annotations.

## 📂 Backend Structure (C# / .NET)
Please follow this folder structure for the Backend:
- **Controllers/**: Handle HTTP requests and routing.
- **Services/**: Business logic (Labeling workflows, Export logic).
- **Models/**: Entity Framework entities and Database context.
- **DTOs/**: Data Transfer Objects (Request/Response models).
- **Middlewares/**: Custom error handling and Auth.
- **Configurations/**: DB connection, JWT settings, File storage paths.
- **Utils/**: Helper classes (Image processing, Coordinate conversion).
- **Validations/**: FluentValidation classes.

### 🏗 Project Architect (Preferred: Gemini 3 Pro)
- **Workspace:** Analyze the relationship between `Controllers` (C#) and `Services` (React) to ensure consistency.
- **Global Config:** Monitor `Program.cs` for middleware and `package.json` for dependencies.

## 📏 3. Coding Standards & Naming
- **C#:** PascalCase for Classes/Methods, camelCase for local variables. Use `async/await` everywhere.
- **React:** PascalCase for Components, camelCase for functions/variables. Use Functional Components with Hooks.
- **Database:** PascalCase for Table and Column names in SQL Server.
- **Standardized Response:** All API responses must follow the structure: `{ "isSuccess": bool, "data": T, "message": string, "errors": [] }`.

## 🚀 4. Performance & Quality
- Implement **Global Exception Handling** middleware in .NET.
- Use **Skeleton Loaders** (Shadcn) in React while TanStack Query is fetching.
- Prioritize **Clean Code** (DRY, SOLID) and self-documenting code.