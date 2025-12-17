# Manage DynamoDB table for Terraform state locking

resource "aws_dynamodb_table" "terraform_lock" {
  name         = "my-dynamodb-ta"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name = "Terraform state lock"
  }
}
