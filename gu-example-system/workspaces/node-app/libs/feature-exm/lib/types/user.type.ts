export interface User {
    id: number;
    name: string;
    isActive: boolean;
    isDeleted: boolean;
    isPremium: boolean;
    lastLoginDate: string;
    role: string;
  }
  
  export interface UserState {
    users: User[];
    selectedUser: User | null;
    filters: {
      status: 'active' | 'inactive' | 'all';
      role: string;
    };
  }
  
  export type UserAction =
    | { type: 'SET_USERS'; payload: User[] }
    | { type: 'SELECT_USER'; payload: User }
    | { type: 'UPDATE_USER'; payload: User }
    | { type: 'DELETE_USER'; payload: number }
    | { type: 'SET_FILTER'; payload: Partial<UserState['filters']> };