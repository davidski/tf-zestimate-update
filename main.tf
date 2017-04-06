provider "aws" {
  region  = "${var.aws_region}"
  profile = "${var.aws_profile}"

  assume_role {
    role_arn = "arn:aws:iam::754135023419:role/administrator-service"
  }
}

# Data source for the availability zones in this zone
data "aws_availability_zones" "available" {}

# Data source for current account number
data "aws_caller_identity" "current" {}

/*
  --------------
  | S3 Bucket |
  --------------
*/

# S3 location for zestimate data files
resource "aws_s3_bucket" "zestimate" {
  bucket = "zestimate-severski"

  tags {
    Name       = "Zestimate data files"
    project    = "zestimate"
    managed_by = "Terraform"
  }
}

/*
  -------------
  | SNS Topic |
  -------------
*/

resource "aws_sns_topic" "zestimate_updates" {
  name = "zestimate-updates-topic"
}

/*
  -------------
  | IAM Roles |
  -------------
*/

resource "aws_iam_role" "lambda_worker" {
  name_prefix = "zestimate-update"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      }
    }
  ]
}
EOF
}

data "aws_iam_policy_document" "policy" {
  statement {
    sid = "1"

    actions = [
      "sns:Publish",
    ]

    resources = ["${aws_sns_topic.zestimate_updates.arn}"]
  }

  statement {
    sid = "2"

    actions = [
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:PutObject"
    ]

    resources = ["arn:aws:s3:::*"]
  }
}

resource "aws_iam_policy" "policy" {
  name   = "lambda_zestimate_update"
  path   = "/"
  policy = "${data.aws_iam_policy_document.policy.json}"
}

resource "aws_iam_role_policy_attachment" "lambda_worker" {
  role       = "${aws_iam_role.lambda_worker.id}"
  policy_arn = "${aws_iam_policy.policy.arn}"
}

resource "aws_iam_role_policy_attachment" "lambda_worker_logs" {
  role       = "${aws_iam_role.lambda_worker.id}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

output "lambda_role_arn" {
  value = "${aws_iam_role.lambda_worker.arn}"
}

/*
  ----------------------------
  | Schedule Lambda Function |
  ----------------------------
*/

resource "aws_cloudwatch_event_rule" "daily" {
  name                = "daily_zestimate_trigger"
  description         = "Trigger Zestimate update Lambda on a daily basis"
  schedule_expression = "rate(1 day)"
}

resource "aws_cloudwatch_event_target" "default" {
  rule      = "${aws_cloudwatch_event_rule.daily.name}"
  target_id = "TriggerZestimateUpdate"
  arn       = "${aws_lambda_function.zestimate_update.arn}"
}

resource "aws_lambda_permission" "from_cloudwatch_events" {
  statement_id  = "AllowExecutionFromCWEvents"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.zestimate_update.arn}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.daily.arn}"
}

resource "aws_lambda_function" "zestimate_update" {
  s3_bucket     = "artifacts-severski"
  s3_key        = "lambdas/update-zestimate.zip"
  function_name = "update_zestimate"
  role          = "${aws_iam_role.lambda_worker.arn}"
  handler       = "main.lambda_handler"
  description   = "Check for updated home Zestimates"
  runtime       = "python2.7"

  environment {
    variables = {
      zpid          = "${var.zpid}"
      zwsid         = "${var.zwsid}"
      bucket_name   = "${aws_s3_bucket.zestimate.id}"
      bucket_key    = "${var.bucket_key}"
      sns_topic_arn = "${aws_sns_topic.zestimate_updates.arn}"
    }
  }
}
