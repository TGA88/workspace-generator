import { InhLogger, Result } from '@inh-lib/common';
import { InputDTO, OutputDTO } from '../dto';
import { Handler } from '../handler';
import {
  Repository,
  Failures,
  EditBibleDetailOutput,
  GetBibleDetailOutput,
} from '@fos-psc-webapi/bible-factory-core/command/edit-bible-detail';
const mockRepository: Repository = jest.createMockFromModule(
  '@fos-psc-webapi/bible-factory-core/command/edit-bible-detail',
);
const mockMapper = jest.fn();
const mockMapperSuccess = jest.fn();
const mockLogger: InhLogger = jest.createMockFromModule('@inh-lib/common');
let mockDTO: InputDTO = jest.genMockFromModule('../dto');
let mockSuccessDTO: OutputDTO = jest.genMockFromModule('../dto');
let mockGetBibleDetail: GetBibleDetailOutput = jest.genMockFromModule(
  '@fos-psc-webapi/bible-factory-core/command/edit-bible-detail',
);
let mockEditBibleDetail: EditBibleDetailOutput = jest.genMockFromModule(
  '@fos-psc-webapi/bible-factory-core/command/edit-bible-detail',
);
const mockHandler = new Handler(mockMapper, mockMapperSuccess, mockRepository, mockLogger);
beforeEach(() => {
  jest.resetAllMocks();
  mockLogger.error = jest.fn();
  mockLogger.info = jest.fn();
  mockDTO = {
    id: '1',
    uid: 'test',
    items: ['1', '2'],
  };
  mockSuccessDTO = {
    id: 'test',
  };
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
  mockEditBibleDetail = {
    id: '1',
  };
});
describe('F5-S4-U1: ต้องการแก้ไข Bible Detail', () => {
  it('TC1:ผู้ใช้งานกรอกข้อมูลที่เป็น Required Field ในส่วนที่ 1,2 ครบถ้วน แล้วกดบันทึก', async () => {
    mockDTO = {
      id: '1',
      uid: 'test',
      items: ['1', '2'],
    };
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
    mockRepository.editBibleDetail = jest.fn().mockReturnValue(Result.ok(mockEditBibleDetail));
    mockMapperSuccess.mockReturnValueOnce(Result.ok(mockSuccessDTO));
    const actual = await mockHandler.execute(mockDTO);
    expect(actual.isRight()).toBeTruthy();
    expect(actual.value.getValue()).toEqual(mockSuccessDTO);
  });
  it('TC2:ผู้ใช้งานกรอกข้อมูลที่เป็น Required Field ในส่วนที่ 1,2 ไม่ครบถ้วน แล้วกดบันทึก', async () => {
    mockDTO = {
      id: '1',
      uid: 'test',
      items: ['1', '2'],
    };
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
    mockRepository.editBibleDetail = jest.fn().mockReturnValue(Result.fail(new Failures.UpdateFail()));
    mockMapperSuccess.mockReturnValueOnce(Result.ok(mockSuccessDTO));
    const actual = await mockHandler.execute(mockDTO);
    expect(actual.isLeft()).toBeTruthy();
    expect(actual.value.errorValue()).toEqual({ message: 'Update fail: [object Object]' });
  });
  it('TC3:ผู้ใช้งานบันทึกการแก้ไขไม่สำเร็จ กรณี มีปัญหาด้านอื่นๆ (Network,Database)', async () => {
    mockDTO = {
      id: '1',
      uid: 'test',
      items: ['1', '2'],
    };
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
    mockRepository.editBibleDetail = jest.fn().mockReturnValue(Result.fail('error'));
    const actual = await mockHandler.execute(mockDTO);
    expect(actual.isLeft()).toBeTruthy();
    expect(actual.value).toEqual(new Failures.UpdateFail('error'));
  });
  //     it('TC6:ผู้ใช้งานไม่สามารถPublishเอกสารได้ก็ต่อเมื่อ Result1: ไม่มีค่า Country หรือไม่มีค่า Medicine Type หรือไม่มีค่า Year หรือไม่มีค่า Species หรือไม่มีค่า Animal Type หรือไม่มีค่า รายการยาใน List', async () => {
  //       mockGetBibleDetail = {
  //         bibleAnimalType: [],
  //         bibleDetail: [
  //           {
  //             medCode: 'test',
  //           },
  //         ],
  //         bibleStatus: 'DRAFT',
  //         medTypeCode: 'test',
  //         speciesCode: 'test',
  //         year: 2024,
  //         createBy: 'test',
  //       };
  //       mockMapper.mockReturnValueOnce(Result.ok(mockDTO));
  //       mockRepository.getBibleDetail = jest.fn().mockReturnValue(Result.ok(mockGetBibleDetail));
  //       const actual = await mockHandler.execute(mockDTO);
  //       expect(actual.isLeft()).toBeTruthy();
  //       expect(actual.value).toEqual(
  //         new Failures.UpdateFail('Data in Bible record not enought to change BIBLE_STATUS to PUBLISHED'),
  //       );
  //     });
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
    mockRepository.getBibleDetail = jest.fn().mockReturnValue(Result.fail(new Failures.BibleDetailNotFound()));
    const actual = await mockHandler.execute(mockDTO);
    expect(actual.isLeft()).toBeTruthy();
    expect(actual.value.errorValue()).toEqual({ message: 'Bible detail not found' });
  });
  it('should return fail when Bible status is "CANCEL"', async () => {
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
      bibleStatus: 'CANCEL',
    };
    mockMapper.mockReturnValueOnce(Result.ok(mockDTO));
    mockRepository.getBibleDetail = jest.fn().mockReturnValue(Result.ok(mockGetBibleDetail));
    const actual = await mockHandler.execute(mockDTO);
    expect(actual.isLeft()).toBeTruthy();
    expect(actual.value.errorValue()).toEqual({ message: 'Bible status not "DRAFT" or "PUBLISHED"' });
  });
  it('should return fail when editBibleDetail fail', async () => {
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
    mockRepository.editBibleDetail = jest.fn().mockReturnValue(Result.fail('error'));
    const actual = await mockHandler.execute(mockDTO);
    expect(actual.isLeft()).toBeTruthy();
    expect(actual.value.errorValue()).toEqual({ message: 'Update fail: error' });
  });
  it('should return success when no error editBibleDetail', async () => {
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
    mockRepository.editBibleDetail = jest.fn().mockReturnValue(Result.ok(mockEditBibleDetail));
    mockMapperSuccess.mockReturnValueOnce(Result.ok(mockSuccessDTO));
    const actual = await mockHandler.execute(mockDTO);
    expect(actual.isRight()).toBeTruthy();
    expect(actual.value.getValue()).toEqual(mockSuccessDTO);
  });
});

