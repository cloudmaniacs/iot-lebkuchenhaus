resource "aws_iam_role" "LambdaAWSIoTDataAccess" {
  name = "LambdaAWSIoTDataAccess"
  path = "/service-role/"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "AWSLambdaBasicExecutionRole" {
  role       = aws_iam_role.LambdaAWSIoTDataAccess.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "AWSIoTDataAccess" {
  role       = aws_iam_role.LambdaAWSIoTDataAccess.name
  policy_arn = "arn:aws:iam::aws:policy/AWSIoTDataAccess"
}