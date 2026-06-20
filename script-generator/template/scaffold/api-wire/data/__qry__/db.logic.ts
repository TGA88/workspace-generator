import { BaseFailure, Either, left, right, toBaseFailure } from '@inh-lib/common';
import { PrismaClient, Prisma } from '../../../dbclient';
import { Raw__Domain__, Get__Domain__DAFFail } from './internal.type';

// ─── get by id ───────────────────────────────────────────────
export async function findByIdDAF(
  client: PrismaClient | Prisma.TransactionClient,
  input: { id: string },
): Promise<Either<BaseFailure, Raw__Domain__ | null>> {
  try {
    const raw = await client.__domain__.findUnique({
      where: { id: input.id },
      select: { id: true, sku: true, name: true, price: true, description: true },
    });
    return right(raw);
  } catch (error) {
    const baseFail = toBaseFailure(error);
    return left(new Get__Domain__DAFFail(baseFail.message, { error: baseFail }));
  }
}
