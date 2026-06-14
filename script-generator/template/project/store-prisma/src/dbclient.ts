import { PrismaClient as GenPrismaClient, Prisma as GenPrisma } from '../generated/client/client';

export type PrismaClient = GenPrismaClient;
export const Prisma = GenPrisma;

let prismaClient: PrismaClient | null = null;

export function getPrismaInstance(): PrismaClient {
  if (prismaClient) return prismaClient;
  prismaClient = new GenPrismaClient({ log: ['info'] });
  return prismaClient;
}
