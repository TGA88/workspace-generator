import { renderHook, act } from '@testing-library/react';
import useLocalStorage  from '../use-local-storage';

describe('useLocalStorage', () => {
  beforeEach(() => {
    // Clear localStorage before each test
    window.localStorage.clear();
  });

  it('should return initial value when no stored value exists', () => {
    const { result } = renderHook(() => useLocalStorage('test-key', 'initial'));
    expect(result.current[0]).toBe('initial');
  });

  it('should return stored value when it exists', () => {
    window.localStorage.setItem('test-key', JSON.stringify('stored value'));
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
    expect(JSON.parse(window.localStorage.getItem('test-key')!)).toBe('new value');
  });

  it('should handle storing objects', () => {
    const initialValue = { name: 'John', age: 30 };
    const { result } = renderHook(() => useLocalStorage('test-key', initialValue));

    const newValue = { name: 'Jane', age: 25 };
    act(() => {
      result.current[1](newValue);
    });

    expect(result.current[0]).toEqual(newValue);
    expect(JSON.parse(window.localStorage.getItem('test-key')!)).toEqual(newValue);
  });

  it('should handle errors when localStorage is not available', () => {
    // Mock localStorage.getItem to throw error
    const mockGetItem = jest.spyOn(Storage.prototype, 'getItem');
    mockGetItem.mockImplementationOnce(() => {
      throw new Error('localStorage not available');
    });

    const { result } = renderHook(() => useLocalStorage('test-key', 'initial'));
    expect(result.current[0]).toBe('initial');

    mockGetItem.mockRestore();
  });
});