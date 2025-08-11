variable "role_name" { type = string }
variable "assume_role_policy_json" { type = string }

variable "attached_policy_arns" {
  type    = list(string)
  default = []
}

variable "inline_policies" {
  type    = map(string)
  default = {}
}

resource "aws_iam_role" "this" {
  name               = var.role_name
  assume_role_policy = var.assume_role_policy_json
}

resource "aws_iam_role_policy_attachment" "attached" {
  for_each   = toset(var.attached_policy_arns)
  role       = aws_iam_role.this.name
  policy_arn = each.value
}

resource "aws_iam_role_policy" "inline" {
  for_each = var.inline_policies
  name     = each.key
  role     = aws_iam_role.this.id
  policy   = each.value
}

output "arn" { value = aws_iam_role.this.arn }
output "name" { value = aws_iam_role.this.name } 