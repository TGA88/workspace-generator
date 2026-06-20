import { transform__Domain__ToOutput } from '../data.logic';

// 1 action = 1 test file
describe('get-__domain__', () => {
  describe('data.logic', () => {
    describe('transform__Domain__ToOutput', () => {
      it('maps raw record to core Output (null description -> undefined)', () => {
        const out = transform__Domain__ToOutput({
          id: 'id-1',
          sku: 'SKU-1',
          name: 'name',
          price: 100,
          description: null,
        });
        expect(out).toEqual({
          id: 'id-1',
          name: 'name',
          sku: 'SKU-1',
          price: 100,
          description: undefined,
        });
      });
    });
  });
});
