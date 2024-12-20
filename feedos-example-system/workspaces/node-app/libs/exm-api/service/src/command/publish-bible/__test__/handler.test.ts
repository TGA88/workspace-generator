import { InhLogger, Result } from '@inh-lib/common';
import { InputDTO, OutputDTO } from '../dto';
import { Handler } from '../handler';
import {
  Repository,
  Failures,
  ChangeBibleStatusOutput,
  GetCreaterEmailOutput,
  GetBibleDetailOutput,
} from '@fos-psc-webapi/bible-factory-core/command/publish-bible';
import { FosPscNotifyAxiosClient } from '@fos-pscnotify-webapi/pscnotify-api-client';
const mockRepository: Repository = jest.createMockFromModule(
  '@fos-psc-webapi/bible-factory-core/command/publish-bible',
);
const mockMapper = jest.fn();
const mockMapperSuccess = jest.fn();
const mockLogger: InhLogger = jest.createMockFromModule('@inh-lib/common');
let mockDTO: InputDTO = jest.genMockFromModule('../dto');
let mockSuccessDTO: OutputDTO = jest.genMockFromModule('../dto');
const mockPscNotify: FosPscNotifyAxiosClient = jest.genMockFromModule('@fos-pscnotify-webapi/pscnotify-api-client');
let mockChangeBibleStatus: ChangeBibleStatusOutput = jest.genMockFromModule(
  '@fos-psc-webapi/bible-factory-core/command/publish-bible',
);
let mockGetCreatorEmail: GetCreaterEmailOutput = jest.genMockFromModule(
  '@fos-psc-webapi/bible-factory-core/command/publish-bible',
);
let mockGetBibleDetail: GetBibleDetailOutput = jest.genMockFromModule(
  '@fos-psc-webapi/bible-factory-core/command/publish-bible',
);
const mockHandler = new Handler(mockMapper, mockMapperSuccess, mockRepository, mockLogger, mockPscNotify);
beforeEach(() => {
  jest.resetAllMocks();
  mockLogger.error = jest.fn();
  mockLogger.info = jest.fn();
  mockDTO = {
    id: 'test',
    veterinarianCode: 'test',
  };
  mockSuccessDTO = {
    id: 'test',
  };
  mockChangeBibleStatus = {
    createBy: 'test',
    id: 'test',
  };
  mockGetCreatorEmail = {
    email: 'test@gmail.com',
  };
  mockGetBibleDetail = {
    bibleAnimalType: [
      {
        animalTypeCode: 'test',
        animalTypeName: 'test',
      },
    ],
    bibleDetail: [
      {
        medCode: 'test',
      },
    ],
    bibleStatus: 'DRAFT',
    medTypeCode: 'test',
    speciesCode: 'test',
    speciesName: 'test',
    year: 2024,
    createBy: 'test',
  };
});
describe('F5-S7-U1: ต้องการ Publish เอกสารและส่งอีเมล์แจ้งเตือน', () => {
  it('TC1:ผู้ใช้งานต้องการ Publish เอกสารที่อยู่ใน สถานะ “Draft” EX1.Publish เอกสารสำเร็จ Result1: Status จะเปลี่ยนจาก “Draft” เป็น “Published” และ ข้อมูลใน Bible จะสามารถนำไปใช้งานต่อได้ในใบสั่งยาเข้าโรงงาน และ Last Modify Date,By ต้องอัพเดทตามการแก้ไขล่าสุดและ Icon Publish จะถูกเปลี่ยนเป็น Notify และ เมื่ออีเมล์ถูกส่งสำเร็จ ระบบควรแสดงข้อความยืนยันการส่งอีเมล์ให้ผู้ใช้ทราบ (ส่งไปยังผู้ที่กด Publish)', async () => {
    mockGetBibleDetail = {
      bibleAnimalType: [
        {
          animalTypeCode: 'test',
          animalTypeName: 'test',
        },
      ],
      bibleDetail: [
        {
          medCode: 'test',
        },
      ],
      bibleStatus: 'DRAFT',
      medTypeCode: 'test',
      speciesCode: 'test',
      speciesName: 'test',
      year: 2024,
      createBy: 'test',
    };
    mockMapper.mockReturnValueOnce(Result.ok(mockDTO));
    mockRepository.getBibleDetail = jest.fn().mockReturnValue(Result.ok(mockGetBibleDetail));
    mockRepository.getIsPublished = jest.fn().mockReturnValue(Result.ok({ items: [], total: 0 }));
    mockRepository.changeBibleStatus = jest.fn().mockReturnValue(Result.ok(mockChangeBibleStatus));
    mockRepository.getCreaterEmail = jest.fn().mockReturnValue(Result.ok(mockGetCreatorEmail));
    mockPscNotify.sendEmail = jest.fn().mockReturnValue(Result.ok());
    mockMapperSuccess.mockReturnValueOnce(Result.ok(mockSuccessDTO));
    const actual = await mockHandler.execute(mockDTO);
    expect(actual.isRight()).toBeTruthy();
    expect(actual.value.getValue()).toEqual(mockSuccessDTO);
  });
  it('TC4.ผู้ใช้งานต้องการ Publish เอกสารที่อยู่ใน สถานะ “Cancel” Rsult4: จะไม่สามารถ Publish ได้(ไม่แสดงปุ่ม Publish หรือ Notify) ', async () => {
    mockGetBibleDetail = {
      bibleAnimalType: [
        {
          animalTypeCode: 'test',
          animalTypeName: 'test',
        },
      ],
      bibleDetail: [
        {
          medCode: 'test',
        },
      ],
      bibleStatus: 'CANCEL',
      medTypeCode: 'test',
      speciesCode: 'test',
      speciesName: 'test',
      year: 2024,
      createBy: 'test',
    };
    mockMapper.mockReturnValueOnce(Result.ok(mockDTO));
    mockRepository.getBibleDetail = jest.fn().mockReturnValue(Result.ok(mockGetBibleDetail));
    mockRepository.getIsPublished = jest.fn().mockReturnValue(Result.ok({ items: [], total: 0 }));
    const actual = await mockHandler.execute(mockDTO);
    expect(actual.isLeft()).toBeTruthy();
    expect(actual.value).toEqual(new Failures.UpdateFail('BIBLE_STATUS is CANCEL or PUBLISHED'));
  });
  it('TC5:ผู้ใช้งานPublishไม่สำเร็จ กรณี มีปัญหาด้านอื่นๆ (Network,Database) Result1: แสดง Modal “แจ้งเตือนล้มแหลว” ', async () => {
    mockGetBibleDetail = {
      bibleAnimalType: [
        {
          animalTypeCode: 'test',
          animalTypeName: 'test',
        },
      ],
      bibleDetail: [
        {
          medCode: 'test',
        },
      ],
      bibleStatus: 'DRAFT',
      medTypeCode: 'test',
      speciesCode: 'test',
      speciesName: 'test',
      year: 2024,
      createBy: 'test',
    };
    mockMapper.mockReturnValueOnce(Result.ok(mockDTO));
    mockRepository.getBibleDetail = jest.fn().mockReturnValue(Result.ok(mockGetBibleDetail));
    mockRepository.getIsPublished = jest.fn().mockReturnValue(Result.ok({ items: [], total: 0 }));
    mockRepository.changeBibleStatus = jest.fn().mockReturnValue(Result.fail('error'));
    const actual = await mockHandler.execute(mockDTO);
    expect(actual.isLeft()).toBeTruthy();
    expect(actual.value).toEqual(new Failures.UpdateFail('error'));
  });
  it('TC6:ผู้ใช้งานไม่สามารถPublishเอกสารได้ก็ต่อเมื่อ Result1: ไม่มีค่า Country หรือไม่มีค่า Medicine Type หรือไม่มีค่า Year หรือไม่มีค่า Species หรือไม่มีค่า Animal Type หรือไม่มีค่า รายการยาใน List', async () => {
    mockGetBibleDetail = {
      bibleAnimalType: [],
      bibleDetail: [
        {
          medCode: 'test',
        },
      ],
      bibleStatus: 'DRAFT',
      medTypeCode: 'test',
      speciesCode: 'test',
      speciesName: 'test',
      year: 2024,
      createBy: 'test',
    };
    mockMapper.mockReturnValueOnce(Result.ok(mockDTO));
    mockRepository.getBibleDetail = jest.fn().mockReturnValue(Result.ok(mockGetBibleDetail));
    mockRepository.getIsPublished = jest.fn().mockReturnValue(Result.ok({ items: [], total: 0 }));
    const actual = await mockHandler.execute(mockDTO);
    expect(actual.isLeft()).toBeTruthy();
    expect(actual.value).toEqual(
      new Failures.UpdateFail('Data in Bible record not enought to change BIBLE_STATUS to PUBLISHED'),
    );
  });
});
describe('Unit Test Handler', () => {
  it('should return fail when mapping fail', async () => {
    mockMapper.mockReturnValueOnce(Result.fail('error'));
    const actual = await mockHandler.execute(mockDTO);
    expect(actual.isLeft()).toBeTruthy();
    expect(actual.value).toEqual(new Failures.ParseFail());
  });
  it('should return update fail when getBibleDetail fail', async () => {
    mockMapper.mockReturnValueOnce(Result.ok(mockDTO));
    mockRepository.getBibleDetail = jest.fn().mockReturnValue(Result.fail('error'));
    const actual = await mockHandler.execute(mockDTO);
    expect(actual.isLeft()).toBeTruthy();
    expect(actual.value).toEqual(new Failures.UpdateFail('error'));
  });
  it('should return fail if getIsPublish fail', async () => {
    mockGetBibleDetail = {
      bibleAnimalType: [
        {
          animalTypeCode: 'test',
          animalTypeName: 'test',
        },
      ],
      bibleDetail: [
        {
          medCode: 'test',
        },
      ],
      bibleStatus: 'DRAFT',
      medTypeCode: 'test',
      speciesCode: 'test',
      speciesName: 'test',
      year: 2024,
      createBy: 'test',
    };
    mockMapper.mockReturnValueOnce(Result.ok(mockDTO));
    mockRepository.getBibleDetail = jest.fn().mockReturnValue(Result.ok(mockGetBibleDetail));
    mockRepository.getIsPublished = jest.fn().mockReturnValue(Result.fail('error'));
    const actual = await mockHandler.execute(mockDTO);
    expect(actual.isLeft()).toBeTruthy();
    expect(actual.value).toEqual(new Failures.UpdateFail('error'));
  });
  it('should return fail if getPublish.items.length > 0 because has data has already publish fail', async () => {
    mockGetBibleDetail = {
      bibleAnimalType: [
        {
          animalTypeCode: 'test',
          animalTypeName: 'test',
        },
      ],
      bibleDetail: [
        {
          medCode: 'test',
        },
      ],
      bibleStatus: 'DRAFT',
      medTypeCode: 'test',
      speciesCode: 'test',
      speciesName: 'test',
      year: 2024,
      createBy: 'test',
    };
    mockMapper.mockReturnValueOnce(Result.ok(mockDTO));
    mockRepository.getBibleDetail = jest.fn().mockReturnValue(Result.ok(mockGetBibleDetail));
    mockRepository.getIsPublished = jest.fn().mockReturnValue(Result.ok({ items: [{ id: 'test' }], total: 1 }));
    const actual = await mockHandler.execute(mockDTO);
    expect(actual.isLeft()).toBeTruthy();
    expect(actual.value).toEqual(
      new Failures.UpdateFail('There is already have BIBLE with this same Year and Animal Type'),
    );
  });
  it('should return update fail when check bible status fail', async () => {
    mockGetBibleDetail = {
      bibleAnimalType: [
        {
          animalTypeCode: 'test',
          animalTypeName: 'test',
        },
      ],
      bibleDetail: [
        {
          medCode: 'test',
        },
      ],
      bibleStatus: 'CANCEL',
      medTypeCode: 'test',
      speciesCode: 'test',
      speciesName: 'test',
      year: 2024,
      createBy: 'test',
    };
    mockMapper.mockReturnValueOnce(Result.ok(mockDTO));
    mockRepository.getBibleDetail = jest.fn().mockReturnValue(Result.ok(mockGetBibleDetail));
    mockRepository.getIsPublished = jest.fn().mockReturnValue(Result.ok({ items: [], total: 0 }));
    const actual = await mockHandler.execute(mockDTO);
    expect(actual.isLeft()).toBeTruthy();
    expect(actual.value).toEqual(new Failures.UpdateFail('BIBLE_STATUS is CANCEL or PUBLISHED'));
  });
  it('should return update fail when check data fail', async () => {
    mockGetBibleDetail = {
      bibleAnimalType: [],
      bibleDetail: [
        {
          medCode: 'test',
        },
      ],
      bibleStatus: 'DRAFT',
      medTypeCode: 'test',
      speciesCode: 'test',
      speciesName: 'test',
      year: 2024,
      createBy: 'test',
    };
    mockMapper.mockReturnValueOnce(Result.ok(mockDTO));
    mockRepository.getBibleDetail = jest.fn().mockReturnValue(Result.ok(mockGetBibleDetail));
    mockRepository.getIsPublished = jest.fn().mockReturnValue(Result.ok({ items: [], total: 0 }));
    const actual = await mockHandler.execute(mockDTO);
    expect(actual.isLeft()).toBeTruthy();
    expect(actual.value).toEqual(
      new Failures.UpdateFail('Data in Bible record not enought to change BIBLE_STATUS to PUBLISHED'),
    );
  });
  it('should return update fail when change bible status fail', async () => {
    mockGetBibleDetail = {
      bibleAnimalType: [
        {
          animalTypeCode: 'test',
          animalTypeName: 'test',
        },
      ],
      bibleDetail: [
        {
          medCode: 'test',
        },
      ],
      bibleStatus: 'DRAFT',
      medTypeCode: 'test',
      speciesCode: 'test',
      speciesName: 'test',
      year: 2024,
      createBy: 'test',
    };
    mockMapper.mockReturnValueOnce(Result.ok(mockDTO));
    mockRepository.getBibleDetail = jest.fn().mockReturnValue(Result.ok(mockGetBibleDetail));
    mockRepository.getIsPublished = jest.fn().mockReturnValue(Result.ok({ items: [], total: 0 }));
    mockRepository.changeBibleStatus = jest.fn().mockReturnValue(Result.fail('error'));
    const actual = await mockHandler.execute(mockDTO);
    expect(actual.isLeft()).toBeTruthy();
    expect(actual.value).toEqual(new Failures.UpdateFail('error'));
  });
  it('should return update fail when getCreaterEmail fail', async () => {
    mockGetBibleDetail = {
      bibleAnimalType: [
        {
          animalTypeCode: 'test',
          animalTypeName: 'test',
        },
      ],
      bibleDetail: [
        {
          medCode: 'test',
        },
      ],
      bibleStatus: 'DRAFT',
      medTypeCode: 'test',
      speciesCode: 'test',
      speciesName: 'test',
      year: 2024,
      createBy: 'test',
    };
    mockMapper.mockReturnValueOnce(Result.ok(mockDTO));
    mockRepository.getBibleDetail = jest.fn().mockReturnValue(Result.ok(mockGetBibleDetail));
    mockRepository.getIsPublished = jest.fn().mockReturnValue(Result.ok({ items: [], total: 0 }));
    mockRepository.changeBibleStatus = jest.fn().mockReturnValue(Result.ok(mockChangeBibleStatus));
    mockRepository.getCreaterEmail = jest.fn().mockReturnValue(Result.fail('error'));
    const actual = await mockHandler.execute(mockDTO);
    expect(actual.isLeft()).toBeTruthy();
    expect(actual.value).toEqual(new Failures.UpdateFail('error'));
  });
  it('should return update fail when sendEmail fail', async () => {
    mockGetBibleDetail = {
      bibleAnimalType: [
        {
          animalTypeCode: 'test',
          animalTypeName: 'test',
        },
      ],
      bibleDetail: [
        {
          medCode: 'test',
        },
      ],
      bibleStatus: 'DRAFT',
      medTypeCode: 'test',
      speciesCode: 'test',
      speciesName: 'test',
      year: 2024,
      createBy: 'test',
    };
    mockMapper.mockReturnValueOnce(Result.ok(mockDTO));
    mockRepository.getBibleDetail = jest.fn().mockReturnValue(Result.ok(mockGetBibleDetail));
    mockRepository.getIsPublished = jest.fn().mockReturnValue(Result.ok({ items: [], total: 0 }));
    mockRepository.changeBibleStatus = jest.fn().mockReturnValue(Result.ok(mockChangeBibleStatus));
    mockRepository.getCreaterEmail = jest.fn().mockReturnValue(Result.ok(mockGetCreatorEmail));
    mockPscNotify.sendEmail = jest.fn().mockReturnValue(Result.fail('error'));
    const actual = await mockHandler.execute(mockDTO);
    expect(actual.isLeft()).toBeTruthy();
    expect(actual.value).toEqual(new Failures.UpdateFail('error'));
  });

  it('should return success when no error getCountry', async () => {
    mockGetBibleDetail = {
      bibleAnimalType: [
        {
          animalTypeCode: 'test',
          animalTypeName: 'test',
        },
      ],
      bibleDetail: [
        {
          medCode: 'test',
        },
      ],
      bibleStatus: 'DRAFT',
      medTypeCode: 'test',
      speciesCode: 'test',
      speciesName: 'test',
      year: 2024,
      createBy: 'test',
    };
    mockMapper.mockReturnValueOnce(Result.ok(mockDTO));
    mockRepository.getBibleDetail = jest.fn().mockReturnValue(Result.ok(mockGetBibleDetail));
    mockRepository.getIsPublished = jest.fn().mockReturnValue(Result.ok({ items: [], total: 0 }));
    mockRepository.changeBibleStatus = jest.fn().mockReturnValue(Result.ok(mockChangeBibleStatus));
    mockRepository.getCreaterEmail = jest.fn().mockReturnValue(Result.ok(mockGetCreatorEmail));
    mockPscNotify.sendEmail = jest.fn().mockReturnValue(Result.ok());
    mockMapperSuccess.mockReturnValueOnce(Result.ok(mockSuccessDTO));
    const actual = await mockHandler.execute(mockDTO);
    expect(actual.isRight()).toBeTruthy();
    expect(actual.value.getValue()).toEqual(mockSuccessDTO);
  });
});
