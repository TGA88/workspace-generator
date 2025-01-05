import '@testing-library/jest-dom';
import '@testing-library/jest-dom/extend-expect';


// Mock Next.js router
jest.mock('next/router', () => ({
  useRouter() {
    return {
      route: '/',
      pathname: '',
      query: {},
      asPath: '',
      push: jest.fn(),
      replace: jest.fn(),
      reload: jest.fn(),
      back: jest.fn(),
      prefetch: jest.fn(),
      beforePopState: jest.fn(),
      events: {
        on: jest.fn(),
        off: jest.fn(),
        emit: jest.fn(),
      },
    };
  },
}));

// Mock next/image
jest.mock('next/image', () => ({
  __esModule: true,
  default: (props: any) => {
    // eslint-disable-next-line @next/next/no-img-element
    return <img {...props} alt={props.alt} />;
  },
}));



// import { server } from './mocks/server';

// // Establish API mocking before all tests
// beforeAll(() => {
//   server.listen({ onUnhandledRequest: 'error' });
// });

// // Reset any request handlers that we may add during the tests,
// // so they don't affect other tests.
// afterEach(() => {
//   server.resetHandlers();
// });

// // Clean up after the tests are finished.
// afterAll(() => {
//   server.close();
// });