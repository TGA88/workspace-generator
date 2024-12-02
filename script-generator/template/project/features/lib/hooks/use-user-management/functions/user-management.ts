import { User } from '@feature-exm/types/user.type';

export const filterActiveUsers = (users: User[]) =>
  users.filter(user => user.isActive && !user.isDeleted);

export const calculateUserStats = (users: User[]) => {
  const now = new Date();
  const thirtyDaysAgo = new Date(now.setDate(now.getDate() - 30));

  return {
    total: users.length,
    active: users.filter(u => u.isActive).length,
    premium: users.filter(u => u.isPremium).length,
    recentlyActive: users.filter(u => 
      new Date(u.lastLoginDate) > thirtyDaysAgo
    ).length
  };
};

export const filterUsersByRole = (users: User[], role: string) =>
  role ? users.filter(user => user.role === role) : users;