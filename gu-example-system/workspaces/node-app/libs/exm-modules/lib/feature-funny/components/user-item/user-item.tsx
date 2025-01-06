
import React from 'react';
import ListItem from '@mui/material/ListItem';
import ListItemAvatar from '@mui/material/ListItemAvatar';
import ListItemText from '@mui/material/ListItemText';
import Avatar from '@mui/material/Avatar';
import { UserItemProps } from './user-item.type';

export const UserItem: React.FC<UserItemProps> = ({ user }) => {
  return (
    <ListItem
      sx={{
        mb: 1,
        bgcolor: 'background.paper',
        borderRadius: 1,
        boxShadow: 1,
        '&:hover': {
          boxShadow: 2,
          transform: 'translateY(-2px)',
          transition: 'all 0.3s ease'
        }
      }}
    >
      <ListItemAvatar>
        <Avatar sx={{ bgcolor: 'primary.main' }}>
          {user.name.charAt(0).toUpperCase()}
        </Avatar>
      </ListItemAvatar>
      <ListItemText
        primary={user.name}
        secondary={`ID: ${user.id}`}
      />
    </ListItem>
  );
};