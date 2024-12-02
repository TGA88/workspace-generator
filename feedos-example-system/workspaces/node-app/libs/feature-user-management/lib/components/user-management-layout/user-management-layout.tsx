import React from 'react';
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
    <Stack
      className="fos-space-y-3 fos-px-3 fos-py-2 fos-bg-red-200"
      sx={{ 
        '& > *': { width: '100%' } // ให้ children ใช้พื้นที่เต็มความกว้าง
      }}
    >
      {statsComponent}
      {listComponent}
    </Stack>
  );
};