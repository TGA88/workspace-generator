import { isDateFormat } from '../isDateFormat';

describe('isDateFormat', () => {
  it('2022-01-01 is correct Date Format', () => {
    const dateValue = '2022-01-01';
    const actual = isDateFormat(dateValue);

    expect(actual.getValue()).toEqual(true);
  });

  it('2022-01 is incorrect  Date Format', () => {
    const dateValue = '2022-01';
    const actual = isDateFormat(dateValue);
    expect(actual.getValue()).toEqual(false);
  });

  it('2022 is incorrect  Date Format ', () => {
    const dateValue = '2022';
    const actual = isDateFormat(dateValue);
    expect(actual.getValue()).toEqual(false);
  });

  it('value is null then it is incorrect  Date Format ', () => {
    const dateValue = 'null';
    const actual = isDateFormat(dateValue);
    expect(actual.getValue()).toEqual(false);
  });
});
