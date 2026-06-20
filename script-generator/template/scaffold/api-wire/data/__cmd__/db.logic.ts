import { BaseFailure, Either, left, right, toBaseFailure } from '@inh-lib/common';
import { PrismaClient, Prisma } from '../../../dbclient';
import {
  Insert__Domain__DbInput,
  Raw__Domain__,
  Create__Domain__DAFFail,
  CheckSkuDAFFail,
} from './internal.type';

// ─── create ──────────────────────────────────────────────────
export async function insert__Domain__DAF(
  client: PrismaClient | Prisma.TransactionClient,
  data: Insert__Domain__DbInput,
): Promise<Either<BaseFailure, Raw__Domain__>> {
  try {
    const raw = await client.__domain__.create({
      data: {
        name: data.name,
        sku: data.sku.trim(),
        price: data.price,
        description: data.description,
      },
    });
    return right(raw);
  } catch (error) {
    const baseFail = toBaseFailure(error);
    return left(new Create__Domain__DAFFail(baseFail.message, { error: baseFail }));
  }
}

// ─── checkDuplicate / shared ─────────────────────────────────
export async function findBySkuDAF(
  client: PrismaClient | Prisma.TransactionClient,
  input: { sku: string },
): Promise<Either<BaseFailure, Raw__Domain__ | null>> {
  try {
    const raw = await client.__domain__.findFirst({ where: { sku: input.sku.trim() } });
    return right(raw);
  } catch (error) {
    const baseFail = toBaseFailure(error);
    return left(new CheckSkuDAFFail(baseFail.message, { error: baseFail }));
  }
}
