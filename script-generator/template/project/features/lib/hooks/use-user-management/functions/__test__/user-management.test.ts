import { filterActiveUsers, calculateUserStats, filterUsersByRole } from '@feature-exm/hooks/use-user-management/functions/user-management'
import { User } from '@feature-exm/types/user.type';

describe('User Management Functions', () => {
  const mockUsers: User[] = [
    { id: 1, name: 'John', role: 'admin', isActive: true, isDeleted: false, isPremium: true, lastLoginDate: '2024-01-01' },
    { id: 2, name: 'Jane', role: 'user', isActive: false, isDeleted: false, isPremium: false, lastLoginDate: '2024-01-01' },
    { id: 3, name: 'Bob', role: 'user', isActive: true, isDeleted: true, isPremium: true, lastLoginDate: '2024-01-01' },
    { id: 4, name: 'Alice', role: 'admin', isActive: true, isDeleted: false, isPremium: false, lastLoginDate: '2024-01-01' }
  ];

  describe('filterActiveUsers', () => {
    it('should return only active and not deleted users', () => {
      const result = filterActiveUsers(mockUsers);
      expect(result).toHaveLength(2);
      expect(result.map(user => user.id)).toEqual([1, 4]);
    });

    it('should handle empty array', () => {
      const result = filterActiveUsers([]);
      expect(result).toHaveLength(0);
    });

    it('should return empty array when no users are active', () => {
      const inactiveUsers = mockUsers.map(user => ({ ...user, isActive: false }));
      const result = filterActiveUsers(inactiveUsers);
      expect(result).toHaveLength(0);
    });

    it('should exclude deleted users even if active', () => {
      const result = filterActiveUsers(mockUsers);
      expect(result.some(user => user.isDeleted)).toBe(false);
    });
  });

  describe('filterUsersByRole', () => {
    it('should filter users by role', () => {
      const adminUsers = filterUsersByRole(mockUsers, 'admin');
      expect(adminUsers).toHaveLength(2);
      expect(adminUsers.every(user => user.role === 'admin')).toBe(true);
    });

    it('should return all users when role is empty', () => {
      const result = filterUsersByRole(mockUsers, '');
      expect(result).toHaveLength(mockUsers.length);
    });

    it('should return empty array when no users match role', () => {
      const result = filterUsersByRole(mockUsers, 'manager');
      expect(result).toHaveLength(0);
    });

    it('should handle empty array', () => {
      const result = filterUsersByRole([], 'admin');
      expect(result).toHaveLength(0);
    });
  });

  describe('calculateUserStats', () => {
    beforeAll(() => {
      jest.useFakeTimers();
      jest.setSystemTime(new Date('2024-01-15'));
    });

    afterAll(() => {
      jest.useRealTimers();
    });

    it('should calculate correct stats', () => {
      const stats = calculateUserStats(mockUsers);
      expect(stats).toEqual({
        total: 4,
        active: 3,
        premium: 2,
        recentlyActive: 4 // all users have lastLoginDate within 30 days of 2024-01-15
      });
    });

    it('should handle empty array', () => {
      const stats = calculateUserStats([]);
      expect(stats).toEqual({
        total: 0,
        active: 0,
        premium: 0,
        recentlyActive: 0
      });
    });

    it('should calculate recentlyActive based on lastLoginDate', () => {
        // คำนวณย้อนหลัง 30 วันจาก 2024-01-15:
        // - 2024-01-15 - 30 วัน = 2023-12-16
        // ดังนั้น lastLoginDate ต้องมากกว่า 2023-12-16 ถึงจะถือว่า active
        const usersWithVariedDates = [
          { ...mockUsers[0], lastLoginDate: '2023-12-17' }, // within 30 days (active)
          { ...mockUsers[1], lastLoginDate: '2023-12-15' }, // more than 30 days (not active)
          { ...mockUsers[2], lastLoginDate: '2024-01-10' }, // within 30 days (active)
        ];
    
        const stats = calculateUserStats(usersWithVariedDates);
        expect(stats.recentlyActive).toBe(2);
      });
    
      // เพิ่ม test case เพื่อให้เห็นการคำนวณชัดเจนขึ้น
      it('should calculate recentlyActive with exact boundary dates', () => {
        const usersWithBoundaryDates = [
          { ...mockUsers[0], lastLoginDate: '2023-12-16' }, // exactly 30 days ago (not active)
          { ...mockUsers[1], lastLoginDate: '2023-12-17' }, // 29 days ago (active)
          { ...mockUsers[2], lastLoginDate: '2024-01-15' }, // today (active)
        ];
    
        const stats = calculateUserStats(usersWithBoundaryDates);
        expect(stats.recentlyActive).toBe(2);
      });

    it('should handle invalid lastLoginDate', () => {
      const usersWithInvalidDate = [
        { ...mockUsers[0], lastLoginDate: 'invalid-date' }
      ];

      const stats = calculateUserStats(usersWithInvalidDate);
      expect(stats.recentlyActive).toBe(0);
    });
  });

// describe('calculateUserStats', () => {
//     beforeAll(() => {
//       // Set fixed date to 2024-01-15
//       jest.useFakeTimers();
//       jest.setSystemTime(new Date('2024-01-15'));
//     });
  
//     afterAll(() => {
//       jest.useRealTimers();
//     });
  
//     it('should calculate recentlyActive based on lastLoginDate', () => {
//       // คำนวณย้อนหลัง 30 วันจาก 2024-01-15:
//       // - 2024-01-15 - 30 วัน = 2023-12-16
//       // ดังนั้น lastLoginDate ต้องมากกว่า 2023-12-16 ถึงจะถือว่า active
//       const usersWithVariedDates = [
//         { ...mockUsers[0], lastLoginDate: '2023-12-17' }, // within 30 days (active)
//         { ...mockUsers[1], lastLoginDate: '2023-12-15' }, // more than 30 days (not active)
//         { ...mockUsers[2], lastLoginDate: '2024-01-10' }, // within 30 days (active)
//       ];
  
//       const stats = calculateUserStats(usersWithVariedDates);
//       expect(stats.recentlyActive).toBe(2);
//     });
  
//     // เพิ่ม test case เพื่อให้เห็นการคำนวณชัดเจนขึ้น
//     it('should calculate recentlyActive with exact boundary dates', () => {
//       const usersWithBoundaryDates = [
//         { ...mockUsers[0], lastLoginDate: '2023-12-16' }, // exactly 30 days ago (not active)
//         { ...mockUsers[1], lastLoginDate: '2023-12-17' }, // 29 days ago (active)
//         { ...mockUsers[2], lastLoginDate: '2024-01-15' }, // today (active)
//       ];
  
//       const stats = calculateUserStats(usersWithBoundaryDates);
//       expect(stats.recentlyActive).toBe(2);
//     });
//   });
});