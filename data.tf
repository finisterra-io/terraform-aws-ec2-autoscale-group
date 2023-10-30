data "aws_subnet" "default" {
  count = module.this.enabled && var.subnet_names != null ? length(var.subnet_names) : 0
  filter {
    name   = "tag:Name"
    values = [var.subnet_names[count.index]]
  }
}
