import { InhLogger, Result } from '@inh-lib/common';
import { InputDTO, OutputDTO } from '../dto';
import { Handler } from '../handler';
import {
    Repository,
    Failures,
    DuplicateBibleOutput,
    // GetAllAnimalTypeOutput,
    CheckBibleStatusOutput
} from '@fos-psc-webapi/bible-factory-core/command/duplicate-bible';
const mockRepository: Repository = jest.createMockFromModule(
    '@fos-psc-webapi/bible-factory-core/command/duplicate-bible',
);
const mockMapper = jest.fn();
const mockMapperSuccess = jest.fn();
const mockLogger: InhLogger = jest.createMockFromModule('@inh-lib/common');
let mockDTO: InputDTO = jest.genMockFromModule('../dto');
let mockSuccessDTO: OutputDTO = jest.genMockFromModule('../dto');
// let mockGetAllAnimalType: GetAllAnimalTypeOutput = jest.genMockFromModule(
//     '@fos-psc-webapi/bible-factory-core/command/duplicate-bible',
// );
let mockGetAllStatus: CheckBibleStatusOutput = jest.genMockFromModule(
    '@fos-psc-webapi/bible-factory-core/command/duplicate-bible',
);
let mockCreateBible: DuplicateBibleOutput = jest.genMockFromModule(
    '@fos-psc-webapi/bible-factory-core/command/duplicate-bible',
);
const mockHandler = new Handler(mockRepository, mockMapper, mockMapperSuccess, mockLogger);
beforeEach(() => {
    jest.resetAllMocks();
    mockLogger.error = jest.fn();
    mockLogger.info = jest.fn();
    mockDTO = {
        year: 2024,
        id: '123',
        animalType: [
            {
                animalTypeCode: 'test',
                animalTypeName: 'test',
            },
        ],
        uid: 'test',

    };
    mockSuccessDTO = {
        id: 'test',
    };
    mockCreateBible = {
        id: 'test',
    };
    mockGetAllStatus = {
        status: 'test'
    };
    // mockGetAllAnimalType = {
    //     animalType: [
    //         {
    //             animalTypeCode: 'test',
    //             animalTypeName: 'test',
    //         },
    //     ],
    // };
});
describe('F5-S8: คัดลอกใบ Bible Factory', () => {
    it('TC1:ผู้ใช้งานต้องการ คัดลอก เอกสาร Bible Factory ', async () => {
        mockDTO = {
            year: 2024,
            id: '1234',
            animalType: [
                {
                    animalTypeCode: 'dd',
                    animalTypeName: 'www',
                },
            ],
            uid: 'test',

        };
        mockMapper.mockReturnValueOnce(Result.ok(mockDTO));
        mockRepository.checkStatus = jest.fn().mockReturnValue(Result.ok(mockGetAllStatus));
        mockRepository.duplicateBible = jest.fn().mockReturnValue(Result.ok(mockCreateBible));
        mockMapperSuccess.mockReturnValueOnce(Result.ok(mockSuccessDTO));
        const actual = await mockHandler.execute(mockDTO);
        console.log('actual', actual)
        expect(actual.isRight()).toBeTruthy();
        expect(actual.value.getValue()).toEqual(mockSuccessDTO);
    });

    it('TC3:ผู้ใช้งานบันทึกการสร้างไม่สำเร็จ กรณี มีปัญหาด้านอื่นๆ (Network,Database)', async () => {
        mockDTO = {
            year: 2024,
            id: '1234',
            animalType: [
                {
                    animalTypeCode: 'dd',
                    animalTypeName: 'www',
                },
            ],
            uid: 'test',

        };
        mockMapper.mockReturnValueOnce(Result.ok(mockDTO));
        mockRepository.checkStatus = jest.fn().mockReturnValue(Result.ok(mockGetAllStatus));

        mockRepository.duplicateBible = jest.fn().mockReturnValue(Result.fail('error'));
        const actual = await mockHandler.execute(mockDTO);
        expect(actual.isLeft()).toBeTruthy();
        expect(actual.value).toEqual(new Failures.DuplicateFail('error'));
    });
});
describe('Unit Test Handler', () => {
    it('should return fail when mapping fail', async () => {
        mockMapper.mockReturnValueOnce(Result.fail('error'));
        const actual = await mockHandler.execute(mockDTO);
        expect(actual.isLeft()).toBeTruthy();
        expect(actual.value).toEqual(new Failures.ParseFail());
    });
    it('should return fail when checkStatus fail', async () => {
        mockMapper.mockReturnValueOnce(Result.ok(mockDTO));
        mockRepository.checkStatus = jest.fn().mockReturnValue(Result.fail('error'));
        const actual = await mockHandler.execute(mockDTO);

        expect(actual.isLeft()).toBeTruthy();
        expect(actual.value).toEqual(new Failures.GetFail('error'));
    });
    it('should return status fail when status is cancel', async () => {
        mockGetAllStatus = {
            status: 'CANCEL'
        };
        mockMapper.mockReturnValueOnce(Result.ok(mockDTO));
        mockRepository.checkStatus = jest.fn().mockReturnValue(Result.ok(mockGetAllStatus));
        const actual = await mockHandler.execute(mockDTO);
        expect(actual.isLeft()).toBeTruthy();
        expect(actual.value).toEqual(new Failures.StatusFail('status Is "CANCEL"'));
    });
    it('should return fail when duplicate fail', async () => {
        mockMapper.mockReturnValueOnce(Result.ok(mockDTO));
        mockRepository.checkStatus = jest.fn().mockReturnValue(Result.ok(mockGetAllStatus));
        mockRepository.duplicateBible = jest.fn().mockReturnValue(Result.fail('error'));
        const actual = await mockHandler.execute(mockDTO);
        expect(actual.isLeft()).toBeTruthy();
        expect(actual.value).toEqual(new Failures.DuplicateFail('error'));
    });
    it('should return success when no error', async () => {
        mockMapper.mockReturnValueOnce(Result.ok(mockDTO));
        mockRepository.checkStatus = jest.fn().mockReturnValue(Result.ok(mockGetAllStatus));
        mockRepository.duplicateBible = jest.fn().mockReturnValue(Result.ok(mockCreateBible));
        mockMapperSuccess.mockReturnValueOnce(Result.ok(mockSuccessDTO));
        const actual = await mockHandler.execute(mockDTO);
        expect(actual.isRight()).toBeTruthy();
        expect(actual.value.getValue()).toEqual(mockSuccessDTO);
    });

});

