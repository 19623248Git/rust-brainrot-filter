output "whoami" {
  value = data.aws_caller_identity.me.arn
}

output "pub_ip" {
  value = aws_eip.proxy_ip.public_ip
}

output "pub_dns" {
  value = aws_eip.proxy_ip.public_dns
}

output "wireguard_endpoint" {
  value = "${aws_eip.proxy_eip.public_ip}:${var.wireguard_port}"
}

output "instance_id" {
  value = aws_instance.ec2_proxy.id
}

output "ssm_command" {
  value = "aws ssm start-session --target ${aws_instance.ec2_proxy.id} --profile iam-xops --region ap-southeast-2"
}