import { InhLogger } from "@inh-lib/common";
import { AxConsumerItf, AxSendMessageItf, AxPublishMessageFormat } from "../types";
import * as AWS from '@aws-sdk/client-sqs';
import * as util from 'util';

export interface IMessageFormat {
    eventId: string;
    topicName: string;
    originId: string;
    publishBy: string;
    systemName: string;
    totalChunk: number;
    chunk: number;
    data: object;
    actions: string;
}

export interface SQSClientCredential {
    endpoint: string,
    region: string,
    credentials: {
        accessKeyId: string,
        secretAccessKey: string,
    }
}

// interface SNSMessageFormat {
//     Messages: {
//         Body: string
//         MD5OfBody: string
//         MessageId: string
//         ReceiptHandle: string
//     }[]
// }

export function makeSQSAxSendMessageItf(clientCredential: SQSClientCredential,): AxSendMessageItf {
    const sqs = new AWS.SQS({
        region: clientCredential.region,
        endpoint: clientCredential.endpoint ?? 'http://localhost:4566',
        //use dummy to prevent local not install aws cli and not setting any credential
        credentials: {
            accessKeyId: clientCredential.credentials.accessKeyId ?? 'dummy',
            secretAccessKey: clientCredential.credentials.secretAccessKey ?? 'dummy',
        }
    });
    const send = sendMessage.bind({ sqs })
    const publish: AxSendMessageItf = { sendMessage: send }
    return publish

    async function sendMessage(
        queueUrl: string,
        message: AxPublishMessageFormat
    ) {
        const param: AWS.SendMessageRequest = {
            MessageBody: JSON.stringify(message),
            QueueUrl: queueUrl,
        };
        const publishMessagePromise = await this.sqs.sendMessage(param).promise();
        await publishMessagePromise
            .then((data) => {
                console.log(
                    `Message ID is ${data.MessageId}, Message ${param.MessageBody} send to topic ${param.QueueUrl}`
                );
            })
            .catch((error) => {
                console.log('sending error', error)
                throw new Error(error)
            });
    };
}

/**
 * create instance of SQS consumer from SNS with fastify logger
 * @param clientCredential 
 * @param config 
 * @param handler 
 * @param inhLogger 
 * @returns 
 */
export const makeSQSConsumerFromSNSFastify = (
    clientCredential: SQSClientCredential,
    config: AWS.ReceiveMessageRequest,
    handler: (data: unknown, logger: InhLogger) => Promise<void>,
    inhLogger: InhLogger,
): AxConsumerItf => {
    const sqs = new AWS.SQS({
        region: clientCredential.region,
        endpoint: clientCredential.endpoint ?? 'http://localhost:4566',
        //use dummy to prevent local not install aws cli and not setting any credential
        credentials: {
            accessKeyId: clientCredential.credentials.accessKeyId ?? 'dummy',
            secretAccessKey: clientCredential.credentials.secretAccessKey ?? 'dummy',
        }
    });
    const recieveMessage = async () => {
        try {
            sqs.receiveMessage(config, receiveMessageCallback)
        } catch (error) {
            inhLogger.error({ error: `error in receive message ${error}` })
        }
    }
    const consume: AxConsumerItf = { recieveMessage: recieveMessage }
    return consume

    async function receiveMessageCallback(err, data) {
        if (data?.Messages?.length > 0) {
            inhLogger.info(`--Message Recieve--`)
            for (const i of data.Messages) {
                // console.log('message number',JSON.parse(JSON.parse(i.Body).Message))
                let parseMessage
                try {
                    parseMessage = JSON.parse(JSON.parse(i.Body).Message)
                    inhLogger.info(`MessageId:${i.MessageId}`)
                    inhLogger.info(`"Message Body":${util.inspect(parseMessage)}`)

                    await handler(parseMessage, inhLogger);
                } catch (err) {
                    inhLogger.error({ error: `Error handling message: ${err}` });
                    continue; // skip to the next message
                }

                try {
                    const deleteMessageParams = {
                        QueueUrl: config.QueueUrl,
                        ReceiptHandle: i.ReceiptHandle
                    };
                    sqs.deleteMessage(deleteMessageParams, deleteMessageCallback);
                    inhLogger.info(`Message with id ${i.MessageId} deleted successfully.`);
                } catch (err) {
                    inhLogger.error({ error: `Error deleting message with id ${i.MessageId}: ${err}` });
                }
            }
            recieveMessage();
        } else {
            process.stdout.write(".");
            // throw new Error("No Message")
        }
        setTimeout(recieveMessage, parseInt(process.env.SQS_RECIEVE_DELAY ?? "10000"));
    }
    function deleteMessageCallback() {
        inhLogger.info("deleted message");
    }
}

/**
 * create instance of SQS consumer from SQS with fastify logger
 * @param clientCredential 
 * @param config 
 * @param handler 
 * @param inhLogger 
 * @returns 
 */
export const makeSQSConsumerFromSQSFasitify = (
    clientCredential: SQSClientCredential,
    config: AWS.ReceiveMessageRequest,
    handler: (data: unknown, logger: InhLogger) => Promise<void>,
    inhLogger: InhLogger,
): AxConsumerItf => {
    const sqs = new AWS.SQS({
        region: clientCredential.region,
        endpoint: clientCredential.endpoint ?? 'http://localhost:4566',
        //use dummy to prevent local not install aws cli and not setting any credential
        credentials: {
            accessKeyId: clientCredential.credentials.accessKeyId ?? 'dummy',
            secretAccessKey: clientCredential.credentials.secretAccessKey ?? 'dummy',
        }
    });
    const recieveMessage = async () => {
        sqs.receiveMessage(config, receiveMessageCallback)
    }
    const consume: AxConsumerItf = { recieveMessage: recieveMessage }
    return consume

    async function receiveMessageCallback(err, data) {
        if (data?.Messages?.length > 0) {
            for (const i of data.Messages) {
                let parseMessage
                try {
                    parseMessage = JSON.parse(i.Body)
                    console.log(parseMessage)
                    await handler(parseMessage, inhLogger);
                } catch (err) {
                    inhLogger.error(`Error handling message: ${err}`);
                    continue; // skip to the next message
                }

                const deleteMessageParams = {
                    QueueUrl: config.QueueUrl,
                    ReceiptHandle: i.ReceiptHandle
                };

                try {
                    sqs.deleteMessage(deleteMessageParams, deleteMessageCallback);
                    inhLogger.error(`Message with id ${i.MessageId} deleted successfully.`);
                } catch (err) {
                    console.error(`Error deleting message with id ${i.MessageId}: `, err);
                }
            }
            recieveMessage();
        } else {

            process.stdout.write('.');
            setTimeout(recieveMessage, parseInt(process.env.SQS_RECIEVE_DELAY ?? "10000"));
        }
    }

    function deleteMessageCallback() {
        console.log("deleted message");
    }
}
