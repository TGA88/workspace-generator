// src/test/setup.ts
import '@testing-library/jest-dom'
import { server } from '../mocks/server'

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