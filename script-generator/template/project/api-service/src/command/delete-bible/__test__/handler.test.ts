import { InhLogger, Result } from "@inh-lib/common"
import { InputDTO, OutputDTO } from '../dto'
import { Handler } from '../handler'
import { Repository, Failures, CheckBbibleStatusOutput, DeleteBibleOutput } from '@gu-example-system/exm-api-core/command/delete-bible'

const mockRepository: Repository
    = jest.createMockFromModule("@gu-example-system/exm-api-core/command/delete-bible")
const mockMapper = jest.fn()
const mockMapperSuccess = jest.fn()
const mockLogger: InhLogger = jest.createMockFromModule("@inh-lib/common")
let mockDTO: InputDTO = jest.genMockFromModule('../dto')
let mockSuccessDTO: OutputDTO = jest.genMockFromModule('../dto')
let mockCheckPrescriptionStatus: CheckBbibleStatusOutput = jest.genMockFromModule('@gu-example-system/exm-api-core/command/delete-bible')
// let mockdeletePrescriptionDetail: DeletePrescriptionOutput = jest.genMockFromModule('@fos-mine-webapi/prescription-core/delete-prescription')
let mockdeletePrescription: DeleteBibleOutput = jest.genMockFromModule('@gu-example-system/exm-api-core/command/delete-bible')
// let mockHasPrescriptionDetail: HasPrescriptionDetailOutput = jest.genMockFromModule('@fos-mine-webapi/prescription-core/delete-prescription')

const mockHandler = new Handler(mockRepository, mockMapper, mockMapperSuccess, mockLogger)

beforeEach(() => {
    jest.resetAllMocks();
    mockLogger.error = jest.fn();
    mockLogger.info = jest.fn();
    mockDTO = {
        id: '1'
    };
    mockSuccessDTO = {
        id: '1',
    };
    mockdeletePrescription = {
        id: '1'
    },
        // mockdeletePrescriptionDetail = {
        //     id: '1'
        // },
        mockCheckPrescriptionStatus = {
            status: "DRAFT"
        }


});

describe('Unit Test Handler', () => {
    it('should return fail when mapping fail', async () => {
        mockMapper.mockReturnValueOnce(Result.fail('error'));
        const actual = await mockHandler.execute(mockDTO);
        expect(actual.isLeft()).toBeTruthy();
        expect(actual.value).toEqual(new Failures.ParseFail());
    });
    it('should return GetFail when checkBibleStatus fail ', async () => {
        mockMapper.mockReturnValueOnce(Result.ok(mockDTO));
        mockRepository.checkBibleStatus = jest.fn().mockReturnValue(Result.fail('error'));
        const actual = await mockHandler.execute(mockDTO);
        expect(actual.isLeft()).toBeTruthy();
        expect(actual.value).toEqual(new Failures.GetFail('error'));
    });
    it('should return fail when status not equal "DRAFT" ', async () => {
        mockCheckPrescriptionStatus = {
            status: 'SUBMIT'
        }
        mockMapper.mockReturnValueOnce(Result.ok(mockDTO));
        mockRepository.checkBibleStatus = jest.fn().mockReturnValue(Result.ok(mockCheckPrescriptionStatus));

        mockRepository.deleteBible = jest.fn().mockReturnValue(Result.ok(mockCheckPrescriptionStatus));

        const actual = await mockHandler.execute(mockDTO);
        expect(actual.isLeft()).toBeTruthy();
        expect(actual.value).toEqual(new Failures.DeleteFail('status not "DRAFT"'));
    });

    it('should return fail when deleteBible fail', async () => {
        mockCheckPrescriptionStatus = {
            status: 'DRAFT'
        }
        mockMapper.mockReturnValueOnce(Result.ok(mockDTO));
        mockRepository.checkBibleStatus = jest.fn().mockReturnValue(Result.ok(mockCheckPrescriptionStatus));
        mockRepository.deleteBible = jest.fn().mockReturnValue(Result.fail('error'));

        const actual = await mockHandler.execute(mockDTO);
        expect(actual.isLeft()).toBeTruthy();
        expect(actual.value).toEqual(new Failures.DeleteFail('error'));
    });

    it('should return success when no error', async () => {
        mockMapper.mockReturnValueOnce(Result.ok(mockDTO));
        mockRepository.deleteBible = jest.fn().mockReturnValue(Result.ok(mockdeletePrescription));
        // mockRepository.deletePrescriptionDetail = jest.fn().mockReturnValue(Result.ok(mockdeletePrescriptionDetail));
        mockRepository.checkBibleStatus = jest.fn().mockReturnValue(Result.ok(mockCheckPrescriptionStatus));
        // mockRepository.hasPrescriptionDetail = jest.fn().mockReturnValue(Result.ok(true));

        mockMapperSuccess.mockReturnValueOnce(Result.ok(mockSuccessDTO));
        const actual = await mockHandler.execute(mockDTO);
        expect(actual.isRight()).toBeTruthy();
        expect(actual.value.getValue()).toEqual(mockSuccessDTO);
    })
})
