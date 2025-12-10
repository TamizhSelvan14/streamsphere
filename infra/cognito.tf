resource "aws_cognito_user_pool" "this" {
  name                     = "${var.project}-users"
  auto_verified_attributes = ["email"]
}

resource "aws_cognito_user_pool_client" "this" {
  name                                 = "${var.project}-client"
  user_pool_id                         = aws_cognito_user_pool.this.id
  generate_secret                      = false
  callback_urls                        = ["http://localhost:5173/"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_scopes                 = ["email", "openid", "profile"]
  supported_identity_providers         = ["COGNITO"]
}

output "cognito_user_pool_id" { value = aws_cognito_user_pool.this.id }
output "cognito_user_pool_client_id" { value = aws_cognito_user_pool_client.this.id }
