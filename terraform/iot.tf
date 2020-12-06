resource "aws_iot_thing" "lebkuchenhaus1" {
  name = "lebkuchenhaus1"
}

resource "aws_iot_policy" "lebkuchenhaus" {
  name = "lebkuchenhaus"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "iot:Publish",
        "iot:Receive"
      ],
      "Resource": [
        "arn:aws:iot:${var.region}:${data.aws_caller_identity.current.account_id}:topic/$aws/things/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "iot:Subscribe"
      ],
      "Resource": [
        "arn:aws:iot:${var.region}:${data.aws_caller_identity.current.account_id}:topicfilter/$aws/things/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "iot:Connect"
      ],
      "Resource": [
        "arn:aws:iot:${var.region}:${data.aws_caller_identity.current.account_id}:client/*"
      ]
    }
  ]
}
EOF
}