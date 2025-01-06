import { Result } from '@inh-lib/common';

export type IsDateFormatType = (value: string) => Result<boolean>;

export const isDateFormat = (date: string):Result<boolean> => {
  //  RegExp must not throw exception. so we don't need try catch block
  const r = RegExp(/^\d{4}-\d{2}-\d{2}$/);
  return Result.ok(r.test(date));
};
