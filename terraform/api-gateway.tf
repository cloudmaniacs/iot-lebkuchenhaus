resource "aws_apigatewayv2_api" "lebkuchenhaus" {
  name = "IoT Lebkuchenhaus by Cloud Maniacs Frankfurt"
  protocol_type = "HTTP"
  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["*"]
    allow_headers = ["*"]
  }
}

resource "aws_apigatewayv2_integration" "getShadow" {
  api_id                    = aws_apigatewayv2_api.lebkuchenhaus.id
  integration_type          = "AWS_PROXY"
  description               = "getShadow"
  integration_method        = "POST"
  integration_uri           = aws_lambda_function.getShadow.invoke_arn
  passthrough_behavior      = "WHEN_NO_MATCH"
  payload_format_version    = "2.0"
}

resource "aws_apigatewayv2_integration" "updateShadow" {
  api_id                    = aws_apigatewayv2_api.lebkuchenhaus.id
  integration_type          = "AWS_PROXY"
  description               = "updateShadow"
  integration_method        = "POST"
  integration_uri           = aws_lambda_function.updateShadow.invoke_arn
  passthrough_behavior      = "WHEN_NO_MATCH"
  payload_format_version    = "2.0"
}

resource "aws_apigatewayv2_route" "getShadow" {
  api_id    = aws_apigatewayv2_api.lebkuchenhaus.id
  route_key = "GET /"
  target    = "integrations/${aws_apigatewayv2_integration.getShadow.id}"
}

resource "aws_apigatewayv2_route" "updateShadow" {
  api_id    = aws_apigatewayv2_api.lebkuchenhaus.id
  route_key = "POST /"
  target    = "integrations/${aws_apigatewayv2_integration.updateShadow.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id = aws_apigatewayv2_api.lebkuchenhaus.id
  name   = "$default"
  auto_deploy = true
}

output "backend-api-gateway" {
  value = aws_apigatewayv2_stage.default.invoke_url
}