data "aws_ssm_parameter" "app_params" {
  for_each        = var.ssm_parameters
  name            = each.value
  with_decryption = true
}



