// hooks/__test__/use-click-outside.test.tsx
import { renderHook } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import useClickOutside  from '../use-click-outside';

describe('useClickOutside', () => {
  let container: HTMLDivElement;
  let handler: jest.Mock;
  let user: ReturnType<typeof userEvent.setup>;

  beforeEach(() => {
    // Setup user event
    user = userEvent.setup();
    // Setup container and handler
    container = document.createElement('div');
    document.body.appendChild(container);
    handler = jest.fn();
  });

  afterEach(() => {
    document.body.removeChild(container);
    jest.clearAllMocks();
  });

  it('should call handler when clicking outside', async () => {
    const ref = { current: container };
    renderHook(() => useClickOutside(ref, handler));

    // Click outside using userEvent
    await user.click(document.body);
    
    expect(handler).toHaveBeenCalledTimes(1);
  });

  it('should not call handler when clicking inside', async () => {
    const ref = { current: container };
    renderHook(() => useClickOutside(ref, handler));

    // Click inside using userEvent
    await user.click(container);
    
    expect(handler).not.toHaveBeenCalled();
  });

  it('should handle touch events', async () => {
    const ref = { current: container };
    renderHook(() => useClickOutside(ref, handler));

    // Simulate touch outside
    await user.pointer({ keys: '[TouchA>]', target: document.body });
    
    expect(handler).toHaveBeenCalledTimes(1);

    // Simulate touch inside
    await user.pointer({ keys: '[TouchA>]', target: container });
    
    expect(handler).toHaveBeenCalledTimes(1); // Still 1 from previous call
  });

  it('should handle null ref', async () => {
    const ref = { current: null };
    renderHook(() => useClickOutside(ref, handler));

    // Click outside
    await user.click(document.body);
    
    expect(handler).toHaveBeenCalled();
  });

  it('should clean up event listeners on unmount', () => {
    const ref = { current: container };
    const removeEventListenerSpy = jest.spyOn(document, 'removeEventListener');

    const { unmount } = renderHook(() => useClickOutside(ref, handler));
    unmount();

    expect(removeEventListenerSpy).toHaveBeenCalledTimes(2); // mousedown and touchstart
    removeEventListenerSpy.mockRestore();
  });
});