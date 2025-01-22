// import { render } from '@testing-library/react';
import '@testing-library/jest-dom';
import { useRouter } from 'next/router';
// import Image from 'next/image';

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

// jest.mock('next/image', () => {
//     const MockImage = (props: JSX.IntrinsicElements['img']) => <img {...props} />;
//     MockImage.displayName = 'MockImage';
//     return MockImage;
// });

describe('Mock Next.js router', () => {
    it('should mock useRouter correctly', () => {
        const router = useRouter();
        expect(router.route).toBe('/');
        // expect(router.push).toBeInstanceOf(Function);
        // expect(router.replace).toBeInstanceOf(Function);
        // expect(router.reload).toBeInstanceOf(Function);
        // expect(router.back).toBeInstanceOf(Function);
        // expect(router.prefetch).toBeInstanceOf(Function);
        // expect(router.beforePopState).toBeInstanceOf(Function);
        // expect(router.events.on).toBeInstanceOf(Function);
        // expect(router.events.off).toBeInstanceOf(Function);
        // expect(router.events.emit).toBeInstanceOf(Function);
    });

    it('should call push method', () => {
        const router = useRouter();
        router.push('/new-route');
        expect(router.push).toHaveBeenCalledWith('/new-route');
    });
});