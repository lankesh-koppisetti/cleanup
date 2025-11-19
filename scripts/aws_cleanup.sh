#!/bin/bash
set -e

echo "Starting AWS cleanup at $(date)"

############################################
# DELETE EC2 INSTANCES WITH TAG AutoDelete=true
############################################
echo "Checking EC2 instances..."

INSTANCE_IDS=$(aws ec2 describe-instances \
  --filters "Name=tag:AutoDelete,Values=true" \
  --query "Reservations[*].Instances[*].InstanceId" \
  --output text)

if [ -n "$INSTANCE_IDS" ]; then
  echo "Terminating EC2 instances: $INSTANCE_IDS"
  aws ec2 terminate-instances --instance-ids $INSTANCE_IDS
else
  echo "No EC2 instances found"
fi

############################################
# DELETE S3 BUCKETS WITH AutoDelete=true TAG
############################################
echo "Checking S3 buckets..."
BUCKETS=$(aws s3api list-buckets --query 'Buckets[].Name' --output text)

for bucket in $BUCKETS; do
  TAGGED=$(aws s3api get-bucket-tagging --bucket "$bucket" 2>/dev/null | grep -c '"AutoDelete": "true"' || true)
  if [[ "$TAGGED" -gt 0 ]]; then
    echo "Deleting S3 bucket: $bucket"
    aws s3 rm s3://$bucket --recursive || true
    aws s3api delete-bucket --bucket $bucket || true
  fi
done

############################################
# DELETE LAMBDA FUNCTIONS WITH AutoDelete=true TAG
############################################
echo "Checking Lambda functions..."
FUNCTIONS=$(aws lambda list-functions --query "Functions[].FunctionName" --output text)

for fn in $FUNCTIONS; do
  TAG=$(aws lambda list-tags --resource arn:aws:lambda:$AWS_DEFAULT_REGION:<ACCOUNT_ID>:function:$fn \
        --query "Tags.AutoDelete" --output text 2>/dev/null)

  if [ "$TAG" == "true" ]; then
    echo "Deleting Lambda function: $fn"
    aws lambda delete-function --function-name "$fn"
  fi
done

echo "AWS Cleanup completed!"
