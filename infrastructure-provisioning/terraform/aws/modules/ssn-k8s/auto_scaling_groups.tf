data "template_file" "ssn_k8s_masters_user_data" {
  template = file("../modules/ssn-k8s/files/masters-user-data.sh")
  vars = {
    k8s-asg = "${var.service_base_name}-master"
    k8s-region = var.region
    k8s-bucket-name = aws_s3_bucket.ssn_k8s_bucket.id
    k8s-eip = aws_eip.k8s-lb-eip.public_ip
    k8s-tg-arn = aws_lb_target_group.ssn_k8s_lb_target_group.arn
    k8s-os-user = var.os-user
  }
}

data "template_file" "ssn_k8s_workers_user_data" {
  template = file("../modules/ssn-k8s/files/workers-user-data.sh")
  vars = {
    k8s-bucket-name = aws_s3_bucket.ssn_k8s_bucket.id
    k8s-os-user = var.os-user
  }
}

resource "aws_launch_configuration" "ssn_k8s_launch_conf_masters" {
  name                 = "${var.service_base_name}-ssn-launch-conf-masters"
  image_id             = var.ami
  instance_type        = var.ssn_k8s_masters_shape
  key_name             = var.key_name
  security_groups      = [aws_security_group.ssn_k8s_sg.id]
  iam_instance_profile = aws_iam_instance_profile.k8s-profile.name
  root_block_device {
    volume_type           = "gp2"
    volume_size           = var.ssn_root_volume_size
    delete_on_termination = true
  }

  lifecycle {
    create_before_destroy = true
  }
  user_data = data.template_file.ssn_k8s_masters_user_data.rendered
}

resource "aws_launch_configuration" "ssn_k8s_launch_conf_workers" {
  name                 = "${var.service_base_name}-ssn-launch-conf-workers"
  image_id             = var.ami
  instance_type        = var.ssn_k8s_workers_shape
  key_name             = var.key_name
  security_groups      = [aws_security_group.ssn_k8s_sg.id]
  iam_instance_profile = aws_iam_instance_profile.k8s-profile.name
  root_block_device {
    volume_type           = "gp2"
    volume_size           = var.ssn_root_volume_size
    delete_on_termination = true
  }

  lifecycle {
    create_before_destroy = true
  }
  user_data = data.template_file.ssn_k8s_workers_user_data.rendered
}

resource "aws_autoscaling_group" "ssn_k8s_autoscaling_group_masters" {
  name                 = "${var.service_base_name}-ssn-masters"
  launch_configuration = aws_launch_configuration.ssn_k8s_launch_conf_masters.name
  min_size             = var.ssn_k8s_masters_count
  max_size             = var.ssn_k8s_masters_count
  vpc_zone_identifier  = [data.aws_subnet.k8s-subnet-data.id]
  target_group_arns    = [aws_lb_target_group.ssn_k8s_lb_target_group.arn]

  lifecycle {
    create_before_destroy = true
  }
  tags = [
    {
      key                 = "Name"
      value               = "${var.service_base_name}-ssn-masters"
      propagate_at_launch = true
    }
  ]
}

resource "aws_autoscaling_group" "ssn_k8s_autoscaling_group_workers" {
  name                 = "${var.service_base_name}-ssn-workers"
  launch_configuration = aws_launch_configuration.ssn_k8s_launch_conf_workers.name
  min_size             = var.ssn_k8s_workers_count
  max_size             = var.ssn_k8s_workers_count
  vpc_zone_identifier  = [data.aws_subnet.k8s-subnet-data.id]

  lifecycle {
    create_before_destroy = true
  }
  tags = [
    {
      key                 = "Name"
      value               = "${var.service_base_name}-ssn-workers"
      propagate_at_launch = true
    }
  ]
}