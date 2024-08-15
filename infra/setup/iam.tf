# Create IAM user and policies for Continuous Deployment (CD) account #
# cd: local identifier within terraform config
# name is AWS resource name
# aws_iam_user: resource type
# cd: resource name, local name within terraform config file
# name: actual AWS resource name

resource "aws_iam_user" "cd" {
  name = "recipe-app-api-cd"
}

#resouce type.resource name.name
resource "aws_iam_access_key" "cd" {
  user = aws_iam_user.cd.name
}

# Policy for Teraform backend to S3 and DynamoDB access #
# data source block, used to retrieve information or create something that does not need to be managed as a resource.
# tf_backend is local name referring to IAM policy document
# define policy
data "aws_iam_policy_document" "tf_backend" {
  statement {
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::${var.tf_state_bucket}"] # because S3 bucket is unique by nature. :: refer to region and accountID
  }

  statement {
    effect  = "Allow"
    actions = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = [
      "arn:aws:s3:::${var.tf_state_bucket}/tf-state-deploy/*",
      "arn:aws:s3:::${var.tf_state_bucket}/tf-state-deploy-env/*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem"
    ]
    # *:* wildcard for region and account ID
    resources = ["arn:aws:dynamodb:*:*:table/${var.tf_state_lock_table}"]
  }
}
# create policy from the data block with json form
resource "aws_iam_policy" "tf_backend" {
  name        = "${aws_iam_user.cd.name}-tf-s3-dynamodb"
  description = "Allow user to use S3 and DynamoDB for TF backend resources"
  policy      = data.aws_iam_policy_document.tf_backend.json
}

# attach policy resource to IAM user
resource "aws_iam_user_policy_attachment" "tf_backend" {
  user       = aws_iam_user.cd.name
  policy_arn = aws_iam_policy.tf_backend.arn
}

#draft policy document by data block => turn that policy into resource block => attach policy resource to the user

   