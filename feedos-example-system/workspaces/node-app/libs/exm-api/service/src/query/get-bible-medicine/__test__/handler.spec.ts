import { InhLogger, Result } from '@inh-lib/common';
import { inputDTO, InputDTO, OutputDTO } from '../dto';
import { Handler } from '../handler';
import { Repository, OutputModel, Failures } from '@fos-psc-webapi/bible-factory-core/query/get-bible-medicine';

const mockRepository: Repository = jest.createMockFromModule(
  '@fos-psc-webapi/bible-factory-core/query/get-bible-medicine',
);
const mockMapper = jest.fn();
const mockMapperSuccess = jest.fn();
const mockLogger: InhLogger = jest.createMockFromModule('@inh-lib/common');
let mockDTO: InputDTO = jest.genMockFromModule('../dto');
let mockSuccessDTO: OutputDTO = jest.genMockFromModule('../dto');
let mockGetMedicine: OutputModel = jest.genMockFromModule(
  '@fos-psc-webapi/bible-factory-core/query/get-bible-medicine',
);
const mockHandler = new Handler(mockMapper, mockMapperSuccess, mockRepository, mockLogger);
beforeEach(() => {
  jest.resetAllMocks();
  mockLogger.error = jest.fn();
  mockLogger.info = jest.fn();
  mockDTO = {
    page: 0,
    size: 100,
    search: undefined,
    countryCode: 'TH',
    medicineTypeCode: '',
  };
  mockSuccessDTO = {
    items: [],
    total: 0,
  };
  mockGetMedicine = {
    items: [],
    total: 0,
  };
});

describe(' 1-S4-API TC1:แสดงรายการ medicine', () => {
  it('Result 1 : สามารถแสดงรายการ medicine  ได้หากมีข้อมูล medicine', async () => {
    mockMapper.mockReturnValueOnce(Result.ok(mockDTO));
    mockRepository.getMedicine = jest.fn().mockReturnValue(
      Result.ok({
        items: [
          {
            id: 'test',
            countryCode: 'Test',
            countryName: 'Test',
          },
        ],
        total: 1,
      }),
    );
    mockMapperSuccess.mockReturnValueOnce(Result.ok(mockSuccessDTO));
    const actual = await mockHandler.execute(mockDTO);
    expect(actual.isRight()).toBeTruthy();
    expect(actual.value.getValue()).toEqual(mockSuccessDTO);
  });
  it('Result 2 : สามารถแสดงรายการว่างเปล่าได้หาก ไม่มีข้อมูล medicine', async () => {
    mockMapper.mockReturnValueOnce(Result.ok(mockDTO));
    mockRepository.getMedicine = jest.fn().mockReturnValue(
      Result.ok({
        items: [],
        total: 0,
      }),
    );
    mockMapperSuccess.mockReturnValueOnce(Result.ok(mockSuccessDTO));
    const actual = await mockHandler.execute(mockDTO);
    expect(actual.isRight()).toBeTruthy();
    expect(actual.value.getValue()).toEqual(mockSuccessDTO);
  });
});
describe('TC2: ไม่สามารถแสดงรายการ medicine  ได้', () => {
  it('Result 1: เกิดความขัดข้องในการเชื่อมต่อกับ database หรือ unexpected error', async () => {
    mockMapper.mockReturnValueOnce(Result.ok(mockDTO));
    mockRepository.getMedicine = jest.fn().mockReturnValue(Result.fail(new Failures.GetFail()));
    const actual = await mockHandler.execute(mockDTO);
    expect(actual.isLeft()).toBeTruthy();
    expect(actual.value).toEqual(new Failures.GetFail());
  });
});
describe('Unit Test Handler', () => {
  it('should return fail when input size is over 250', () => {
    const inputModels = {
      page: 0,
      size: 251,
      search: undefined,
      countryCode: 'TH',
      medicineTypeCode: '',
    };
    const input = inputDTO.safeParse(inputModels);
    expect(input.success).toEqual(false);
  });
  it('should return fail when mapping fail', async () => {
    mockMapper.mockReturnValueOnce(Result.fail('error'));
    const actual = await mockHandler.execute(mockDTO);
    expect(actual.isLeft()).toBeTruthy();
    expect(actual.value).toEqual(new Failures.ParseFail());
  });
  it('should return Get Fail when getMedicine fail', async () => {
    mockMapper.mockReturnValueOnce(Result.ok(mockDTO));
    mockRepository.getMedicine = jest.fn().mockReturnValue(Result.fail(new Failures.GetFail()));
    const actual = await mockHandler.execute(mockDTO);
    expect(actual.isLeft()).toBeTruthy();
    expect(actual.value).toEqual(new Failures.GetFail());
  });
  it('should return success when no error getMedicine', async () => {
    mockMapper.mockReturnValueOnce(Result.ok(mockDTO));
    mockRepository.getMedicine = jest.fn().mockReturnValue(Result.ok(mockGetMedicine));
    mockMapperSuccess.mockReturnValueOnce(Result.ok(mockSuccessDTO));
    const actual = await mockHandler.execute(mockDTO);
    expect(actual.isRight()).toBeTruthy();
    expect(actual.value.getValue()).toEqual(mockSuccessDTO);
  });
});

