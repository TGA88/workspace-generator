import React from 'react';

import { UserList } from '../../components/user-list/user-list';
import { UserStats } from '../../components/user-stats/user-stats';
import { UserManagementLayout } from '../../components/user-management-layout/user-management-layout';
import { useUserManagement } from '../../hooks/hook-user-management';

/** page = entry-point ของ feature — host เอาไป mount เป็น 1 หน้า (frontend-structure §3) */
export const UserManagementPage: React.FC = () => {
  const {
    users,
    stats,
    filters,
    selectUser,
    deleteUser,
    setFilter
  } = useUserManagement();

  const handleFilterChange = (field: string, value: string): void => {
    setFilter({ [field]: value });
  };

  return (
    <UserManagementLayout
      statsComponent={
        <UserStats stats={stats} />
      }
      listComponent={
        <UserList
          users={users}
          filters={filters}
          onFilterChange={handleFilterChange}
          onSelectUser={selectUser}
          onDeleteUser={deleteUser}
        />
      }
    />
  );
};
