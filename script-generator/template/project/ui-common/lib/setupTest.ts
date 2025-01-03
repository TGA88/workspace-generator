import '@testing-library/jest-dom';
import { server } from './mocks/api/server';
import { LocalStorageMock } from '@ui-exm/mocks/local-storage.mock';


global.localStorage = new LocalStorageMock();

// jest.setup.ts

// // เก็บ function ดั้งเดิมไว้
// const originalLog = console.log
// const originalInfo = console.info 
// const originalDebug = console.debug

// override console methods
global.console.log = () => {}
global.console.warn = () => {}
global.console.info = () => {}
global.console.debug = () => {}
global.console.trace = () => {}

// console.error ยังคงทำงานตามปกติ


// Establish API mocking before all tests
beforeAll(() => {
  server.listen({ onUnhandledRequest: 'error' });
});

// Reset any request handlers that we may add during the tests,
// so they don't affect other tests.
afterEach(() => {
  server.resetHandlers();
});

// Clean up after the tests are finished.
afterAll(() => {
  server.close();
});