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
      className="fos-space-y-b4-6 fos-px-b4-20 fos-py-b4-2 fos-bg-red-200"
      sx={{ 
        '& > *': { width: '100%' } // ให้ children ใช้พื้นที่เต็มความกว้าง
      }}
    >
      {statsComponent}
      {listComponent}
    </Stack>
  );
};