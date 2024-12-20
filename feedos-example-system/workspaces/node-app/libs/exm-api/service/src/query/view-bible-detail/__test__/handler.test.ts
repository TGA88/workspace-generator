/* eslint-disable @typescript-eslint/no-explicit-any */
import { InhLogger, Result } from '@inh-lib/common';
import { InputDTO, OutputDTO } from '../dto';
import { Handler } from '../handler';
import { Repository, Failures } from '@feedos-example-system/exm-api-core/query/view-bible-detail';

const mockRepository: Repository = jest.createMockFromModule(
    '@feedos-example-system/exm-api-core/query/view-bible-detail',
);
const mockMapper = jest.fn();
const mockMapperSuccess = jest.fn();
const mockLogger: InhLogger = jest.createMockFromModule('@inh-lib/common');
let mockDTO: InputDTO = jest.genMockFromModule('../dto');
let mockSuccessDTO: OutputDTO = jest.genMockFromModule('../dto');

const mockHandler = new Handler(mockMapper, mockMapperSuccess, mockRepository, mockLogger);
beforeEach(() => {
    jest.resetAllMocks();
    mockLogger.error = jest.fn();
    mockLogger.info = jest.fn();
    mockDTO = {
        id: '1',
        page: 0,
        size: 100,
        search: undefined,
    };
    mockSuccessDTO = {
        cancelRemark: 'test',
        animalType: [{
            animalTypeCode: 'test',
            animalTypeName: 'test',
        }],
        medType: {
            medTypeCode: 'test',
            medTypeName: 'test',
        },
        country: {
            countryCode: 'test',
            countryName: 'test'
        },
        createBy: 'test',
        year: 2024,
        createAt: 10 as any,
        remarks: 'test',
        id: 'stest',
        items: [] as any,
        species: {
            speciesCode: 'test',
            speciesName: 'test'
        },
        status: 'test',
        total: 10,
        updateAt: 10 as any,
        updateBy: 'test',

    };
    // mockGetBibleDetail = {
    //     animalType: [{
    //         animalTypeCode: 'test',
    //         animalTypeName: 'test',
    //     }],
    //     country: {
    //         countryCode: 'test',
    //         countryName: 'test'
    //     },
    //     createBy: 'test',
    //     createAt: 10 as any,
    //     docDate: 'test',
    //     docNo: 'test',
    //     remarks: 'test',
    //     endDate: 'test',
    //     id: 'stest',
    //     items: [] as any,
    //     species: {
    //         speciesCode: 'test',
    //         speciesName: 'test'
    //     },
    //     startDate: 'test',
    //     status: 'test',
    //     total: 10,
    //     updateAt: 10 as any,
    //     updateBy: 'test',
    //     year: 2024

    // };
});
describe('F5-S3: แสดง Bible Detail', () => {

    it('Result 1 : สามารถแสดงรายการ  Bible detail', async () => {
        mockMapper.mockReturnValueOnce(Result.ok(mockDTO));
        mockRepository.getDetailBible = jest.fn().mockReturnValue(
            Result.ok({
                items: [],
                total: 0,
            }),
        );
        mockRepository.getBibleDetailOfItems = jest.fn().mockReturnValue(
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
describe('TC2: ไม่สามารถแสดงรายการ Bible  ได้', () => {
    it('Result 1: เกิดความขัดข้องในการเชื่อมต่อกับ database หรือ unexpected error', async () => {
        mockMapper.mockReturnValueOnce(Result.ok(mockDTO));
        mockRepository.getDetailBible = jest.fn().mockReturnValue(Result.fail(new Failures.GetFail()));
        const actual = await mockHandler.execute(mockDTO);
        expect(actual.isLeft()).toBeTruthy();
        expect(actual.value).toEqual(new Failures.GetFail());
    });
});
describe('Unit Test Handler', () => {
    it('should return fail when mapping fail', async () => {
        mockMapper.mockReturnValueOnce(Result.fail('error'));
        const actual = await mockHandler.execute(mockDTO);
        expect(actual.isLeft()).toBeTruthy();
        expect(actual.value).toEqual(new Failures.ParseFail());
    });
    it('should return Get Fail when Bible fail', async () => {
        mockMapper.mockReturnValueOnce(Result.ok(mockDTO));
        mockRepository.getDetailBible = jest.fn().mockReturnValue(Result.fail(new Failures.GetFail()));
        const actual = await mockHandler.execute(mockDTO);
        expect(actual.isLeft()).toBeTruthy();
        expect(actual.value).toEqual(new Failures.GetFail());
    });
    it('should return fail when getBibleDetailOfItem fail', async () => {
        mockMapper.mockReturnValueOnce(Result.ok(mockDTO));
        mockRepository.getDetailBible = jest.fn().mockReturnValue(Result.ok());
        mockRepository.getBibleDetailOfItems = jest.fn().mockReturnValue(Result.fail(new Failures.GetFail()));
        const actual = await mockHandler.execute(mockDTO);
        expect(actual.isLeft()).toBeTruthy();
        expect(actual.value).toEqual(new Failures.GetFail());
    });
    it('should return fail when getBibleDetailOfItem fail', async () => {
        mockMapper.mockReturnValueOnce(Result.ok(mockDTO));
        mockRepository.getDetailBible = jest.fn().mockReturnValue(Result.ok());
        mockRepository.getBibleDetailOfItems = jest.fn().mockReturnValue(Result.ok({ items: [], total: 0 }));
        mockMapperSuccess.mockReturnValueOnce(Result.ok(mockSuccessDTO));
        const actual = await mockHandler.execute(mockDTO);
        expect(actual.isRight()).toBeTruthy();
        expect(actual.value.getValue()).toEqual(mockSuccessDTO);
    });
});
