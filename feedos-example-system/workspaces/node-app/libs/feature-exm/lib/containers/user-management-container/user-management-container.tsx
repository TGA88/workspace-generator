import React from 'react';
import { UserList } from '../../components/user-list/user-list';
import { UserStats } from '../../components/user-stats/user-stats';
import { UserManagementLayout } from '../../components/user-management-layout/user-management-layout';
import { useUserManagement } from '../../hooks/use-user-management/useUserManagement';

export const UserManagementContainer: React.FC = () => {
  const {
    users,
    stats,
    filters,
    selectUser,
    deleteUser,
    setFilter
  } = useUserManagement();

  const handleFilterChange = (field: string, value: string) => {
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