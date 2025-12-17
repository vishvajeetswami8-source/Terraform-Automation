Terraform backend lock table (DynamoDB)

Problem
-------
Terraform requires a DynamoDB table with a hash key named `LockID` (exact case) when `dynamodb_table` is used for remote state locks. If the table uses a different key name (for example `LockId`, `id`), Terraform will fail to acquire the lock with ValidationException errors.

Options to create the table
---------------------------
1) Create via AWS CLI (quick, manual):

```bash
aws dynamodb create-table \
  --table-name my-dynamodb-ta \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1
```

2) Create via Terraform (recommended to manage it in code):

- Initialize without the backend so Terraform won't try to use the lock table before it's created:

```bash
terraform init -backend=false
```

- Create only the DynamoDB table resource:

```bash
terraform apply -target=aws_dynamodb_table.terraform_lock -auto-approve
```

- Reinitialize the backend to pick up your S3/DynamoDB remote state:

```bash
terraform init -reconfigure
```

Permissions
-----------
Ensure the credentials used by Jenkins/CI have DynamoDB actions (GetItem, PutItem, DeleteItem, UpdateItem) and S3 permissions for the state bucket.

Notes
-----
- The DynamoDB resource is defined in `dynamodb.tf` and uses `LockID` as the hash key.
- You can protect the table from accidental deletion using the `prevent_destroy` lifecycle rule included in `dynamodb.tf`.

Pipeline check
--------------
This repository includes `scripts/ensure-dynamodb.sh` which runs in CI to ensure the DynamoDB table exists and has the correct `LockID` hash key. The Jenkins pipeline runs this before `terraform init`; it will create the table if missing or fail the build when the table exists but has the wrong key (to avoid destructive automatic deletes). Use:

```bash
./scripts/ensure-dynamodb.sh my-dynamodb-ta us-east-1
```

