resource "random_string" "bucketname" {
  length = 6
  special = false
  upper = false
}

resource "aws_s3_bucket" "frontend" {

  bucket = "iot-center-${random_string.bucketname.result}"

  versioning {
    enabled = false
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  website {
    index_document = "index.html"
    error_document = "index.html"
  }

  tags = {
    Name = "S3 Bucket for the IoT Center Frontend"
  }

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Id": "PublicAccess",
    "Statement": [
        {
            "Sid": "1",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::iot-center-${random_string.bucketname.result}/*"
        }
    ]
}
POLICY

  force_destroy = true

}

resource "null_resource" "upload_website_to_s3" {
  provisioner "local-exec" {
    command = "aws s3 cp ../frontend s3://${aws_s3_bucket.frontend.id} --recursive"
  }
}

output "frontend-s3-website" {
  value = "http://${aws_s3_bucket.frontend.website_endpoint}/"
}