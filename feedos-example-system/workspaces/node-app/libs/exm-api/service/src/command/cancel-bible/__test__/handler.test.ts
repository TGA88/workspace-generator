import { InhLogger, Result } from '@inh-lib/common';
import { InputDTO, OutputDTO } from '../dto';
import { Handler } from '../handler';
import {
  Repository,
  Failures,
  CancelBibleOutput,
  GetBibleDetailOutput,
} from '@fos-psc-webapi/bible-factory-core/command/cancel-bible';
const mockRepository: Repository = jest.createMockFromModule(
  '@fos-psc-webapi/bible-factory-core/command/cancel-bible',
);
const mockMapper = jest.fn();
const mockMapperSuccess = jest.fn();
const mockLogger: InhLogger = jest.createMockFromModule('@inh-lib/common');
let mockDTO: InputDTO = jest.genMockFromModule('../dto');
let mockSuccessDTO: OutputDTO = jest.genMockFromModule('../dto');
let mockGetBibleDetail: GetBibleDetailOutput = jest.genMockFromModule(
  '@fos-psc-webapi/bible-factory-core/command/cancel-bible',
);
let mockCancelBible: CancelBibleOutput = jest.genMockFromModule(
  '@fos-psc-webapi/bible-factory-core/command/cancel-bible',
);
const mockHandler = new Handler(mockMapper, mockMapperSuccess, mockRepository, mockLogger);
beforeEach(() => {
  jest.resetAllMocks();
  mockLogger.error = jest.fn();
  mockLogger.info = jest.fn();
  mockDTO = {
    id: '1',
    cancelRemark: 'test',
    uid: 'test',
  };
  mockSuccessDTO = {
    id: '1',
  };
  mockGetBibleDetail = {
    id: '1',
    status: 'ACTIVE',
    bibleStatus: 'PUBLISHED',
  };
  mockCancelBible = {
    id: '1',
  };
});
describe('TC1:ผู้ใช้งานต้องการ ยกเลิก เอกสาร Bible Factory กรณี 1 EX1.ผู้ใช้งานต้องการ ยกเลิก เอกสารที่อยู่ใน สถานะ PUBLISHED กรอก Cancel Remark และยืนยัน', () => {
  it('Result1: สถานะของเอกสาร จะถูกเปลี่ยนจาก PUBLISHED เป็น CANCEL และ ข้อมูลใน Bible จะไม่สามารถนำไปใช้งานต่อได้ในใบสั่งยาเข้าโรงงาน และ Last Modify Date,By ต้องอัพเดทตามการแก้ไขล่าสุด', async () => {
    mockMapper.mockReturnValueOnce(Result.ok(mockDTO));
    mockRepository.getBibleDetail = jest.fn().mockReturnValue(Result.ok(mockGetBibleDetail));
    mockRepository.cancelBible = jest.fn().mockReturnValue(Result.ok(mockCancelBible));
    mockMapperSuccess.mockReturnValueOnce(Result.ok(mockSuccessDTO));
    const actual = await mockHandler.execute(mockDTO);
    expect(actual.isRight()).toBeTruthy();
    expect(actual.value.getValue()).toEqual(mockSuccessDTO);
  });
});
describe('TC2:ผู้ใช้งานต้องการ ยกเลิก เอกสาร Bible Factory กรณี 2 EX2.ผู้ใช้งานต้องการ ยกเลิก เอกสารที่อยู่ใน สถานะ PUBLISHED ไม่กรอก Cancel Remark และยืนยัน', () => {
  it('Result1: จะไม่สามารถยกเลิกได้ เนื่องจากข้อมูลไม่ครบ', async () => {
    mockMapper.mockReturnValueOnce(Result.ok(mockDTO));
    mockRepository.getBibleDetail = jest.fn().mockReturnValue(Result.ok(mockGetBibleDetail));
    mockRepository.cancelBible = jest.fn().mockReturnValue(Result.ok(mockCancelBible));
    mockMapperSuccess.mockReturnValueOnce(Result.ok(mockSuccessDTO));
    const actual = await mockHandler.execute(mockDTO);
    expect(actual.isRight()).toBeTruthy();
    expect(actual.value.getValue()).toEqual(mockSuccessDTO);
  });
});
describe('TC3:ผู้ใช้งานยกเลิกไม่สำเร็จ กรณี มีปัญหาด้านอื่นๆ (Network,Database)', () => {
  it('Result1: แสดง Modal “แจ้งเตือนล้มเหลว” ', async () => {
    mockMapper.mockReturnValueOnce(Result.ok(mockDTO));
    mockRepository.getBibleDetail = jest.fn().mockReturnValue(Result.ok(mockGetBibleDetail));
    mockRepository.cancelBible = jest.fn().mockReturnValue(Result.fail('error'));
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
    expect(actual.value.errorValue()).toEqual({ message: 'Get fail' });
  });
  it('should return fail when Bible Status not "PUBLISHED"', async () => {
    mockGetBibleDetail = {
      id: '1',
      status: 'INACTIVE',
      bibleStatus: 'CANCEL',
    };
    mockMapper.mockReturnValueOnce(Result.ok(mockDTO));
    mockRepository.getBibleDetail = jest.fn().mockReturnValue(Result.ok(mockGetBibleDetail));
    mockRepository.cancelBible = jest.fn().mockReturnValue(Result.fail(new Failures.UpdateFail()));
    const actual = await mockHandler.execute(mockDTO);
    expect(actual.isLeft()).toBeTruthy();
    expect(actual.value.errorValue()).toEqual({ message: 'Bible status not "PUBLISHED"' });
  });
  it('should return fail when cancelBible fail', async () => {
    mockMapper.mockReturnValueOnce(Result.ok(mockDTO));
    mockRepository.getBibleDetail = jest.fn().mockReturnValue(Result.ok(mockGetBibleDetail));
    mockRepository.cancelBible = jest.fn().mockReturnValue(Result.fail(new Failures.UpdateFail()));
    const actual = await mockHandler.execute(mockDTO);
    expect(actual.isLeft()).toBeTruthy();
    expect(actual.value.errorValue()).toEqual({ message: 'Update fail: [object Object]' });
  });
  it('should return success when no error cancelBible', async () => {
    mockMapper.mockReturnValueOnce(Result.ok(mockDTO));
    mockRepository.getBibleDetail = jest.fn().mockReturnValue(Result.ok(mockGetBibleDetail));
    mockRepository.cancelBible = jest.fn().mockReturnValue(Result.ok(mockCancelBible));
    mockMapperSuccess.mockReturnValueOnce(Result.ok(mockSuccessDTO));
    const actual = await mockHandler.execute(mockDTO);
    expect(actual.isRight()).toBeTruthy();
    expect(actual.value.getValue()).toEqual(mockSuccessDTO);
  });
});

