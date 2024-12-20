import { InhLogger, Result } from '@inh-lib/common';
import { InputDTO, OutputDTO } from '../dto';
import { Handler } from '../handler';
import {
  Repository,
  Failures,
  UpdateBibleDetailStatusOutput,
  GetBibleDetailOutput,
} from '@fos-psc-webapi/bible-factory-core/command/update-bible-detail-status';
const mockRepository: Repository = jest.createMockFromModule(
  '@fos-psc-webapi/bible-factory-core/command/update-bible-detail-status',
);
const mockMapper = jest.fn();
const mockMapperSuccess = jest.fn();
const mockLogger: InhLogger = jest.createMockFromModule('@inh-lib/common');
let mockDTO: InputDTO = jest.genMockFromModule('../dto');
let mockSuccessDTO: OutputDTO = jest.genMockFromModule('../dto');
let mockGetBibleDetail: GetBibleDetailOutput = jest.genMockFromModule(
  '@fos-psc-webapi/bible-factory-core/command/update-bible-detail-status',
);
let mockUpdateBibleDetail: UpdateBibleDetailStatusOutput = jest.genMockFromModule(
  '@fos-psc-webapi/bible-factory-core/command/update-bible-detail-status',
);
const mockHandler = new Handler(mockMapper, mockMapperSuccess, mockRepository, mockLogger);
beforeEach(() => {
  jest.resetAllMocks();
  mockLogger.error = jest.fn();
  mockLogger.info = jest.fn();
  mockDTO = {
    id: '1',
    detailId: 'test',
    uid: 'test',
    status: 'INACTIVE',
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
    bibleStatus: 'PUBLISHED',
  };
  mockUpdateBibleDetail = {
    id: '1',
  };
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
  it('should return fail when Bible Status "CANCEL"', async () => {
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
    mockRepository.updateBibleDetailStatus = jest.fn().mockReturnValue(Result.fail(new Failures.UpdateFail()));
    const actual = await mockHandler.execute(mockDTO);
    expect(actual.isLeft()).toBeTruthy();
    expect(actual.value.errorValue()).toEqual({ message: 'Bible status not "DRAFT" or "PUBLISHED"' });
  });
  it('should return fail when updateBibleDetailStatus fail', async () => {
    mockMapper.mockReturnValueOnce(Result.ok(mockDTO));
    mockRepository.getBibleDetail = jest.fn().mockReturnValue(Result.ok(mockGetBibleDetail));
    mockRepository.updateBibleDetailStatus = jest.fn().mockReturnValue(Result.fail(new Failures.UpdateFail()));
    const actual = await mockHandler.execute(mockDTO);
    expect(actual.isLeft()).toBeTruthy();
    expect(actual.value.errorValue()).toEqual({ message: 'Update fail: [object Object]' });
  });
  it('should return success when no error updateBibleDetailStatus', async () => {
    mockMapper.mockReturnValueOnce(Result.ok(mockDTO));
    mockRepository.getBibleDetail = jest.fn().mockReturnValue(Result.ok(mockGetBibleDetail));
    mockRepository.updateBibleDetailStatus = jest.fn().mockReturnValue(Result.ok(mockUpdateBibleDetail));
    mockMapperSuccess.mockReturnValueOnce(Result.ok(mockSuccessDTO));
    const actual = await mockHandler.execute(mockDTO);
    expect(actual.isRight()).toBeTruthy();
    expect(actual.value.getValue()).toEqual(mockSuccessDTO);
  });
});

