output "alb_dns" { value = aws_lb.app.dns_name }
output "frontend_bucket" { value = aws_s3_bucket.frontend.bucket }
output "frontend_cloudfront_domain" { value = aws_cloudfront_distribution.frontend.domain_name }
output "video_bucket" { value = aws_s3_bucket.videos.bucket }
output "sqs_queue_url" { value = aws_sqs_queue.jobs.url }
output "aurora_endpoint" { value = aws_rds_cluster.aurora.endpoint }
