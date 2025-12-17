#!/usr/bin/env bash
set -euo pipefail

TABLE="${1:-my-dynamodb-ta}"
REGION="${2:-us-east-1}"

echo "Checking DynamoDB table '$TABLE' in region '$REGION'..."
if aws dynamodb describe-table --table-name "$TABLE" --region "$REGION" >/dev/null 2>&1; then
  KEY_NAME=$(aws dynamodb describe-table --table-name "$TABLE" --region "$REGION" --query "Table.KeySchema[0].AttributeName" --output text)
  if [ "$KEY_NAME" != "LockID" ]; then
    echo "ERROR: DynamoDB table '$TABLE' exists but hash key is '$KEY_NAME' (expected 'LockID')."
    echo "Please recreate the table with a hash key named 'LockID' or delete it so CI can create it." >&2
    exit 1
  else
    echo "OK: DynamoDB table '$TABLE' exists and has correct key 'LockID'."
  fi
else
  echo "DynamoDB table '$TABLE' does not exist. Creating..."
  aws dynamodb create-table --table-name "$TABLE" \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --region "$REGION"
  echo "Waiting for table to become ACTIVE..."
  aws dynamodb wait table-exists --table-name "$TABLE" --region "$REGION"
  echo "Table '$TABLE' created and ready."
fi
