
import { PrismaClient } from '@prisma/exm-data-client';
import { mockDeep, mockReset, DeepMockProxy } from 'jest-mock-extended';

import { getPrismaInstance } from './dbclient';

jest.mock('./dbclient', () => ({
  __esModule: true,
  default: mockDeep<PrismaClient>(),
}));

beforeEach(() => {
  mockReset(prismaMock);
});

export const prismaMock = getPrismaInstance() as unknown as DeepMockProxy<PrismaClient>;
