import { UserState, UserAction } from '@feature-user-management/types/user.type';

export const userReducer = (state: UserState, action: UserAction): UserState => {
  switch (action.type) {
    case 'SET_USERS':
      return { ...state, users: action.payload };
      
    case 'SELECT_USER':
      return { ...state, selectedUser: action.payload };
      
    case 'UPDATE_USER':
      return {
        ...state,
        users: state.users.map(user => 
          user.id === action.payload.id ? action.payload : user
        )
      };
      
    case 'DELETE_USER':
      return {
        ...state,
        users: state.users.filter(user => user.id !== action.payload),
        selectedUser: state.selectedUser?.id === action.payload ? null : state.selectedUser
      };
      
    case 'SET_FILTER':
      return {
        ...state,
        filters: { ...state.filters, ...action.payload }
      };
      
    default:
      return state;
  }
};