resource "aws_launch_template" "default" {
  count = module.this.enabled && var.create_aws_launch_template ? 1 : 0

  name = var.launch_template_name

  dynamic "block_device_mappings" {
    for_each = var.block_device_mappings
    content {
      device_name  = lookup(block_device_mappings.value, "device_name", null)
      no_device    = lookup(block_device_mappings.value, "no_device", null)
      virtual_name = lookup(block_device_mappings.value, "virtual_name", null)

      dynamic "ebs" {
        for_each = lookup(block_device_mappings.value, "ebs", null) == null ? [] : ["ebs"]
        content {
          delete_on_termination = lookup(block_device_mappings.value.ebs, "delete_on_termination", null)
          encrypted             = lookup(block_device_mappings.value.ebs, "encrypted", null)
          iops                  = lookup(block_device_mappings.value.ebs, "iops", null)
          throughput            = lookup(block_device_mappings.value.ebs, "throughput", null)
          kms_key_id            = lookup(block_device_mappings.value.ebs, "kms_key_id", null)
          snapshot_id           = lookup(block_device_mappings.value.ebs, "snapshot_id", null)
          volume_size           = lookup(block_device_mappings.value.ebs, "volume_size", null)
          volume_type           = lookup(block_device_mappings.value.ebs, "volume_type", null)
        }
      }
    }
  }

  dynamic "credit_specification" {
    for_each = var.credit_specification != null ? [var.credit_specification] : []
    content {
      cpu_credits = lookup(credit_specification.value, "cpu_credits", null)
    }
  }

  disable_api_termination = var.disable_api_termination
  ebs_optimized           = var.ebs_optimized
  update_default_version  = var.update_default_version

  dynamic "elastic_gpu_specifications" {
    for_each = var.elastic_gpu_specifications != null ? [var.elastic_gpu_specifications] : []
    content {
      type = lookup(elastic_gpu_specifications.value, "type", null)
    }
  }

  image_id                             = var.image_id
  instance_initiated_shutdown_behavior = var.instance_initiated_shutdown_behavior

  dynamic "instance_market_options" {
    for_each = var.instance_market_options != null ? [var.instance_market_options] : []
    content {
      market_type = lookup(instance_market_options.value, "market_type", null)

      dynamic "spot_options" {
        for_each = (instance_market_options.value.spot_options != null ?
        [instance_market_options.value.spot_options] : [])
        content {
          block_duration_minutes         = lookup(spot_options.value, "block_duration_minutes", null)
          instance_interruption_behavior = lookup(spot_options.value, "instance_interruption_behavior", null)
          max_price                      = lookup(spot_options.value, "max_price", null)
          spot_instance_type             = lookup(spot_options.value, "spot_instance_type", null)
          valid_until                    = lookup(spot_options.value, "valid_until", null)
        }
      }
    }
  }

  instance_type = var.instance_type
  key_name      = var.key_name

  dynamic "placement" {
    for_each = var.placement != null ? [var.placement] : []
    content {
      affinity          = lookup(placement.value, "affinity", null)
      availability_zone = lookup(placement.value, "availability_zone", null)
      group_name        = lookup(placement.value, "group_name", null)
      host_id           = lookup(placement.value, "host_id", null)
      tenancy           = lookup(placement.value, "tenancy", null)
    }
  }

  user_data = var.user_data_base64

  dynamic "iam_instance_profile" {
    for_each = var.iam_instance_profile_name != "" ? [var.iam_instance_profile_name] : []
    content {
      name = iam_instance_profile.value
    }
  }

  monitoring {
    enabled = var.enable_monitoring
  }


  dynamic "network_interfaces" {
    for_each = [var.network_interfaces]
    content {
      description                 = module.this.id
      device_index                = 0
      associate_public_ip_address = var.associate_public_ip_address
      delete_on_termination       = true
      security_groups             = var.security_group_ids
    }
  }

  dynamic "metadata_options" {
    for_each = [var.metadata_options]
    content {
      http_endpoint               = lookup(metadata_options.value, "http_endpoint", null)
      http_put_response_hop_limit = lookup(metadata_options.value, "http_put_response_hop_limit", null)
      http_tokens                 = lookup(metadata_options.value, "http_tokens", null)
      http_protocol_ipv6          = lookup(metadata_options.value, "http_protocol_ipv6", null)
      instance_metadata_tags      = lookup(metadata_options.value, "instance_metadata_tags", null)
    }
  }

  dynamic "tag_specifications" {
    for_each = var.tag_specifications

    content {
      resource_type = tag_specifications.value.resource_type
      tags          = tag_specifications.value.tags
    }
  }

  tags = var.aws_launch_template_tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "default" {
  count             = module.this.enabled && var.create_aws_launch_configuration ? 1 : 0
  name              = var.launch_configuration_name
  image_id          = var.image_id
  instance_type     = var.instance_type
  key_name          = var.key_name
  user_data         = var.user_data_base64
  enable_monitoring = var.enable_monitoring
  ebs_optimized     = var.ebs_optimized
  security_groups   = var.security_group_ids


  dynamic "root_block_device" {
    for_each = length(var.root_block_device) > 0 ? [var.root_block_device] : []
    content {
      volume_type           = lookup(root_block_device.value, "volume_type", null)
      volume_size           = lookup(root_block_device.value, "volume_size", null)
      delete_on_termination = lookup(root_block_device.value, "delete_on_termination", null)
    }
  }

  dynamic "ebs_block_device" {
    for_each = var.ebs_block_device
    content {
      device_name           = lookup(ebs_block_device.value, "device_name", null)
      volume_type           = lookup(ebs_block_device.value, "volume_type", null)
      volume_size           = lookup(ebs_block_device.value, "volume_size", null)
      delete_on_termination = lookup(ebs_block_device.value, "delete_on_termination", null)
    }
  }

  dynamic "ephemeral_block_device" {
    for_each = var.ephemeral_block_device
    content {
      device_name  = lookup(ephemeral_block_device.value, "device_name", null)
      virtual_name = lookup(ephemeral_block_device.value, "virtual_name", null)

    }
  }

  iam_instance_profile = var.iam_instance_profile_name

  spot_price = var.spot_price

  placement_tenancy = var.placement_tenancy


  lifecycle {
    create_before_destroy = true
  }
}

locals {
  launch_template_block = {
    id      = one(aws_launch_template.default[*].id)
    version = var.launch_template_version != "" ? var.launch_template_version : one(aws_launch_template.default[*].latest_version)
  }
  launch_template = (
    var.mixed_instances_policy == null ? local.launch_template_block
  : null)
  mixed_instances_policy = (
    var.mixed_instances_policy == null ? null : {
      instances_distribution = var.mixed_instances_policy.instances_distribution
      launch_template        = local.launch_template_block
      override               = var.mixed_instances_policy.override
  })
  tags = {
    for key, value in module.this.tags :
    key => value if value != "" && value != null
  }
}

resource "aws_autoscaling_group" "default" {
  count = module.this.enabled ? 1 : 0

  name                      = var.asg_name
  vpc_zone_identifier       = coalesce(var.subnet_ids, data.aws_subnet.default[*].id, [])
  max_size                  = var.max_size
  min_size                  = var.min_size
  load_balancers            = var.load_balancers
  health_check_grace_period = var.health_check_grace_period
  health_check_type         = var.health_check_type
  min_elb_capacity          = var.min_elb_capacity
  wait_for_elb_capacity     = var.wait_for_elb_capacity
  target_group_arns         = var.target_group_arns
  default_cooldown          = var.default_cooldown
  force_delete              = var.force_delete
  termination_policies      = var.termination_policies
  suspended_processes       = var.suspended_processes
  placement_group           = var.placement_group
  enabled_metrics           = var.enabled_metrics
  metrics_granularity       = var.metrics_granularity
  wait_for_capacity_timeout = var.wait_for_capacity_timeout
  protect_from_scale_in     = var.protect_from_scale_in
  service_linked_role_arn   = var.service_linked_role_arn
  desired_capacity          = var.desired_capacity
  max_instance_lifetime     = var.max_instance_lifetime
  capacity_rebalance        = var.capacity_rebalance

  dynamic "instance_refresh" {
    for_each = (var.instance_refresh != null ? [var.instance_refresh] : [])

    content {
      strategy = instance_refresh.value.strategy
      dynamic "preferences" {
        for_each = instance_refresh.value.preferences != null ? [instance_refresh.value.preferences] : []
        content {
          instance_warmup              = lookup(preferences.value, "instance_warmup", null)
          min_healthy_percentage       = lookup(preferences.value, "min_healthy_percentage", null)
          skip_matching                = lookup(preferences.value, "skip_matching", null)
          auto_rollback                = lookup(preferences.value, "auto_rollback", null)
          scale_in_protected_instances = lookup(preferences.value, "scale_in_protected_instances", null)
          standby_instances            = lookup(preferences.value, "standby_instances", null)
        }
      }
      triggers = instance_refresh.value.triggers
    }
  }

  launch_configuration = var.launch_configuration_name

  # dynamic "launch_template" {
  #   for_each = (local.launch_template != null ?
  #   [local.launch_template] : [])
  #   content {
  #     id      = local.launch_template_block.id
  #     version = local.launch_template_block.version
  #   }
  # }

  # dynamic "mixed_instances_policy" {
  #   for_each = (local.mixed_instances_policy != null ?
  #   [local.mixed_instances_policy] : [])
  #   content {
  #     dynamic "instances_distribution" {
  #       for_each = (
  #         mixed_instances_policy.value.instances_distribution != null ?
  #       [mixed_instances_policy.value.instances_distribution] : [])
  #       content {
  #         on_demand_allocation_strategy = lookup(
  #         instances_distribution.value, "on_demand_allocation_strategy", null)
  #         on_demand_base_capacity = lookup(
  #         instances_distribution.value, "on_demand_base_capacity", null)
  #         on_demand_percentage_above_base_capacity = lookup(
  #         instances_distribution.value, "on_demand_percentage_above_base_capacity", null)
  #         spot_allocation_strategy = lookup(
  #         instances_distribution.value, "spot_allocation_strategy", null)
  #         spot_instance_pools = lookup(
  #         instances_distribution.value, "spot_instance_pools", null)
  #         spot_max_price = lookup(
  #         instances_distribution.value, "spot_max_price", null)
  #       }
  #     }
  #     launch_template {
  #       launch_template_specification {
  #         launch_template_id = mixed_instances_policy.value.launch_template.id
  #         version            = mixed_instances_policy.value.launch_template.version
  #       }
  #       dynamic "override" {
  #         for_each = (mixed_instances_policy.value.override != null ?
  #         mixed_instances_policy.value.override : [])
  #         content {
  #           instance_type     = lookup(override.value, "instance_type", null)
  #           weighted_capacity = lookup(override.value, "weighted_capacity", null)
  #         }
  #       }
  #     }
  #   }
  # }

  dynamic "warm_pool" {
    for_each = var.warm_pool != null ? [var.warm_pool] : []
    content {
      pool_state                  = try(warm_pool.value.pool_state, null)
      min_size                    = try(warm_pool.value.min_size, null)
      max_group_prepared_capacity = try(warm_pool.value.max_group_prepared_capacity, null)
      dynamic "instance_reuse_policy" {
        for_each = var.instance_reuse_policy != null ? [var.instance_reuse_policy] : []
        content {
          reuse_on_scale_in = instance_reuse_policy.value.reuse_on_scale_in
        }
      }
    }
  }

  dynamic "tag" {
    for_each = var.autoscaling_group_tags != null ? var.autoscaling_group_tags : []
    content {
      key                 = tag.value.key
      value               = tag.value.value
      propagate_at_launch = tag.value.propagate_at_launch
    }
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [desired_capacity]
  }
}
