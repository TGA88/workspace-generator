
import { renderHook, act } from '@testing-library/react';
import  useDebounce  from '../use-debounce';

describe('useDebounce', () => {
  jest.useFakeTimers();

  it('should return initial value immediately', () => {
    const { result } = renderHook(() => useDebounce('initial value', 500));
    expect(result.current).toBe('initial value');
  });

  it('should update value after delay', () => {
    const { result, rerender } = renderHook(
      ({ value, delay }) => useDebounce(value, delay),
      {
        initialProps: { value: 'initial value', delay: 500 }
      }
    );

    // Update the value
    rerender({ value: 'updated value', delay: 500 });

    // Value should not have changed yet
    expect(result.current).toBe('initial value');

    // Fast-forward time
    act(() => {
      jest.advanceTimersByTime(500);
    });

    // Now the value should be updated
    expect(result.current).toBe('updated value');
  });

  it('should cancel previous timer on new update', () => {
    const { result, rerender } = renderHook(
      ({ value, delay }) => useDebounce(value, delay),
      {
        initialProps: { value: 'initial value', delay: 500 }
      }
    );

    // First update
    rerender({ value: 'first update', delay: 500 });
    
    // Advance time partially
    act(() => {
      jest.advanceTimersByTime(250);
    });

    // Second update before first one completes
    rerender({ value: 'second update', delay: 500 });

    // Advance time to when first update would have completed
    act(() => {
      jest.advanceTimersByTime(250);
    });

    // Value should not be from first update
    expect(result.current).not.toBe('first update');

    // Complete second update timer
    act(() => {
      jest.advanceTimersByTime(250);
    });

    // Now should have second update value
    expect(result.current).toBe('second update');
  });
});