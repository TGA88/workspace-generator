import React from 'react';
import Table from '@mui/material/Table';
import TableBody from '@mui/material/TableBody';
import TableCell from '@mui/material/TableCell';
import TableContainer from '@mui/material/TableContainer';
import TableHead from '@mui/material/TableHead';
import TableRow from '@mui/material/TableRow';
import Paper from '@mui/material/Paper';
import IconButton from '@mui/material/IconButton';
import DeleteIcon from '@mui/icons-material/Delete';
import Select from '@mui/material/Select';
import MenuItem from '@mui/material/MenuItem';
import FormControl from '@mui/material/FormControl';
import InputLabel from '@mui/material/InputLabel';
// import Box from '@mui/material/Box';
import Chip from '@mui/material/Chip';
import Stack from '@mui/material/Stack';
import { User } from '../../types/user.type';

export interface UserListProps {
  users: User[];
  filters: {
    status: 'active' | 'inactive' | 'all';
    role: string;
  };
  onFilterChange: (field: string, value: string) => void;
  onSelectUser: (user: User) => void;
  onDeleteUser: (userId: number) => void;
}

export const UserList: React.FC<UserListProps> = ({
  users,
  filters,
  onFilterChange,
  onSelectUser,
  onDeleteUser
}) => {
  return (
    <Paper sx={{ width: '100%', overflow: 'hidden' }}>
      <Stack direction="row" spacing={2} sx={{ p: 2 }}>
        <FormControl size="small" sx={{ minWidth: 120 }}>
          <InputLabel id="status-label">Status</InputLabel>
          <Select
            labelId="status-label"
            id="status-select"
            value={filters.status}
            label="Status"
            onChange={(e) => onFilterChange('status', e.target.value)}
            aria-label="Status filter"
          >
            <MenuItem value="all">All</MenuItem>
            <MenuItem value="active">Active</MenuItem>
            <MenuItem value="inactive">Inactive</MenuItem>
          </Select>
        </FormControl>

        <FormControl size="small" sx={{ minWidth: 120 }}>
          <InputLabel id="role-label">Role</InputLabel>
          <Select
            labelId="role-label"
            id="role-select"
            value={filters.role}
            label="Role"
            onChange={(e) => onFilterChange('role', e.target.value)}
            aria-label="Role filter"
          >
            <MenuItem value="">All</MenuItem>
            <MenuItem value="admin">Admin</MenuItem>
            <MenuItem value="user">User</MenuItem>
          </Select>
        </FormControl>
      </Stack>

      <TableContainer>
        <Table aria-label="users table">
          <TableHead>
            <TableRow>
              <TableCell>Name</TableCell>
              <TableCell>Role</TableCell>
              <TableCell>Status</TableCell>
              <TableCell align="center">Premium</TableCell>
              <TableCell>Last Active</TableCell>
              <TableCell align="right">Actions</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {users.map((user) => (
              <TableRow
                key={user.id}
                hover
                onClick={() => onSelectUser(user)}
                sx={{ cursor: 'pointer' }}
              >
                <TableCell component="th" scope="row">
                  {user.name}
                </TableCell>
                <TableCell>
                  <Chip
                    label={user.role}
                    color={user.role === 'admin' ? 'primary' : 'default'}
                    size="small"
                  />
                </TableCell>
                <TableCell>
                  <Chip
                    label={user.isActive ? 'Active' : 'Inactive'}
                    color={user.isActive ? 'success' : 'default'}
                    size="small"
                  />
                </TableCell>
                <TableCell align="center">
                  {user.isPremium ? '✓' : '-'}
                </TableCell>
                <TableCell>
                  {new Date(user.lastLoginDate).toLocaleDateString()}
                </TableCell>
                <TableCell align="right">
                  <IconButton
                    aria-label="delete user"
                    onClick={(e) => {
                      e.stopPropagation();
                      onDeleteUser(user.id);
                    }}
                    size="small"
                  >
                    <DeleteIcon />
                  </IconButton>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </TableContainer>
    </Paper>
  );
};

export default UserList;