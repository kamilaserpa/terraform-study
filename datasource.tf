data “aws_ami” “latest_amazon_linux” {
    most_recent = true
    
    filter {
        name = “name”
        values = [“amzn2-ami-hvm-*-x86_64-gp2”]
    }
    filter {
        name = "virtualization-type"
        values = [“hvm”]
    }

    owners = [“137112412989”] # AWS ID oficial para AMIs da Amazon
}

data "aws_s3_bucket" "fiap_previouslly_created" {
    bucket = "fiap-created"
}