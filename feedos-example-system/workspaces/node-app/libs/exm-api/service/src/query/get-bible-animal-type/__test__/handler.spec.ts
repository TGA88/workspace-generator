import { InhLogger, Result } from '@inh-lib/common';
import { inputDTO, InputDTO, OutputDTO } from '../dto';
import { Handler } from '../handler';
import { Repository, OutputModel, Failures } from '@fos-psc-webapi/bible-factory-core/query/get-bible-animal-type';

const mockRepository: Repository = jest.createMockFromModule(
  '@fos-psc-webapi/bible-factory-core/query/get-bible-animal-type',
);
const mockMapper = jest.fn();
const mockMapperSuccess = jest.fn();
const mockLogger: InhLogger = jest.createMockFromModule('@inh-lib/common');
let mockDTO: InputDTO = jest.genMockFromModule('../dto');
let mockSuccessDTO: OutputDTO = jest.genMockFromModule('../dto');
let mockGetCountry: OutputModel = jest.genMockFromModule(
  '@fos-psc-webapi/bible-factory-core/query/get-bible-animal-type',
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
    speciesCode: 'test',
  };
  mockSuccessDTO = {
    items: [],
    total: 0,
  };
  mockGetCountry = {
    items: [],
    total: 0,
  };
});
describe('F1-S4-API-No.11: ต้องการแสดงรายการ animalType', () => {
  it('Result 1 : สามารถแสดงรายการ animalType  ได้หากมีข้อมูล animalType', async () => {
    mockMapper.mockReturnValueOnce(Result.ok(mockDTO));
    mockRepository.getAnimalType = jest.fn().mockReturnValue(
      Result.ok({
        items: [
          {
            id: 'test',
            animalTypeCode: 'Test',
            animalTypeName: 'Test',
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
  it('Result 2 : สามารถแสดงรายการว่างเปล่าได้หาก ไม่มีข้อมูล animalType', async () => {
    mockMapper.mockReturnValueOnce(Result.ok(mockDTO));
    mockRepository.getAnimalType = jest.fn().mockReturnValue(
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
describe('TC2: ไม่สามารถแสดงรายการ animalType  ได้', () => {
  it('Result 1: เกิดความขัดข้องในการเชื่อมต่อกับ database หรือ unexpected error', async () => {
    mockMapper.mockReturnValueOnce(Result.ok(mockDTO));
    mockRepository.getAnimalType = jest.fn().mockReturnValue(Result.fail(new Failures.GetFail()));
    const actual = await mockHandler.execute(mockDTO);
    expect(actual.isLeft()).toBeTruthy();
    expect(actual.value).toEqual(new Failures.GetFail());
  });
});
describe('Unit Test Handler', () => {
  it('should return fail when input size is over 100', () => {
    const inputModels = {
      page: 1,
      size: 101,
      search: undefined,
      speciesCode: 'test',
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
  it('should return Get Fail when getCountry fail', async () => {
    mockMapper.mockReturnValueOnce(Result.ok(mockDTO));
    mockRepository.getAnimalType = jest.fn().mockReturnValue(Result.fail(new Failures.GetFail()));
    const actual = await mockHandler.execute(mockDTO);
    expect(actual.isLeft()).toBeTruthy();
    expect(actual.value).toEqual(new Failures.GetFail());
  });
  it('should return success when no error getCountry', async () => {
    mockMapper.mockReturnValueOnce(Result.ok(mockDTO));
    mockRepository.getAnimalType = jest.fn().mockReturnValue(Result.ok(mockGetCountry));
    mockMapperSuccess.mockReturnValueOnce(Result.ok(mockSuccessDTO));
    const actual = await mockHandler.execute(mockDTO);
    expect(actual.isRight()).toBeTruthy();
    expect(actual.value.getValue()).toEqual(mockSuccessDTO);
  });
});

