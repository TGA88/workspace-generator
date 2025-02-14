#!/usr/bin/env bash

set -euo pipefail

# enable debug
# set -x

echo "configuring sqs"
echo "==================="
LOCALSTACK_HOST=localhost
AWS_REGION=ap-southeast-1
KEY=dummy
PROFILE=default
SNS_TRN_PRESCRIPTION_CHANGED=SNS_TrnPrescriptionChanged
SQS_GUPSCREPORT_PSC_TRN_CHANGED=SQS_fosminereport_mine_TrnPrescriptionChanged
SQS_FEEDERP_PSC_TRN_CHANGED=SQS_feederp-mine_TrnPrescriptionChanged
SNS_TRN_PRESCRIPTION_ORDER_CHANGED=SNS_TrnPrescriptionOrderChanged
SQS_GUPSCREPORT_PSC_ORDER_TRN_CHANGED=SQS_fosminereport_mine_TrnPrescriptionOrderChanged
SNS_FEEDERP_SYNCMASTERDATA_CHANGED=SNS_feederp_syncmasterdata_changed
SQS_GUPSC_SYNCMASTERDATA_CHANGE=SQS_fosmine_syncmasterdata_changed

aws --version
aws --profile $PROFILE configure set aws_access_key_id $KEY
aws --profile $PROFILE configure set aws_secret_access_key $KEY
aws configure set region $AWS_REGION --profile $PROFILE
aws configure set output table --profile $PROFILE

#create SNS and SQS
aws --endpoint-url=http://localhost:4566 sns create-topic --name $SNS_TRN_PRESCRIPTION_CHANGED --region $AWS_REGION --profile $PROFILE --output table | cat
aws --endpoint-url=http://localhost:4566 sqs create-queue --queue-name $SQS_GUPSCREPORT_PSC_TRN_CHANGED --profile $PROFILE --region $AWS_REGION --output table | cat
aws --endpoint-url=http://localhost:4566 sqs create-queue --queue-name $SQS_FEEDERP_PSC_TRN_CHANGED --profile $PROFILE --region $AWS_REGION --output table | cat

aws --endpoint-url=http://localhost:4566 sns create-topic --name $SNS_TRN_PRESCRIPTION_ORDER_CHANGED --region $AWS_REGION --profile $PROFILE --output table | cat
aws --endpoint-url=http://localhost:4566 sqs create-queue --queue-name $SQS_GUPSCREPORT_PSC_ORDER_TRN_CHANGED --profile $PROFILE --region $AWS_REGION --output table | cat

aws --endpoint-url=http://localhost:4566 sns create-topic --name $SNS_FEEDERP_SYNCMASTERDATA_CHANGED --region $AWS_REGION --profile $PROFILE --output table | cat
aws --endpoint-url=http://localhost:4566 sqs create-queue --queue-name $SQS_GUPSC_SYNCMASTERDATA_CHANGE --profile $PROFILE --region $AWS_REGION --output table | cat

# subscibe
aws --endpoint-url=http://localhost:4566 sns subscribe --topic-arn arn:aws:sns:$AWS_REGION:000000000000:$SNS_TRN_PRESCRIPTION_CHANGED --profile $PROFILE --protocol sqs --notification-endpoint arn:aws:sqs:$AWS_REGION:000000000000:$SQS_GUPSCREPORT_PSC_TRN_CHANGED --region $AWS_REGION
aws --endpoint-url=http://localhost:4566 sns subscribe --topic-arn arn:aws:sns:$AWS_REGION:000000000000:$SNS_TRN_PRESCRIPTION_CHANGED --profile $PROFILE --protocol sqs --notification-endpoint arn:aws:sqs:$AWS_REGION:000000000000:$SQS_FEEDERP_PSC_TRN_CHANGED --region $AWS_REGION

aws --endpoint-url=http://localhost:4566 sns subscribe --topic-arn arn:aws:sns:$AWS_REGION:000000000000:$SNS_TRN_PRESCRIPTION_ORDER_CHANGED --profile $PROFILE --protocol sqs --notification-endpoint arn:aws:sqs:$AWS_REGION:000000000000:$SQS_GUPSCREPORT_PSC_ORDER_TRN_CHANGED --region $AWS_REGION

aws --endpoint-url=http://localhost:4566 sns subscribe --topic-arn arn:aws:sns:$AWS_REGION:000000000000:$SNS_FEEDERP_SYNCMASTERDATA_CHANGED --profile $PROFILE --protocol sqs --notification-endpoint arn:aws:sqs:$AWS_REGION:000000000000:$SQS_GUPSC_SYNCMASTERDATA_CHANGE --region $AWS_REGION