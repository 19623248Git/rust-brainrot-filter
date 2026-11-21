output "whoami" {
  value = data.aws_caller_identity.me.arn
}

output "pub_ip" {
  value = aws_instance.ec2_proxy.public_ip
}

output "pub_dns"{
  value = aws_instance.ec2_proxy.public_dns
}