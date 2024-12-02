import { useReducer, useEffect, useMemo, useCallback, useState } from 'react';
import { User, UserState } from '@feature-exm/types/user.type';
import { userReducer } from './user-reducer';
import { filterActiveUsers, calculateUserStats, filterUsersByRole } from './functions/user-management'
// import { filterActiveUsers } from './logic/filterActiveUsers';
// import { filterActiveUsers, calculateUserStats, filterUsersByRole } from './logic/userManagement';
// import { filterActiveUsers, calculateUserStats, filterUsersByRole } from './logic/userManagement';

const initialState: UserState = {
    users: [],
    selectedUser: null,
    filters: {
        status: 'all',
        role: ''
    }
};

export const useUserManagement = () => {
    const [state, dispatch] = useReducer(userReducer, initialState);
    const [error, setError] = useState<Error | null>(null);

    // Fetch users
    useEffect(() => {
        const fetchUsers = async () => {
            try {
                const response = await fetch('/api/users');
                if (!response.ok) {
                    throw new Error(`HTTP error! status: ${response.status}`);
                }
                const data = await response.json();
                dispatch({ type: 'SET_USERS', payload: data });
                setError(null);
            } catch (error) {
                if (error instanceof Error) {
                    setError(error);
                } else {
                    setError(new Error('An unknown error occurred'));
                }
            };
        }

        fetchUsers();
    }, []);

    // Computed values
    const filteredUsers = useMemo(() => {
        let result = state.users;
        if (state.filters.status === 'active') {
            result = filterActiveUsers(result);
        }
        return filterUsersByRole(result, state.filters.role);
    }, [state.users, state.filters]);

    const stats = useMemo(() =>
        calculateUserStats(state.users),
        [state.users]
    );

    // Actions
    const selectUser = useCallback((user: User) => {
        dispatch({ type: 'SELECT_USER', payload: user });
    }, []);

    const updateUser = useCallback(async (user: User) => {
        try {
            const response = await fetch(`/api/users/${user.id}`, {
                method: 'PUT',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(user)
            });
            if (!response.ok) throw new Error('Failed to update user');
            dispatch({ type: 'UPDATE_USER', payload: user });
            setError(null);
        } catch (error) {
          if (error instanceof Error) {
            setError(error);
          } else {
            setError(new Error('An unknown error occurred'));
          }
        }
    }, []);

    const deleteUser = useCallback(async (userId: number) => {
        try {
            const response = await fetch(`/api/users/${userId}`, {
                method: 'DELETE'
            });
            if (!response.ok) throw new Error('Failed to delete user');
            dispatch({ type: 'DELETE_USER', payload: userId });
            setError(null);
        } catch (error) {
            //   console.error('Error deleting user:', error);
            if (error instanceof Error) {
                setError(error);
            } else {
                setError(new Error('An unknown error occurred'));
            }
        }
    }, []);

    const setFilter = useCallback((filter: Partial<UserState['filters']>) => {
        dispatch({ type: 'SET_FILTER', payload: filter });
    }, []);

    return {
        users: filteredUsers,
        selectedUser: state.selectedUser,
        filters: state.filters,
        stats,
        selectUser,
        updateUser,
        deleteUser,
        setFilter,
        error
    };
};