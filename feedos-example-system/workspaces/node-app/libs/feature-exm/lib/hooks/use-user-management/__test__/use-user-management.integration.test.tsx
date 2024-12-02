import { renderHook, act, waitFor } from '@testing-library/react';
import { http, HttpResponse } from 'msw';
import { server } from '@feature-exm/mocks/server';
import { useUserManagement } from '@feature-exm/hooks/use-user-management/use-user-management';
import { User } from '@feature-exm/types/user.type';

describe('useUserManagement Integration Tests', () => {
  const mockUsers: User[] = [
    { id: 1, name: 'John', role: 'admin', isActive: true, isDeleted: false, isPremium: true, lastLoginDate: '2024-01-01' },
    { id: 2, name: 'Jane', role: 'user', isActive: false, isDeleted: false, isPremium: false, lastLoginDate: '2024-01-01' },
    { id: 3, name: 'Bob', role: 'user', isActive: true, isDeleted: false, isPremium: true, lastLoginDate: '2024-01-01' }
  ];
  // Setup default handler before each test
  beforeAll(() => {
    server.listen({ onUnhandledRequest: 'warn' });
  });

  beforeEach(() => {
    // Reset handlers to default state before each test
    server.resetHandlers();
    // Setup default handler
    server.use(
      http.get('/api/users', () => {
        return HttpResponse.json(mockUsers);
      })
    );
  });

  afterEach(() => {
    jest.restoreAllMocks();
  });

  afterAll(() => {
    server.close();
  });

  describe('Fetching Users', () => {
    it('should fetch users successfully', async () => {
      const { result } = renderHook(() => useUserManagement());

      expect(result.current.users).toEqual([]);

      await waitFor(() => {
        expect(result.current.users).toHaveLength(3);
      });

      expect(result.current.users).toEqual(mockUsers);
    });

    it('should handle fetch error', async () => {
      server.use(
        http.get('/api/users', () => {
          return new HttpResponse(null, { status: 500 });
        })
      );

      const { result } = renderHook(() => useUserManagement());

      await waitFor(() => {
        expect(result.current.users).toEqual([]);
      });
    });
  });

  describe('Filtering Users', () => {
    it('should filter active users', async () => {
      const { result } = renderHook(() => useUserManagement());

      await waitFor(() => {
        expect(result.current.users).toHaveLength(3);
      });

      act(() => {
        result.current.setFilter({ status: 'active' });
      });

      expect(result.current.users).toHaveLength(2);
      expect(result.current.users.every(user => user.isActive)).toBe(true);
    });

    it('should filter by role', async () => {
      const { result } = renderHook(() => useUserManagement());

      await waitFor(() => {
        expect(result.current.users).toHaveLength(3);
      });

      act(() => {
        result.current.setFilter({ role: 'admin' });
      });

      expect(result.current.users).toHaveLength(1);
      expect(result.current.users[0].role).toBe('admin');
    });

    it('should handle multiple filters', async () => {
      const { result } = renderHook(() => useUserManagement());

      await waitFor(() => {
        expect(result.current.users).toHaveLength(3);
      });

      act(() => {
        result.current.setFilter({ status: 'active', role: 'user' });
      });

      expect(result.current.users).toHaveLength(1);
      expect(result.current.users[0].name).toBe('Bob');
    });
  });

  describe('User Selection', () => {
    it('should select a user', async () => {
      const { result } = renderHook(() => useUserManagement());

      await waitFor(() => {
        expect(result.current.users).toHaveLength(3);
      });

      act(() => {
        result.current.selectUser(mockUsers[0]);
      });

      expect(result.current.selectedUser).toEqual(mockUsers[0]);
    });
  });

  describe('Updating User', () => {
    it('should update user successfully', async () => {
      server.use(
        http.put('/api/users/1', async () => {
          return HttpResponse.json({
            ...mockUsers[0],
            name: 'John Updated'
          });
        })
      );

      const { result } = renderHook(() => useUserManagement());

      await waitFor(() => {
        expect(result.current.users).toHaveLength(3);
      });

      await act(async () => {
        await result.current.updateUser({
          ...mockUsers[0],
          name: 'John Updated'
        });
      });

      expect(result.current.users[0].name).toBe('John Updated');
    });

    it('should handle update error', async () => {
      server.use(
        http.put('/api/users/1', () => {
          return new HttpResponse(null, { status: 500 });
        })
      );

      const { result } = renderHook(() => useUserManagement());

      await waitFor(() => {
        expect(result.current.users).toHaveLength(3);
      });

      await act(async () => {
        await result.current.updateUser({
          ...mockUsers[0],
          name: 'John Updated'
        });
      });

      expect(result.current.users[0].name).toBe('John');
    });
  });

  describe('Deleting User', () => {
    it('should delete user successfully', async () => {
      server.use(
        http.delete('/api/users/1', () => {
          return HttpResponse.json({ success: true });
        })
      );

      const { result } = renderHook(() => useUserManagement());

      await waitFor(() => {
        expect(result.current.users).toHaveLength(3);
      });

      await act(async () => {
        await result.current.deleteUser(1);
      });

      expect(result.current.users).toHaveLength(2);
      expect(result.current.users.find(user => user.id === 1)).toBeUndefined();
    });

    it('should handle delete error', async () => {
      server.use(
        http.delete('/api/users/1', () => {
          return new HttpResponse(null, { status: 500 });
        })
      );

      const { result } = renderHook(() => useUserManagement());

      await waitFor(() => {
        expect(result.current.users).toHaveLength(3);
      });

      await act(async () => {
        await result.current.deleteUser(1);
      });

      expect(result.current.users).toHaveLength(3);
    });

    it('should clear selectedUser if deleted user was selected', async () => {
      server.use(
        http.delete('/api/users/1', () => {
          return HttpResponse.json({ success: true });
        })
      );

      const { result } = renderHook(() => useUserManagement());

      await waitFor(() => {
        expect(result.current.users).toHaveLength(3);
      });

      act(() => {
        result.current.selectUser(mockUsers[0]);
      });

      await act(async () => {
        await result.current.deleteUser(1);
      });

      expect(result.current.selectedUser).toBeNull();
    });
  });

//   describe('Stats Calculation', () => {
//     it('should calculate correct stats', async () => {
//       const { result } = renderHook(() => useUserManagement());

//       await waitFor(() => {
//         expect(result.current.users).toHaveLength(3);
//       });

//       expect(result.current.stats).toEqual({
//         total: 3,
//         active: 2,
//         premium: 2,
//         recentlyActive: 3
//       });
//     });
//   });

describe('Stats Calculation', () => {
    it('should calculate correct stats', async () => {
      // Mock current date to be fixed
      jest.useFakeTimers();
      jest.setSystemTime(new Date('2024-01-15'));
  
      const { result } = renderHook(() => useUserManagement());
  
      await waitFor(() => {
        expect(result.current.users).toHaveLength(3);
      });
  
      expect(result.current.stats).toEqual({
        total: 3,
        active: 2,
        premium: 2,
        recentlyActive: 3  // จะเป็น 3 เพราะทุก user มี lastLoginDate เป็น '2024-01-01'
                           // ซึ่งอยู่ในช่วง 30 วันจาก mock date (2024-01-15)
      });
  
      jest.useRealTimers(); // คืนค่า timer กลับเป็นค่าจริง
    });
  
    // เพิ่ม test case เพื่อทดสอบกรณีที่ user ไม่ active ในช่วง 30 วัน
    it('should calculate recentlyActive correctly for older dates', async () => {
      jest.useFakeTimers();
      jest.setSystemTime(new Date('2024-03-15')); // set date to future
  
      // Override mock users with older lastLoginDate
      server.use(
        http.get('/api/users', () => {
          return HttpResponse.json([
            { ...mockUsers[0], lastLoginDate: '2024-01-01' }, // older than 30 days
            { ...mockUsers[1], lastLoginDate: '2024-03-10' }, // within 30 days
            { ...mockUsers[2], lastLoginDate: '2024-01-15' }  // older than 30 days
          ]);
        })
      );
  
      const { result } = renderHook(() => useUserManagement());
  
      await waitFor(() => {
        expect(result.current.users).toHaveLength(3);
      });
  
      expect(result.current.stats).toEqual({
        total: 3,
        active: 2,
        premium: 2,
        recentlyActive: 1  // only one user logged in within last 30 days
      });
  
      jest.useRealTimers();
    });
  });
});