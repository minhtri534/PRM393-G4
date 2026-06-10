import { useState } from 'react';
import DashboardLayout from '../../layouts/DashboardLayout';
import { Button } from '../../components/ui/Button';
import { INITIAL_NOTIFICATIONS } from '../../data/mockData';
import type { Notification } from '../../data/mockData';
import { 
  Bell, 
  CheckCircle2, 
  AlertCircle, 
  Info, 
  Clock, 
  Check,
  Trash2,
} from 'lucide-react';

export default function NotificationsPage() {
  const [notifications, setNotifications] = useState<Notification[]>(INITIAL_NOTIFICATIONS);
  const [filter, setFilter] = useState<'all' | 'unread'>('all');

  const filteredNotifications = notifications.filter(n => 
    filter === 'all' ? true : !n.isRead
  );

  // Simple grouping logic based on timestamp string
  const todayNotifications = filteredNotifications.filter(n => n.timestamp.includes('hour') || n.timestamp.includes('min'));
  const earlierNotifications = filteredNotifications.filter(n => !n.timestamp.includes('hour') && !n.timestamp.includes('min'));

  const markAsRead = (id: string) => {
    setNotifications(prev => prev.map(n => 
      n.id === id ? { ...n, isRead: true } : n
    ));
  };

  const markAllAsRead = () => {
    setNotifications(prev => prev.map(n => ({ ...n, isRead: true })));
  };

  const deleteNotification = (id: string) => {
    setNotifications(prev => prev.filter(n => n.id !== id));
  };

  const getIcon = (type: Notification['type']) => {
    switch (type) {
      case 'success': return <CheckCircle2 className="h-5 w-5 text-emerald-500" />;
      case 'warning': return <AlertCircle className="h-5 w-5 text-amber-500" />;
      case 'error': return <AlertCircle className="h-5 w-5 text-red-500" />;
      default: return <Info className="h-5 w-5 text-blue-500" />;
    }
  };

  const getBgColor = (type: Notification['type']) => {
    switch (type) {
      case 'success': return 'bg-emerald-50 border-emerald-100';
      case 'warning': return 'bg-amber-50 border-amber-100';
      case 'error': return 'bg-red-50 border-red-100';
      default: return 'bg-blue-50 border-blue-100';
    }
  };

  const NotificationItem = ({ notification }: { notification: Notification }) => (
    <div 
      className={`group relative p-4 rounded-2xl border transition-all duration-200 ${
        !notification.isRead 
          ? 'bg-white border-brand/20 shadow-md shadow-brand/5 ring-1 ring-brand/5' 
          : 'bg-gray-50/50 border-transparent opacity-75 hover:opacity-100 hover:bg-white hover:shadow-sm'
      }`}
    >
      {!notification.isRead && (
        <div className="absolute top-0 left-0 bottom-0 w-1 bg-brand rounded-l-2xl" />
      )}
      
      <div className="flex gap-4">
        <div className={`p-3 rounded-xl h-fit shrink-0 ${getBgColor(notification.type)} border`}>
          {getIcon(notification.type)}
        </div>
        
        <div className="flex-1 min-w-0">
          <div className="flex items-start justify-between pr-4">
            <div>
              <h3 className={`text-sm font-semibold ${!notification.isRead ? 'text-gray-900' : 'text-gray-600'}`}>
                {notification.title}
              </h3>
              <p className={`text-sm mt-1 leading-relaxed ${!notification.isRead ? 'text-gray-700' : 'text-gray-500'}`}>
                {notification.message}
              </p>
            </div>
          </div>
          
          <div className="mt-3 flex items-center justify-between">
            <span className="text-xs text-gray-400 flex items-center gap-1.5 bg-gray-50 px-2 py-1 rounded-md border border-gray-100">
              <Clock className="h-3 w-3" />
              {notification.timestamp}
            </span>
            
            <div className="flex items-center gap-2 opacity-0 group-hover:opacity-100 transition-opacity">
              {!notification.isRead && (
                <button 
                  onClick={() => markAsRead(notification.id)}
                  className="p-1.5 text-gray-400 hover:text-brand hover:bg-brand/10 rounded-lg transition-colors"
                  title="Mark as read"
                >
                  <Check className="h-4 w-4" />
                </button>
              )}
              <button 
                onClick={() => deleteNotification(notification.id)}
                className="p-1.5 text-gray-400 hover:text-red-500 hover:bg-red-50 rounded-lg transition-colors"
                title="Delete"
              >
                <Trash2 className="h-4 w-4" />
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );

  return (
    <DashboardLayout>
      <div className="space-y-8 max-w-4xl mx-auto">
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
          <div>
            <div className="flex items-center gap-3 mb-1">
              <h1 className="text-3xl font-bold text-gray-900 tracking-tight">
                Notifications
              </h1>
              {notifications.filter(n => !n.isRead).length > 0 && (
                <span className="inline-flex items-center justify-center px-2.5 py-0.5 rounded-full text-xs font-bold bg-brand/10 text-brand border border-brand/20">
                  {notifications.filter(n => !n.isRead).length} new
                </span>
              )}
            </div>
            <p className="text-gray-500">
              Stay updated with your latest activities.
            </p>
          </div>
          <div className="flex gap-3">
            <Button 
              variant="outline" 
              onClick={markAllAsRead}
              className="bg-white/50 backdrop-blur-sm hover:bg-white"
            >
              <Check className="h-4 w-4 mr-2" />
              Mark all as read
            </Button>
          </div>
        </div>

        <div className="flex items-center gap-2 border-b border-gray-200/50 pb-1">
          <button
            onClick={() => setFilter('all')}
            className={`px-4 py-2 text-sm font-medium rounded-lg transition-all duration-200 ${
              filter === 'all' 
                ? 'bg-white shadow-sm text-brand' 
                : 'text-gray-500 hover:bg-white/50 hover:text-gray-900'
            }`}
          >
            All
          </button>
          <button
            onClick={() => setFilter('unread')}
            className={`px-4 py-2 text-sm font-medium rounded-lg transition-all duration-200 ${
              filter === 'unread' 
                ? 'bg-white shadow-sm text-brand' 
                : 'text-gray-500 hover:bg-white/50 hover:text-gray-900'
            }`}
          >
            Unread
          </button>
        </div>

        <div className="space-y-8">
          {filteredNotifications.length === 0 ? (
            <div className="p-12 text-center flex flex-col items-center justify-center min-h-[400px] rounded-3xl bg-white/40 border border-white/40 backdrop-blur-sm">
              <div className="h-20 w-20 rounded-full bg-gray-50 flex items-center justify-center mb-6 shadow-inner">
                <Bell className="h-10 w-10 text-gray-300" />
              </div>
              <h3 className="text-xl font-semibold text-gray-900">All caught up!</h3>
              <p className="text-gray-500 mt-2 max-w-sm">
                You have no {filter === 'unread' ? 'unread' : ''} notifications at the moment. We'll notify you when something important happens.
              </p>
            </div>
          ) : (
            <>
              {todayNotifications.length > 0 && (
                <div className="space-y-4 animate-in fade-in slide-in-from-bottom-4 duration-500">
                  <h2 className="text-sm font-semibold text-gray-500 uppercase tracking-wider pl-1">Today</h2>
                  {todayNotifications.map(notification => (
                    <NotificationItem key={notification.id} notification={notification} />
                  ))}
                </div>
              )}

              {earlierNotifications.length > 0 && (
                <div className="space-y-4 animate-in fade-in slide-in-from-bottom-4 duration-500 delay-100">
                  <h2 className="text-sm font-semibold text-gray-500 uppercase tracking-wider pl-1">Earlier</h2>
                  {earlierNotifications.map(notification => (
                    <NotificationItem key={notification.id} notification={notification} />
                  ))}
                </div>
              )}
            </>
          )}
        </div>
      </div>
    </DashboardLayout>
  );
}
