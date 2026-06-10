export type User = {
  id: string;
  name: string;
  email: string;
  role: 'admin' | 'reviewer' | 'annotator';
  status: 'active' | 'inactive';
  lastActive: string;
};

export const INITIAL_USERS: User[] = [
  {
    id: '1',
    name: 'Sarah Wilson',
    email: 'sarah.wilson@example.com',
    role: 'reviewer',
    status: 'active',
    lastActive: '2 minutes ago'
  },
  {
    id: '2',
    name: 'Michael Chen',
    email: 'michael.chen@example.com',
    role: 'annotator',
    status: 'active',
    lastActive: '1 hour ago'
  },
  {
    id: '3',
    name: 'David Miller',
    email: 'david.miller@example.com',
    role: 'annotator',
    status: 'inactive',
    lastActive: '2 days ago'
  },
  {
    id: '4',
    name: 'Emma Davis',
    email: 'emma.davis@example.com',
    role: 'admin',
    status: 'active',
    lastActive: 'Just now'
  }
];

export type Notification = {
  id: string;
  title: string;
  message: string;
  type: 'info' | 'success' | 'warning' | 'error';
  timestamp: string;
  isRead: boolean;
};

export const INITIAL_NOTIFICATIONS: Notification[] = [
  {
    id: '1',
    title: 'New Task Assigned',
    message: 'You have been assigned to the "Vehicle Detection v2" project.',
    type: 'info',
    timestamp: '2 hours ago',
    isRead: false
  },
  {
    id: '2',
    title: 'Review Completed',
    message: 'Your review for Batch #4092 has been approved by QA.',
    type: 'success',
    timestamp: '5 hours ago',
    isRead: false
  },
  {
    id: '3',
    title: 'System Maintenance',
    message: 'Scheduled maintenance will occur on Saturday at 2:00 AM UTC.',
    type: 'warning',
    timestamp: '1 day ago',
    isRead: true
  },
  {
    id: '4',
    title: 'Profile Updated',
    message: 'Your profile information was successfully updated.',
    type: 'success',
    timestamp: '2 days ago',
    isRead: true
  }
];
