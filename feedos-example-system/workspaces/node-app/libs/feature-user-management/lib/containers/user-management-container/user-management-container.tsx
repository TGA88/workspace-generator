import React from 'react';
// import { UserList } from '../../components/user-list/user-list';
// import { UserList } from '@components/user-list/user-list'
import { UserList } from '@root/workspaces/node-app/libs/feature-user-management/lib/components/user-list/user-list'
import { UserStats } from '@feature-user-management/components/user-stats/user-stats';
import { UserManagementLayout } from '@feature-user-management/components/user-management-layout/user-management-layout';
import { useUserManagement } from '@feature-user-management/hooks/use-user-management/use-user-management';

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