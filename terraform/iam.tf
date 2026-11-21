# trust policy for ec2
data "aws_iam_policy_document" "proxy_assume" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
        type = "Service"
      identifiers = [ "ec2.amazonaws.com" ]
    }
  }
}

# only ec2 services can assume the role of "${var.project_name}-proxy-iam" 
resource "aws_iam_role" "proxy_iam" {
  name = "${var.project_name}-proxy-iam"
  assume_role_policy = data.aws_iam_policy_document.proxy_assume
}

# attach the iam to the policy
resource "aws_iam_policy_attachment" "proxy_iam_attach" {
  name = "${var.project_name}-proxy-iam-attach"
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# ec2 identity based policy, wrap it around an instance profile
resource "aws_iam_instance_profile" "proxy_iam_profile" {
  name = "${var.project_name}-proxy-iam-profile"
  role = aws_iam_role.proxy_iam.name
}


