import * as AWS from '@aws-sdk/client-sns';

import { UniqueEntityID } from '@inh-lib/ddd';
import { AwsSnsProducerConfig, InhHealthCheckCommandItf, InhLogger, InhMessageFormat, InhProducerClientItf, InhProducerConfig, InhProducerProviderItf, InhPublishCommandItf, MakeInhHealthCheckCommandFn, MakeInhPublishCommandFn, Result } from '@inh-lib/common'

import { array } from 'zod';



export class AxSnsProducerProvider implements InhProducerProviderItf {
    private logger: InhLogger
    constructor(logger: InhLogger) {
        this.logger = logger
    }
    makeProducerClient(config: InhProducerConfig): InhProducerClientItf {
        const input = config as AwsSnsProducerConfig

        const sns = new AWS.SNSClient({
            region: input.region ?? 'ap-southeast-1',
            endpoint: input.endpoint ?? 'http://localhost:4566',
            credentials: {
                accessKeyId: input.credentials.accessKeyId ?? 'dummy',
                secretAccessKey: input.credentials.secretAccessKey ?? 'dummy',
            }
        });

        const client: InhProducerClientItf = {
            makePublishCommand: createMakePublishCommand(sns,this.logger),
            makeHealthCheckCommand: createMakeHealthCheckCommand(sns,this.logger)
        }
        return client
    }

}


export const createMakePublishCommand = (sns: AWS.SNSClient,logger:InhLogger) => {
    logger.info("createMakePublishCommand")
    const fn: MakeInhPublishCommandFn = (target: string): InhPublishCommandItf => {
        const res=createPublishCommand(sns,target,logger)
        return res
    }
    return fn
}

export const createPublishCommand = (sns: AWS.SNSClient, target: string, logger: InhLogger): InhPublishCommandItf => {
    logger.info("createPublishCommand")
    const fn: InhPublishCommandItf = {
        execute: async function <O, F>(data: InhMessageFormat, messageGroupId?: string): Promise<Result<O, F>> {

            if (messageGroupId === undefined) {
                return publishStandard(sns, target, logger, data)
            } else {
                return publishFiFo(sns, target, logger, data, messageGroupId)
            }
        }
    }
  
    return fn

}

export const publishStandard = async <O,F>(sns: AWS.SNSClient, target: string, logger: InhLogger,data: InhMessageFormat):Promise<Result<O,F>> =>{
    const topicArn = target
    const param: AWS.PublishInput = {
        Message: JSON.stringify(data),
        TopicArn: topicArn,
    };
    logger.info(`publishing message to ${topicArn}. . .`)
    await sns.send(new AWS.PublishCommand(param)).catch((err: Error) => {
        logger.error(`publisher error: ${err}`)
        return Result.fail(err.message)
        // throw new Error('publisher error') 
    });
    
    logger.info(`publishMessage: ${param}`)
    return Result.ok()
}
export const publishFiFo = async <O,F>(sns: AWS.SNSClient, target: string, logger: InhLogger, data: InhMessageFormat, messageGroupId: string):Promise<Result<O,F>> =>{
    const uniqueId = new UniqueEntityID().toString();
    const param: AWS.PublishInput = {
        Message: JSON.stringify(data),
        TopicArn: target,
        MessageGroupId: messageGroupId,
        MessageDeduplicationId: uniqueId,
    };
    logger.info(`publishing message to ${target}. . .`)
    logger.info(`sns params: ${param}`)
    const publishMessageFIFOV3 = await sns.send(new AWS.PublishCommand(param)).catch((err: Error) => {
        logger.error(`publisher error: ${err}`)
        return Result.fail(err.message)
        // throw new Error('publisher error') 
    });;
    logger.info('after publishing message. . .')
    logger.info(`publishMessageFIFOV3 success result: ${publishMessageFIFOV3} `)
    return Result.ok()
}


export const createMakeHealthCheckCommand = (sns: AWS.SNSClient,logger:InhLogger) => {
    const fn: MakeInhHealthCheckCommandFn = (target: string): InhHealthCheckCommandItf => {
        const res=createHelthCheckCommand(sns,target,logger)
        return res
    }
    return fn
}

export const createHelthCheckCommand = (sns: AWS.SNSClient, target: string, logger: InhLogger): InhHealthCheckCommandItf => {
    const fn: InhHealthCheckCommandItf = {
        execute: async function <I, O>(): Promise<Result<I, O>> {
            //healthcheck
            try {
                const command = new AWS.GetTopicAttributesCommand({ TopicArn: target });
                await sns.send(command).then().catch((err) => {
                    //  throw new Error(`connect sns fail: ${err}`) }
                    logger.error(`connect sns fail: ${err}`)
                    return Result.fail(err)
                }
                )
                logger.info('Connection to AWS SNS successful.');
            } catch (error) {
                logger.error(`Error testing connection to AWS SNS: ${error}`);
                return Result.fail(error)
            }
            return Result.ok()
        }
    }
    return fn
}



