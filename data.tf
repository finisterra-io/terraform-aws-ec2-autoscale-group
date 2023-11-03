data "aws_subnet" "default" {
  count = module.this.enabled && var.subnet_names != null ? length(var.subnet_names) : 0
  filter {
    name   = "tag:Name"
    values = [var.subnet_names[count.index]]
  }
}


data "aws_security_group" "selected" {
  count = length(var.security_group_names)
  name  = var.security_group_names[count.index]
}
