resource "aws_lambda_function" "getShadow" {
  filename      = "../lambda/getShadow.zip"
  function_name = "getShadow"
  role          = aws_iam_role.LambdaAWSIoTDataAccess.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"
  source_code_hash = filebase64sha256("../lambda/getShadow.zip")
}
resource "aws_lambda_permission" "getShadow" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.getShadow.id
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.lebkuchenhaus.execution_arn}/*/*/"
}

resource "aws_lambda_function" "updateShadow" {
  filename      = "../lambda/updateShadow.zip"
  function_name = "updateShadow"
  role          = aws_iam_role.LambdaAWSIoTDataAccess.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"
  source_code_hash = filebase64sha256("../lambda/updateShadow.zip")
}

resource "aws_lambda_permission" "updateShadow" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.updateShadow.id
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.lebkuchenhaus.execution_arn}/*/*/"
}