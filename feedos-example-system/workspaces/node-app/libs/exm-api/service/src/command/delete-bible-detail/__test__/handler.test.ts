import { InhLogger, Result } from '@inh-lib/common';
import { InputDTO, OutputDTO } from '../dto';
import { Handler } from '../handler';
import {
  Repository,
  Failures,
  DeleteBibleDetailOutput,
  GetBibleDetailOutput,
} from '@feedos-example-system/exm-api-core/command/delete-bible-detail';
const mockRepository: Repository = jest.createMockFromModule(
  '@feedos-example-system/exm-api-core/command/delete-bible-detail',
);
const mockMapper = jest.fn();
const mockMapperSuccess = jest.fn();
const mockLogger: InhLogger = jest.createMockFromModule('@inh-lib/common');
let mockDTO: InputDTO = jest.genMockFromModule('../dto');
let mockSuccessDTO: OutputDTO = jest.genMockFromModule('../dto');
let mockGetBibleDetail: GetBibleDetailOutput = jest.genMockFromModule(
  '@feedos-example-system/exm-api-core/command/delete-bible-detail',
);
let mockDeleteBibleDetail: DeleteBibleDetailOutput = jest.genMockFromModule(
  '@feedos-example-system/exm-api-core/command/delete-bible-detail',
);
const mockHandler = new Handler(mockMapper, mockMapperSuccess, mockRepository, mockLogger);
beforeEach(() => {
  jest.resetAllMocks();
  mockLogger.error = jest.fn();
  mockLogger.info = jest.fn();
  mockDTO = {
    id: '1',
    detailId: 'test',
  };
  mockSuccessDTO = {
    detailId: 'test',
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
  mockDeleteBibleDetail = {
    id: '1',
  };
});
describe('F5-S6: ลบ Medicine', () => {
  describe('F5-S6-U1: ต้องการลบ Medicine ในรายการ', () => {
    it('TC1: ผู้ใช้งานต้องการลบรายการ Medicine ใน Bible ที่มีสถานะเป็น Draft', async () => {
      mockMapper.mockReturnValueOnce(Result.ok(mockDTO));
      mockRepository.getBibleDetail = jest.fn().mockReturnValue(Result.ok(mockGetBibleDetail));
      mockRepository.deleteBibleDetail = jest.fn().mockReturnValue(Result.ok(mockDeleteBibleDetail));
      mockMapperSuccess.mockReturnValueOnce(Result.ok(mockSuccessDTO));
      const actual = await mockHandler.execute(mockDTO);
      expect(actual.isRight()).toBeTruthy();
      expect(actual.value.getValue()).toEqual(mockSuccessDTO);
    });
  });
  describe('F5-S6-U2: กรณีที่ Bible ที่มีสถานะ Publish หรือ Cancel จะไม่สามารถลบรายการยาเดิมได้', () => {
    it('TC1: ผู้ใช้งานต้องการลบรายการ Medicine เดิมใน Bible ที่มีสถานะเป็น Published', async () => {
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
      mockRepository.deleteBibleDetail = jest.fn().mockReturnValue(Result.ok(mockDeleteBibleDetail));
      mockMapperSuccess.mockReturnValueOnce(Result.ok(mockSuccessDTO));
      const actual = await mockHandler.execute(mockDTO);
      expect(actual.isLeft()).toBeTruthy();
      expect(actual.value.errorValue()).toEqual({ message: 'Bible status not "DRAFT"' });
    });
    it('TC2: ผู้ใช้งานต้องการลบรายการ Medicine เดิมใน Bible ที่มีสถานะเป็น Cancel', async () => {
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
      mockRepository.deleteBibleDetail = jest.fn().mockReturnValue(Result.ok(mockDeleteBibleDetail));
      mockMapperSuccess.mockReturnValueOnce(Result.ok(mockSuccessDTO));
      const actual = await mockHandler.execute(mockDTO);
      expect(actual.isLeft()).toBeTruthy();
      expect(actual.value.errorValue()).toEqual({ message: 'Bible status not "DRAFT"' });
    });
    it('TC3: ผู้ใช้งานบันทึกลบไม่สำเร็จ กรณี มีปัญหาด้านอื่นๆ (Network,Database)', async () => {
      mockMapper.mockReturnValueOnce(Result.ok(mockDTO));
      mockRepository.getBibleDetail = jest.fn().mockReturnValue(Result.ok(mockGetBibleDetail));
      mockRepository.deleteBibleDetail = jest.fn().mockReturnValue(Result.fail(new Failures.DeleteFail()));
      const actual = await mockHandler.execute(mockDTO);
      expect(actual.isLeft()).toBeTruthy();
      expect(actual.value.errorValue()).toEqual({ message: 'Delete fail: [object Object]' });
    });
    describe('TC4: ผู้ใช้งานไม่สามารถบันทึกการลบยาในเอกสารได้ก็ต่อเมื่อ', () => {
      it('Result1: ไม่มีค่า Country หรือไม่มีค่า Medicine Type หรือไม่มีค่า Year หรือไม่มีค่า Species หรือไม่มีค่า Animal Type หรือไม่มีค่า รายการยาใน List', async () => {
        mockGetBibleDetail = {
          animalType: [],
          id: '1',
          country: { countryCode: 'TH', countryName: 'Thailand' },
          bibleStatus: 'DRAFT',
          species: {
            speciesCode: 'test',
            speciesName: 'test',
          },
          medType: {
            medTypeCode: 'V1',
            medTypeName: 'test',
          },
          year: 2024,
        };
        mockMapper.mockReturnValueOnce(Result.ok(mockDTO));
        mockRepository.getBibleDetail = jest.fn().mockReturnValue(Result.ok(mockGetBibleDetail));
        const actual = await mockHandler.execute(mockDTO);
        expect(actual.isLeft()).toBeTruthy();
        expect(actual.value).toEqual(new Failures.CheckConditionFail('Data in Bible record not enought to delete'));
      });
      it('Result2: ไม่มีค่า Country และไม่มีค่า Medicine Type และไม่มีค่า Year และไม่มีค่า Species และไม่มีค่า Animal Type และไม่มีค่า รายการยาใน List', async () => {
        mockGetBibleDetail = {
          animalType: [],
          id: '1',
          country: { countryCode: 'TH', countryName: 'Thailand' },
          bibleStatus: 'DRAFT',
          species: {
            speciesCode: 'test',
            speciesName: 'test',
          },
          medType: {
            medTypeCode: 'V1',
            medTypeName: 'test',
          },
          year: 2024,
        };
        mockMapper.mockReturnValueOnce(Result.ok(mockDTO));
        mockRepository.getBibleDetail = jest.fn().mockReturnValue(Result.ok(mockGetBibleDetail));
        const actual = await mockHandler.execute(mockDTO);
        expect(actual.isLeft()).toBeTruthy();
        expect(actual.value).toEqual(new Failures.CheckConditionFail('Data in Bible record not enought to delete'));
      });
    });
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
    mockRepository.getBibleDetail = jest.fn().mockReturnValue(Result.fail(new Failures.BibleDetailNotFound()));
    const actual = await mockHandler.execute(mockDTO);
    expect(actual.isLeft()).toBeTruthy();
    expect(actual.value.errorValue()).toEqual({ message: 'Bible detail not found' });
  });
  it('should return fail when Bible Status not "DRAFT"', async () => {
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
    mockRepository.deleteBibleDetail = jest.fn().mockReturnValue(Result.fail(new Failures.DeleteFail()));
    const actual = await mockHandler.execute(mockDTO);
    expect(actual.isLeft()).toBeTruthy();
    expect(actual.value.errorValue()).toEqual({ message: 'Bible status not "DRAFT"' });
  });
  it('should return fail when has only one bible detail', async () => {
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
      total: 1,
    };
    mockMapper.mockReturnValueOnce(Result.ok(mockDTO));
    mockRepository.getBibleDetail = jest.fn().mockReturnValue(Result.ok(mockGetBibleDetail));
    mockRepository.deleteBibleDetail = jest.fn().mockReturnValue(Result.fail(new Failures.DeleteFail()));
    const actual = await mockHandler.execute(mockDTO);
    expect(actual.isLeft()).toBeTruthy();
    expect(actual.value.errorValue()).toEqual({
      message: 'This is the last medicine in this bible, Please edit current medicine and try again.',
    });
  });
  it('should return fail when deleteBibleDetail fail', async () => {
    mockMapper.mockReturnValueOnce(Result.ok(mockDTO));
    mockRepository.getBibleDetail = jest.fn().mockReturnValue(Result.ok(mockGetBibleDetail));
    mockRepository.deleteBibleDetail = jest.fn().mockReturnValue(Result.fail(new Failures.DeleteFail()));
    const actual = await mockHandler.execute(mockDTO);
    expect(actual.isLeft()).toBeTruthy();
    expect(actual.value.errorValue()).toEqual({ message: 'Delete fail: [object Object]' });
  });
  it('should return success when no error deleteBibleDetail', async () => {
    mockMapper.mockReturnValueOnce(Result.ok(mockDTO));
    mockRepository.getBibleDetail = jest.fn().mockReturnValue(Result.ok(mockGetBibleDetail));
    mockRepository.deleteBibleDetail = jest.fn().mockReturnValue(Result.ok(mockDeleteBibleDetail));
    mockMapperSuccess.mockReturnValueOnce(Result.ok(mockSuccessDTO));
    const actual = await mockHandler.execute(mockDTO);
    expect(actual.isRight()).toBeTruthy();
    expect(actual.value.getValue()).toEqual(mockSuccessDTO);
  });
});

