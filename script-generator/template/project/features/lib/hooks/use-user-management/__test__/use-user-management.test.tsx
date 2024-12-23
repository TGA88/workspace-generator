import { renderHook, act } from '@testing-library/react';
import { useUserManagement } from '@feature-exm/hooks/use-user-management/use-user-management'
import * as userManagementFunctions from '@feature-exm/hooks/use-user-management/functions/user-management';

// Mock the pure functions
jest.mock('../functions/user-management');

describe('useUserManagement - Unit Tests', () => {
  const mockFilterActiveUsers = jest.spyOn(userManagementFunctions, 'filterActiveUsers');
  const mockCalculateUserStats = jest.spyOn(userManagementFunctions, 'calculateUserStats');

  beforeEach(() => {
    mockFilterActiveUsers.mockImplementation((users) => users.filter(u => u.isActive));
    mockCalculateUserStats.mockImplementation(() => ({
      total: 2,
      active: 1,
      premium: 1,
      recentlyActive: 1
    }));
  });

  it('should filter active users correctly', () => {
    const { result } = renderHook(() => useUserManagement());

    act(() => {
      result.current.setFilter({ status: 'active' });
    });

    expect(mockFilterActiveUsers).toHaveBeenCalled();
  });

  it('should calculate stats correctly', () => {
    const { result } = renderHook(() => useUserManagement());
    expect(mockCalculateUserStats).toHaveBeenCalled();
    expect(result.current.stats).toEqual({
      total: 2,
      active: 1,
      premium: 1,
      recentlyActive: 1
    });
  });
});