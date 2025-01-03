// hooks/__test__/use-local-storage.test.tsx
import { renderHook, act } from '@testing-library/react';
import useLocalStorage from '../use-local-storage';
import { LocalStorageMock } from '@ui-exm/mocks/local-storage.mock';

describe('useLocalStorage', () => {
  let mockStorage: LocalStorageMock;

  beforeEach(() => {
    // สร้าง instance ใหม่ของ LocalStorageMock
    mockStorage = new LocalStorageMock();
    // Mock window.localStorage ด้วย mockStorage
    Object.defineProperty(window, 'localStorage', {
      value: mockStorage,
      writable: true
    });
  });

  it('should return initial value when no stored value exists', () => {
    const { result } = renderHook(() => useLocalStorage('test-key', 'initial'));
    expect(result.current[0]).toBe('initial');
  });

  it('should return stored value when it exists', () => {
    mockStorage.setItem('test-key', JSON.stringify('stored value'));
    const { result } = renderHook(() => useLocalStorage('test-key', 'initial'));
    expect(result.current[0]).toBe('stored value');
  });

  it('should update stored value', () => {
    const { result } = renderHook(() => useLocalStorage('test-key', 'initial'));

    act(() => {
      result.current[1]('new value');
    });

    // Check hook value
    expect(result.current[0]).toBe('new value');
    
    // Check localStorage value
    expect(JSON.parse(mockStorage.getItem('test-key')!)).toBe('new value');
  });

  it('should handle storing objects', () => {
    const initialValue = { name: 'John', age: 30 };
    const { result } = renderHook(() => useLocalStorage('test-key', initialValue));

    const newValue = { name: 'Jane', age: 25 };
    act(() => {
      result.current[1](newValue);
    });

    expect(result.current[0]).toEqual(newValue);
    expect(JSON.parse(mockStorage.getItem('test-key')!)).toEqual(newValue);
  });

  it('should handle errors when localStorage is not available', () => {
    // Mock getItem method to throw error
    jest.spyOn(mockStorage, 'getItem').mockImplementationOnce(() => {
      throw new Error('localStorage not available');
    });

    const { result } = renderHook(() => useLocalStorage('test-key', 'initial'));
    expect(result.current[0]).toBe('initial');
  });

  // เพิ่ม test case สำหรับทดสอบ removeItem
  it('should handle removeItem correctly', () => {
    mockStorage.setItem('test-key', JSON.stringify('value'));
    mockStorage.removeItem('test-key');
    expect(mockStorage.getItem('test-key')).toBeNull();
  });

  // เพิ่ม test case สำหรับทดสอบ length
  it('should update length when adding and removing items', () => {
    expect(mockStorage.length).toBe(0);
    
    mockStorage.setItem('key1', 'value1');
    expect(mockStorage.length).toBe(1);
    
    mockStorage.setItem('key2', 'value2');
    expect(mockStorage.length).toBe(2);
    
    mockStorage.removeItem('key1');
    expect(mockStorage.length).toBe(1);
  });
});