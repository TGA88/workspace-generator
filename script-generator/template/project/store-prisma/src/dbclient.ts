import { PrismaClient as MINEPrismaClient, Prisma } from '@prisma/exm-data-client';

export type PrismaClient = MINEPrismaClient;
export const prisma = Prisma
let prismaClient: PrismaClient | null = null;



export function getPrismaInstance(): PrismaClient {
  if (prismaClient) {
    console.log('prismaInstance: use_old_prisma_instance');
    return prismaClient;
  }
  console.log('prismaInstance: create_new_prisma_instance');
  prismaClient = new MINEPrismaClient({
    log: ['info'],
  });
  // type BibleRes =  Prisma.PromiseReturnType<typeof prismaClient.bIBLE.create>  
  // you can use below for overwrite connection of file prisma.schema at runtime
  // new MINEPrismaClient({datasourceUrl:"connextionstring"});
  return prismaClient;
}


