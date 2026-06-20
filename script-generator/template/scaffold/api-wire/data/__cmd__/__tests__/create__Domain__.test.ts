import { transform__Domain__ToOutput } from '../data.logic';

// 1 action = 1 test file. เพิ่ม describe ของ entry/task/flows/db.logic ได้ในไฟล์เดียวนี้
describe('create-__domain__', () => {
  describe('data.logic', () => {
    describe('transform__Domain__ToOutput', () => {
      it('maps raw record to core Output (id, sku)', () => {
        const out = transform__Domain__ToOutput({
          id: 'id-1',
          sku: 'SKU-1',
          name: 'name',
          price: 100,
          description: null,
          createdAt: new Date(),
        });
        expect(out).toEqual({ id: 'id-1', sku: 'SKU-1' });
      });
    });
  });
});
