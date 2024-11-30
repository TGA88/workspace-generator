import React from 'react';
import Paper from '@mui/material/Paper';
import Grid from '@mui/material/Grid';
import Typography from '@mui/material/Typography';
import Box from '@mui/material/Box';

interface UserStatsProps {
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
        <Grid container spacing={2}>
          <Grid item xs={3}>
            <Typography variant="h6">Total Users</Typography>
            <Typography variant="h4">{stats.total}</Typography>
          </Grid>
          <Grid item xs={3}>
            <Typography variant="h6">Active Users</Typography>
            <Typography variant="h4">{stats.active}</Typography>
          </Grid>
          <Grid item xs={3}>
            <Typography variant="h6">Premium Users</Typography>
            <Typography variant="h4">{stats.premium}</Typography>
          </Grid>
          <Grid item xs={3}>
            <Typography variant="h6">Recently Active</Typography>
            <Typography variant="h4">{stats.recentlyActive}</Typography>
          </Grid>
        </Grid>
      </Box>
    </Paper>
  );
};