import { InhLogger, Result } from '@inh-lib/common';
import { InputDTO, OutputDTO } from '../dto';
import { Handler } from '../handler';
import {
  Repository,
  Failures,
  EditBibleOutput,
  // GetAllAnimalTypeOutput,
  GetBibleDetailOutput,
} from '@gu-example-system/exm-api-core/command/edit-bible';
const mockRepository: Repository = jest.createMockFromModule(
  '@gu-example-system/exm-api-core/command/edit-bible',
);
const mockMapper = jest.fn();
const mockMapperSuccess = jest.fn();
const mockLogger: InhLogger = jest.createMockFromModule('@inh-lib/common');
let mockDTO: InputDTO = jest.genMockFromModule('../dto');
let mockSuccessDTO: OutputDTO = jest.genMockFromModule('../dto');
let mockGetBibleDetail: GetBibleDetailOutput = jest.genMockFromModule(
  '@gu-example-system/exm-api-core/command/edit-bible',
);
// let mockGetAllAnimalType: GetAllAnimalTypeOutput = jest.genMockFromModule(
//   '@gu-example-system/exm-api-core/command/edit-bible',
// );
let mockEditBible: EditBibleOutput = jest.genMockFromModule(
  '@gu-example-system/exm-api-core/command/edit-bible',
);
const mockHandler = new Handler(mockMapper, mockMapperSuccess, mockRepository, mockLogger);
beforeEach(() => {
  jest.resetAllMocks();
  mockLogger.error = jest.fn();
  mockLogger.info = jest.fn();
  mockDTO = {
    id: '1',
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
    uid: 'test',
    medType: {
      medTypeCode: 'V1',
      medTypeName: 'test',
    },
  };
  mockSuccessDTO = {
    id: 'test',
  };
  // mockGetAllAnimalType = {
  //   animalType: [
  //     {
  //       animalTypeCode: 'test',
  //       animalTypeName: 'test',
  //     },
  //   ],
  //   year: 2024,
  // };
  mockGetBibleDetail = {
    id: '1',
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
    medType: {
      medTypeCode: 'V1',
      medTypeName: 'test',
    },
    bibleStatus: 'DRAFT',
  };
  mockEditBible = {
    id: '1',
  };
});
describe('F5-S4-U1: ต้องการแก้ไข Bible', () => {
  it('TC1:ผู้ใช้งานกรอกข้อมูลที่เป็น Required Field ในส่วนที่ 1,2 ครบถ้วน แล้วกดบันทึก', async () => {
    mockDTO = {
      id: '1',
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
      uid: 'test',
      medType: {
        medTypeCode: 'V1',
        medTypeName: 'test',
      },
    };
    mockMapper.mockReturnValueOnce(Result.ok(mockDTO));
    mockRepository.getBibleDetail = jest.fn().mockReturnValue(Result.ok(mockGetBibleDetail));
    // mockRepository.getAllAnimalType = jest.fn().mockReturnValue(Result.ok(mockGetAllAnimalType));
    mockRepository.editBible = jest.fn().mockReturnValue(Result.ok(mockEditBible));
    mockMapperSuccess.mockReturnValueOnce(Result.ok(mockSuccessDTO));
    const actual = await mockHandler.execute(mockDTO);
    expect(actual.isRight()).toBeTruthy();
    expect(actual.value.getValue()).toEqual(mockSuccessDTO);
  });
  it('TC2:ผู้ใช้งานกรอกข้อมูลที่เป็น Required Field ในส่วนที่ 1,2 ไม่ครบถ้วน แล้วกดบันทึก', async () => {
    mockDTO = {
      id: '1',
      country: { countryCode: 'TH', countryName: 'Thailand' },
      year: 2024,
      species: {
        speciesCode: 'test',
        speciesName: 'test',
      },
      animalType: [],
      uid: 'test',
      medType: {
        medTypeCode: 'V1',
        medTypeName: 'test',
      },
    };
    mockMapper.mockReturnValueOnce(Result.ok(mockDTO));
    mockRepository.getBibleDetail = jest.fn().mockReturnValue(Result.ok(mockGetBibleDetail));
    // mockRepository.getAllAnimalType = jest.fn().mockReturnValue(Result.ok(mockGetAllAnimalType));
    mockRepository.editBible = jest.fn().mockReturnValue(Result.fail(new Failures.UpdateFail()));
    mockMapperSuccess.mockReturnValueOnce(Result.ok(mockSuccessDTO));
    const actual = await mockHandler.execute(mockDTO);
    expect(actual.isLeft()).toBeTruthy();
    expect(actual.value.errorValue()).toEqual({ message: 'Update fail: [object Object]' });
  });
  it('TC3:ผู้ใช้งานบันทึกการแก้ไขไม่สำเร็จ กรณี มีปัญหาด้านอื่นๆ (Network,Database)', async () => {
    mockDTO = {
      id: '1',
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
      uid: 'test',
      medType: {
        medTypeCode: 'V1',
        medTypeName: 'test',
      },
    };
    mockMapper.mockReturnValueOnce(Result.ok(mockDTO));
    mockRepository.getBibleDetail = jest.fn().mockReturnValue(Result.ok(mockGetBibleDetail));
    // mockRepository.getAllAnimalType = jest.fn().mockReturnValue(Result.ok(mockGetAllAnimalType));
    mockRepository.editBible = jest.fn().mockReturnValue(Result.fail('error'));
    const actual = await mockHandler.execute(mockDTO);
    expect(actual.isLeft()).toBeTruthy();
    expect(actual.value).toEqual(new Failures.UpdateFail('error'));
  });
});
describe('Unit Test Handler', () => {
  it('should return fail when mapping fail', async () => {
    mockMapper.mockReturnValueOnce(Result.fail('error'));
    const actual = await mockHandler.execute(mockDTO);
    expect(actual.isLeft()).toBeTruthy();
    expect(actual.value).toEqual(new Failures.ParseFail());
  });
  it('should return fail when getBibleDetail fail', async () => {
    mockMapper.mockReturnValueOnce(Result.ok(mockDTO));
    mockRepository.getBibleDetail = jest.fn().mockReturnValue(Result.fail(new Failures.GetFail()));
    const actual = await mockHandler.execute(mockDTO);
    expect(actual.isLeft()).toBeTruthy();
    expect(actual.value.errorValue()).toEqual({ message: 'Bible detail not found' });
  });
  // it('should return fail when getAllAnimalType fail (status DRAFT)', async () => {
  //   mockMapper.mockReturnValueOnce(Result.ok(mockDTO));
  //   mockRepository.getBibleDetail = jest.fn().mockReturnValue(Result.ok(mockGetBibleDetail));
  //   mockRepository.getAllAnimalType = jest.fn().mockReturnValue(Result.fail(new Failures.GetFail()));
  //   const actual = await mockHandler.execute(mockDTO);
  //   expect(actual.isLeft()).toBeTruthy();
  //   expect(actual.value.errorValue()).toEqual({ message: 'Get fail' });
  // });
  // it('should return fail when getAllAnimalType fail (other status)', async () => {
  //   mockGetBibleDetail = {
  //     id: '1',
  //     country: { countryCode: 'TH', countryName: 'Thailand' },
  //     year: 2024,
  //     species: {
  //       speciesCode: 'test',
  //       speciesName: 'test',
  //     },
  //     animalType: [
  //       {
  //         animalTypeCode: 'test',
  //         animalTypeName: 'test',
  //       },
  //     ],
  //     medType: {
  //       medTypeCode: 'V1',
  //       medTypeName: 'test',
  //     },
  //     bibleStatus: 'PUBLISHED',
  //   };
  //   mockMapper.mockReturnValueOnce(Result.ok(mockDTO));
  //   mockRepository.getBibleDetail = jest.fn().mockReturnValue(Result.ok(mockGetBibleDetail));
  //   mockRepository.getAllAnimalType = jest.fn().mockReturnValue(Result.fail(new Failures.GetFail()));
  //   const actual = await mockHandler.execute(mockDTO);
  //   expect(actual.isLeft()).toBeTruthy();
  //   expect(actual.value.errorValue()).toEqual({ message: 'Bible status not "DRAFT"' });
  // });
  it('should return fail when bibleStatus !== DRAFT', async () => {
    mockGetBibleDetail = {
      id: '1',
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
      medType: {
        medTypeCode: 'V1',
        medTypeName: 'test',
      },
      bibleStatus: 'PUBLISHED',
    };
    mockMapper.mockReturnValueOnce(Result.ok(mockDTO));
    mockRepository.getBibleDetail = jest.fn().mockReturnValue(Result.ok(mockGetBibleDetail));
    // mockRepository.getAllAnimalType = jest.fn().mockReturnValue(Result.ok(mockGetAllAnimalType));
    const actual = await mockHandler.execute(mockDTO);
    expect(actual.isLeft()).toBeTruthy();
    expect(actual.value.errorValue()).toEqual({ message: 'Bible status not "DRAFT"' });
  });
  it('should return fail when editBibleOrError fail', async () => {
    mockDTO = {
      id: '1',
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
      uid: 'test',
      medType: {
        medTypeCode: 'V1',
        medTypeName: 'test',
      },
    };
    mockMapper.mockReturnValueOnce(Result.ok(mockDTO));
    mockRepository.getBibleDetail = jest.fn().mockReturnValue(Result.ok(mockGetBibleDetail));
    // mockRepository.getAllAnimalType = jest.fn().mockReturnValue(Result.ok(mockGetAllAnimalType));
    mockRepository.editBible = jest.fn().mockReturnValue(Result.fail('error'));
    const actual = await mockHandler.execute(mockDTO);
    expect(actual.isLeft()).toBeTruthy();
    expect(actual.value.errorValue()).toEqual({ message: 'Update fail: error' });
  });
  it('should return success when no error editBible (single detail)', async () => {
    mockDTO = {
      id: '1',
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
      uid: 'test',
      medType: {
        medTypeCode: 'V1',
        medTypeName: 'test',
      },
    };
    mockMapper.mockReturnValueOnce(Result.ok(mockDTO));
    mockRepository.getBibleDetail = jest.fn().mockReturnValue(Result.ok(mockGetBibleDetail));
    // mockRepository.getAllAnimalType = jest.fn().mockReturnValue(Result.ok(mockGetAllAnimalType));
    mockRepository.editBible = jest.fn().mockReturnValue(Result.ok(mockEditBible));
    mockMapperSuccess.mockReturnValueOnce(Result.ok(mockSuccessDTO));
    const actual = await mockHandler.execute(mockDTO);
    expect(actual.isRight()).toBeTruthy();
    expect(actual.value.getValue()).toEqual(mockSuccessDTO);
  });
});

