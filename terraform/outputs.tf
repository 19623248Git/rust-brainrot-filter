output "whoami" {
  value = data.aws_caller_identity.me.arn
}

output "pub_ip" {
  value = aws_instance.ec2_proxy.public_ip
}

output "pub_dns"{
  value = aws_instance.ec2_proxy.public_dns
}

output "instance_id" {
  value = aws_instance.ec2_proxy.id
}

output "ssm_command" {
  value = "aws ssm start-session --target ${aws_instance.ec2_proxy.id} --profile iam-xops --region ap-southeast-2"
}