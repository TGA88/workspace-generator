import React from 'react';
import Paper from '@mui/material/Paper';
import Stack from '@mui/material/Stack';
import Typography from '@mui/material/Typography';
import Box from '@mui/material/Box';

export interface UserStatsProps {
  stats: {
    total: number;
    active: number;
    premium: number;
    recentlyActive: number;
  };
}

export const UserStats: React.FC<UserStatsProps> = ({ stats }) => {
  return (
    <Paper>
      <Box sx={{ p: 2 }}>
        <Stack 
          direction="row" 
          spacing={2} 
          sx={{ 
            width: '100%',
            justifyContent: 'space-between' 
          }}
        >
          <Box>
            <Typography variant="h6" className='fos-text-red-500'>Total Users</Typography>
            <Typography variant="h4">{stats.total}</Typography>
          </Box>
          <Box>
            <Typography variant="h6">Active Users</Typography>
            <Typography variant="h4">{stats.active}</Typography>
          </Box>
          <Box>
            <Typography variant="h6">Premium Users</Typography>
            <Typography variant="h4">{stats.premium}</Typography>
          </Box>
          <Box>
            <Typography variant="h6">Recently Active</Typography>
            <Typography variant="h4">{stats.recentlyActive}</Typography>
          </Box>
        </Stack>
      </Box>
    </Paper>
  );
};