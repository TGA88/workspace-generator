import React from 'react';
// import Box from '@mui/material/Box';
import Stack from '@mui/material/Stack';

export interface UserManagementLayoutProps {
  statsComponent: React.ReactNode;
  listComponent: React.ReactNode;
}

export const UserManagementLayout: React.FC<UserManagementLayoutProps> = ({ 
  statsComponent, 
  listComponent 
}) => {
  return (
    <Stack spacing={3} px={3} py={2}>
      {statsComponent}
      {listComponent}
    </Stack>
  );
};