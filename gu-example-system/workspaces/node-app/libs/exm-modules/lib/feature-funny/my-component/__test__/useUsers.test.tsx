// src/hooks/useUsers.test.ts
import { renderHook, waitFor } from '@testing-library/react'
import { useUsers } from '../hooks/useUsers'
import { server } from '@feature-funny/mocks/server'
import { http, HttpResponse } from 'msw'



beforeAll(() => {
  // Enable API mocking
  server.listen({ onUnhandledRequest: 'error' })
})

afterEach(() => {
  // Reset handlers between tests
  server.resetHandlers()
})

afterAll(() => {
  // Clean up after tests
  server.close()
})

describe('useUsers', () => {
  test('should fetch users successfully', async () => {
    const { result } = renderHook(() => useUsers())

    // Check initial state
    expect(result.current.loading).toBe(true)
    expect(result.current.users).toEqual([])
    expect(result.current.error).toBeNull()

    // Wait for data to load
    await waitFor(() => {
      expect(result.current.loading).toBe(false)
    })

    // Check loaded state
    expect(result.current.users).toEqual([
      { id: 1, name: 'John' },
      { id: 2, name: 'Jane' }
    ])
    expect(result.current.error).toBeNull()
  })

  test('should handle error', async () => {
    // Override handler for this test
    server.use(
      http.get('/api/users', () => {
        return new HttpResponse(null, { status: 500 })
      })
    )

    const { result } = renderHook(() => useUsers())

    await waitFor(() => {
      expect(result.current.loading).toBe(false)
    })

    expect(result.current.users).toEqual([])
    expect(result.current.error).toBeTruthy()
  })
})