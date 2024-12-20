import { InhLogger, Result } from '@inh-lib/common';
import { InputDTO, OutputDTO } from '../dto';
import { Handler } from '../handler';
import {
  Repository,
  Failures,
  CreateBibleOutput,
  // GetAllAnimalTypeOutput,
} from '@feedos-example-system/exm-api-core/command/create-bible';
const mockRepository: Repository = jest.createMockFromModule(
  '@feedos-example-system/exm-api-core/command/create-bible',
);
const mockMapper = jest.fn();
const mockMapperSuccess = jest.fn();
const mockLogger: InhLogger = jest.createMockFromModule('@inh-lib/common');
let mockDTO: InputDTO = jest.genMockFromModule('../dto');
let mockSuccessDTO: OutputDTO = jest.genMockFromModule('../dto');
// let mockGetAllAnimalType: GetAllAnimalTypeOutput = jest.genMockFromModule(
//   '@feedos-example-system/exm-api-core/command/create-bible',
// );
let mockCreateBible: CreateBibleOutput = jest.genMockFromModule(
  '@feedos-example-system/exm-api-core/command/create-bible',
);
const mockHandler = new Handler(mockMapper, mockMapperSuccess, mockRepository, mockLogger);
beforeEach(() => {
  jest.resetAllMocks();
  mockLogger.error = jest.fn();
  mockLogger.info = jest.fn();
  mockDTO = {
    country: { countryCode: 'TH', countryName: 'Thailand' },
    year: 2024,
    species: {
      speciesCode: 'test',
      speciesName: 'test',
    },
    animalType: [
      {
        animalTypeCode: 'test',
        animalTypeName: 'test',
      },
    ],
    items: ['test'],
    uid: 'test',
    medType: {
      medTypeCode: 'V1',
      medTypeName: 'test',
    },
  };
  mockSuccessDTO = {
    id: 'test',
  };
  mockCreateBible = {
    id: 'test',
  };
  // mockGetAllAnimalType = {
  //   animalType: [
  //     {
  //       animalTypeCode: 'test',
  //       animalTypeName: 'test',
  //     },
  //   ],
  // };
});
describe('F5-S4-U1: ต้องการสร้าง Bible', () => {
  it('TC1:ผู้ใช้งานกรอกข้อมูลที่เป็น Required Field ในส่วนที่ 1,2 ครบถ้วน แล้วกดบันทึก', async () => {
    mockDTO = {
      country: { countryCode: 'TH', countryName: 'Thailand' },
      year: 2024,
      species: {
        speciesCode: 'test',
        speciesName: 'test',
      },
      animalType: [
        {
          animalTypeCode: 'test2',
          animalTypeName: 'test2',
        },
      ],
      items: ['test', 'test2'],
      uid: 'test',
      medType: {
        medTypeCode: 'V1',
        medTypeName: 'test',
      },
    };
    mockMapper.mockReturnValueOnce(Result.ok(mockDTO));
    // mockRepository.getAllAnimalType = jest.fn().mockReturnValue(Result.ok(mockGetAllAnimalType));
    mockRepository.createBible = jest.fn().mockReturnValue(Result.ok(mockCreateBible));
    mockMapperSuccess.mockReturnValueOnce(Result.ok(mockSuccessDTO));
    const actual = await mockHandler.execute(mockDTO);
    expect(actual.isRight()).toBeTruthy();
    expect(actual.value.getValue()).toEqual(mockSuccessDTO);
  });
  it('TC2:ผู้ใช้งานกรอกข้อมูลที่เป็น Required Field ในส่วนที่ 1,2 ไม่ครบถ้วน แล้วกดบันทึก', async () => {
    mockDTO = {
      country: { countryCode: 'TH', countryName: 'Thailand' },
      year: 2024,
      species: {
        speciesCode: 'test',
        speciesName: 'test',
      },
      animalType: [],
      items: ['test', 'test2'],
      uid: 'test',
      medType: {
        medTypeCode: 'V1',
        medTypeName: 'test',
      },
    };
    mockMapper.mockReturnValueOnce(Result.ok(mockDTO));
    // mockRepository.getAllAnimalType = jest.fn().mockReturnValue(Result.ok(mockGetAllAnimalType));
    mockRepository.createBible = jest.fn().mockReturnValue(Result.fail(new Failures.CreateFail()));
    mockMapperSuccess.mockReturnValueOnce(Result.ok(mockSuccessDTO));
    const actual = await mockHandler.execute(mockDTO);
    expect(actual.isLeft()).toBeTruthy();
    expect(actual.value.errorValue()).toEqual({ message: 'Create fail: [object Object]' });
  });
  it('TC3:ผู้ใช้งานบันทึกการสร้างไม่สำเร็จ กรณี มีปัญหาด้านอื่นๆ (Network,Database)', async () => {
    mockDTO = {
      country: { countryCode: 'TH', countryName: 'Thailand' },
      year: 2024,
      species: {
        speciesCode: 'test',
        speciesName: 'test',
      },
      animalType: [
        {
          animalTypeCode: 'test2',
          animalTypeName: 'test2',
        },
      ],
      items: ['test', 'test2'],
      uid: 'test',
      medType: {
        medTypeCode: 'V1',
        medTypeName: 'test',
      },
    };
    mockMapper.mockReturnValueOnce(Result.ok(mockDTO));
    // mockRepository.getAllAnimalType = jest.fn().mockReturnValue(Result.ok(mockGetAllAnimalType));
    mockRepository.createBible = jest.fn().mockReturnValue(Result.fail('error'));
    const actual = await mockHandler.execute(mockDTO);
    expect(actual.isLeft()).toBeTruthy();
    expect(actual.value).toEqual(new Failures.CreateFail('error'));
  });
});
describe('Unit Test Handler', () => {
  it('should return fail when mapping fail', async () => {
    mockMapper.mockReturnValueOnce(Result.fail('error'));
    const actual = await mockHandler.execute(mockDTO);
    expect(actual.isLeft()).toBeTruthy();
    expect(actual.value).toEqual(new Failures.ParseFail());
  });
  // it('should return get fail when getAllAnimalType fail', async () => {
  //   mockMapper.mockReturnValueOnce(Result.ok(mockDTO));
  //   mockRepository.getAllAnimalType = jest.fn().mockReturnValue(Result.fail(new Failures.GetFail()));
  //   const actual = await mockHandler.execute(mockDTO);
  //   expect(actual.isLeft()).toBeTruthy();
  //   expect(actual.value).toEqual(new Failures.GetFail());
  // });
  // it('should return create fail when Year + AnimalType duplicate', async () => {
  //   mockMapper.mockReturnValueOnce(Result.ok(mockDTO));
  //   mockRepository.getAllAnimalType = jest.fn().mockReturnValue(Result.ok(mockGetAllAnimalType));
  //   mockRepository.createBible = jest.fn().mockReturnValue(Result.fail('error'));
  //   const actual = await mockHandler.execute(mockDTO);
  //   expect(actual.isLeft()).toBeTruthy();
  //   expect(actual.value.errorValue()).toEqual({ message: "Year + AnimalType can't duplicate" });
  // });
  it('should return create fail when createBible fail', async () => {
    mockDTO = {
      country: { countryCode: 'TH', countryName: 'Thailand' },
      year: 2026,
      species: {
        speciesCode: 'test',
        speciesName: 'test',
      },
      animalType: [
        {
          animalTypeCode: 'test2',
          animalTypeName: 'test2',
        },
      ],
      items: ['test', 'test2'],
      uid: 'test',
      medType: {
        medTypeCode: 'V1',
        medTypeName: 'test',
      },
    };
    mockMapper.mockReturnValueOnce(Result.ok(mockDTO));
    // mockRepository.getAllAnimalType = jest.fn().mockReturnValue(Result.ok(mockGetAllAnimalType));
    mockRepository.createBible = jest.fn().mockReturnValue(Result.fail('error'));
    const actual = await mockHandler.execute(mockDTO);
    expect(actual.isLeft()).toBeTruthy();
    expect(actual.value).toEqual(new Failures.CreateFail('error'));
  });
  it('should return success when no error createBible (single detail)', async () => {
    mockDTO = {
      country: { countryCode: 'TH', countryName: 'Thailand' },
      year: 2026,
      species: {
        speciesCode: 'test',
        speciesName: 'test',
      },
      animalType: [
        {
          animalTypeCode: 'test2',
          animalTypeName: 'test2',
        },
      ],
      items: ['test', 'test2'],
      uid: 'test',
      medType: {
        medTypeCode: 'V1',
        medTypeName: 'test',
      },
    };
    mockMapper.mockReturnValueOnce(Result.ok(mockDTO));
    // mockRepository.getAllAnimalType = jest.fn().mockReturnValue(Result.ok(mockGetAllAnimalType));
    mockRepository.createBible = jest.fn().mockReturnValue(Result.ok(mockCreateBible));
    mockMapperSuccess.mockReturnValueOnce(Result.ok(mockSuccessDTO));
    const actual = await mockHandler.execute(mockDTO);
    expect(actual.isRight()).toBeTruthy();
    expect(actual.value.getValue()).toEqual(mockSuccessDTO);
  });
  it('should return success when no error createBible (multiple detail)', async () => {
    mockDTO = {
      country: { countryCode: 'TH', countryName: 'Thailand' },
      year: 2024,
      species: {
        speciesCode: 'test',
        speciesName: 'test',
      },
      animalType: [
        {
          animalTypeCode: 'test2',
          animalTypeName: 'test2',
        },
      ],
      items: ['test', 'test2'],
      uid: 'test',
      medType: {
        medTypeCode: 'V1',
        medTypeName: 'test',
      },
    };
    mockMapper.mockReturnValueOnce(Result.ok(mockDTO));
    // mockRepository.getAllAnimalType = jest.fn().mockReturnValue(Result.ok(mockGetAllAnimalType));
    mockRepository.createBible = jest.fn().mockReturnValue(Result.ok(mockCreateBible));
    mockMapperSuccess.mockReturnValueOnce(Result.ok(mockSuccessDTO));
    const actual = await mockHandler.execute(mockDTO);
    expect(actual.isRight()).toBeTruthy();
    expect(actual.value.getValue()).toEqual(mockSuccessDTO);
  });
});

