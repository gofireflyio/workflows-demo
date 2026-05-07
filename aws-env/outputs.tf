output "instance_id" {
  description = "ID of the EC2 instance"
  value       = module.ec2_instance.id
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.data.id
}

output "gal_test2_instance_id" {
  description = "ID of the gal-test2 EC2 instance"
  value       = module.gal_test2_ec2_instance.id
}

output "gal_test2_instance_public_ip" {
  description = "Public IP of the gal-test2 EC2 instance"
  value       = module.gal_test2_ec2_instance.public_ip
}

output "gal_test2_instance_private_ip" {
  description = "Private IP of the gal-test2 EC2 instance"
  value       = module.gal_test2_ec2_instance.private_ip
} 