import { __Verb____Domain__Input } from '@__WS__/__API__-core/__domain__-api/command/__verb__-__domain__';

// ===========================================================================
// business.logic = "pure business logic" ของ action นี้ (validate / transform)
// - ไม่มี I/O, ไม่แตะ context/registry/repo  -> unit test ตรงๆ ได้
// - รวม pure logic ไว้ที่เดียว ลดจำนวนไฟล์/จำนวน test file (jest spawn ต่อไฟล์)
// ===========================================================================
type ValidationResult = {
  isValid: boolean;
  missingFields: (keyof __Verb____Domain__Input)[];
  message?: string;
};

const isEmpty = (value: unknown): boolean =>
  value === null || value === undefined || value === '';

const commonRequired: (keyof __Verb____Domain__Input)[] = ['name', 'sku', 'price'];

export const validate__Verb____Domain__Input = (input: __Verb____Domain__Input): ValidationResult => {
  const missingFields: (keyof __Verb____Domain__Input)[] = [];
  commonRequired.forEach((field) => {
    if (isEmpty(input[field])) missingFields.push(field);
  });

  if (typeof input.price === 'number' && input.price < 0) {
    return { isValid: false, missingFields, message: 'price must be >= 0' };
  }
  if (missingFields.length > 0) {
    return { isValid: false, missingFields, message: `Missing required fields: ${missingFields.join(', ')}` };
  }
  return { isValid: true, missingFields: [] };
};
