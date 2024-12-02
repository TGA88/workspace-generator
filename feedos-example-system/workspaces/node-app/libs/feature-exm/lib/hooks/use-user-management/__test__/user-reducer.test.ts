import { userReducer } from '@feature-exm/hooks/use-user-management/user-reducer'
import { UserState, UserAction } from '@feature-exm/types/user.type'

describe('userReducer', () => {
  // Setup initial state for testing
  const initialState: UserState = {
    users: [],
    selectedUser: null,
    filters: {
      status: 'all',
      role: ''
    }
  };

  const mockUser = {
    id: 1,
    name: 'John Doe',
    role: 'admin',
    isActive: true,
    isDeleted: false,
    isPremium: true,
    lastLoginDate: '2024-01-01'
  };

  const mockUsers = [
    mockUser,
    {
      id: 2,
      name: 'Jane Smith',
      role: 'user',
      isActive: false,
      isDeleted: false,
      isPremium: false,
      lastLoginDate: '2024-01-01'
    }
  ];

  describe('SET_USERS action', () => {
    it('should set users array', () => {
      const action: UserAction = {
        type: 'SET_USERS',
        payload: mockUsers
      };

      const newState = userReducer(initialState, action);

      expect(newState.users).toEqual(mockUsers);
      expect(newState.selectedUser).toBeNull();
      expect(newState.filters).toEqual(initialState.filters);
    });
  });

  describe('SELECT_USER action', () => {
    it('should set selected user', () => {
      const action: UserAction = {
        type: 'SELECT_USER',
        payload: mockUser
      };

      const newState = userReducer(initialState, action);

      expect(newState.selectedUser).toEqual(mockUser);
      expect(newState.users).toEqual(initialState.users);
    });
  });

  describe('UPDATE_USER action', () => {
    it('should update existing user', () => {
      const stateWithUsers = {
        ...initialState,
        users: mockUsers
      };

      const updatedUser = {
        ...mockUser,
        name: 'John Updated'
      };

      const action: UserAction = {
        type: 'UPDATE_USER',
        payload: updatedUser
      };

      const newState = userReducer(stateWithUsers, action);

      expect(newState.users[0].name).toBe('John Updated');
      expect(newState.users[1]).toEqual(mockUsers[1]);
    });

    it('should not modify state if user not found', () => {
      const stateWithUsers = {
        ...initialState,
        users: mockUsers
      };

      const nonExistentUser = {
        ...mockUser,
        id: 999
      };

      const action: UserAction = {
        type: 'UPDATE_USER',
        payload: nonExistentUser
      };

      const newState = userReducer(stateWithUsers, action);

      expect(newState).toEqual(stateWithUsers);
    });
  });

  describe('DELETE_USER action', () => {
    it('should delete user', () => {
      const stateWithUsers = {
        ...initialState,
        users: mockUsers
      };

      const action: UserAction = {
        type: 'DELETE_USER',
        payload: 1
      };

      const newState = userReducer(stateWithUsers, action);

      expect(newState.users).toHaveLength(1);
      expect(newState.users[0].id).toBe(2);
    });

    it('should clear selectedUser if deleted user was selected', () => {
      const stateWithSelectedUser = {
        ...initialState,
        users: mockUsers,
        selectedUser: mockUser
      };

      const action: UserAction = {
        type: 'DELETE_USER',
        payload: 1
      };

      const newState = userReducer(stateWithSelectedUser, action);

      expect(newState.selectedUser).toBeNull();
    });

    it('should keep selectedUser if different user was deleted', () => {
      const stateWithSelectedUser = {
        ...initialState,
        users: mockUsers,
        selectedUser: mockUser
      };

      const action: UserAction = {
        type: 'DELETE_USER',
        payload: 2
      };

      const newState = userReducer(stateWithSelectedUser, action);

      expect(newState.selectedUser).toEqual(mockUser);
    });
  });

  describe('SET_FILTER action', () => {
    it('should update single filter', () => {
      const action: UserAction = {
        type: 'SET_FILTER',
        payload: { status: 'active' }
      };

      const newState = userReducer(initialState, action);

      expect(newState.filters.status).toBe('active');
      expect(newState.filters.role).toBe(initialState.filters.role);
    });

    it('should update multiple filters', () => {
      const action: UserAction = {
        type: 'SET_FILTER',
        payload: { status: 'inactive', role: 'admin' }
      };

      const newState = userReducer(initialState, action);

      expect(newState.filters).toEqual({
        status: 'inactive',
        role: 'admin'
      });
    });
  });

  describe('state immutability', () => {
    it('should not modify original state', () => {
      const action: UserAction = {
        type: 'SET_USERS',
        payload: mockUsers
      };

      const newState = userReducer(initialState, action);

      expect(newState).not.toBe(initialState);
      expect(initialState.users).toEqual([]);
    });
  });
});