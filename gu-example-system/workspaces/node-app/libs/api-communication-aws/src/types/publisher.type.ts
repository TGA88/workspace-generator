import { Result } from "@inh-lib/common";

export type AxPublishMessageFn = <R>( message: AxPublishMessageFormat)=> Promise<R>;
export type AxMakeHealthCheckCommandFn =  (target:string) => AxPublishHealthCheckCommandItf;
export interface AxPublishHealthCheckCommandItf {
    execute: <I,O>() => Promise<Result<I,O>>;
}


export type AxPublishMessageFormat= {
    eventId: string
    topicName: string
    originId: string
    publishBy: string
    systemName: string
    totalChunk: number
    chunk: number
    data: unknown,
    actions: string
}


export type AxSnsPublisherConfig = {
    region: string
    endpoint: string
    credentials: {
        accessKeyId: string
        secretAccessKey: string
    }
}
export type AxGenericPublisherConfig = {
    region: string
    endpoint: string
    topic:string
}


export type AxPublisherConfig = AxSnsPublisherConfig | AxGenericPublisherConfig;

export interface AxPublisherClientItf  {
    makePublishCommand: (target:string) => AxPublishMessageFn;
    makeHealthCheckCommand:AxMakeHealthCheckCommandFn;
}

export interface AxPublisherProviderItf{
    makePublisherClient(config:AxPublisherConfig): AxPublisherClientItf
}

// export interface AxPublisherItf {
//     // publishMessage: (topic: string , message: AxPublishMessageFormat) => Promise<Result<string>>
//     publishMessage: AxPublishMessageFn
//     healthCheck: AxPublisHealthCheckFn
// }


export interface AxSendMessageItf {
    sendMessage: (queueUrl: string, message: AxPublishMessageFormat) => Promise<void>
}
// export interface AxSenderMessageItf {
//     sendMessage: (queueUrl: string, message: AxPublishMessageFormat) => Promise<void>
// }