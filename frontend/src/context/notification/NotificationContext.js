import { createContext } from 'react';

export const NotificationContext = createContext({
  notifications: [],
  addNotification: () => {},
  removeNotification: () => {},
  clearNotifications: () => {},
  markAsRead: () => {},
  markAllAsRead: () => {},
  unreadCount: 0,
});
