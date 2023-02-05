# Create load balancer outputs

output "elb_target_groupr_arn" {
  value = aws_lb_target_group.Miniproject-target-group.arn
}

output "elb_load_balancer_dns_name" {
  value = aws_lb.Miniproject-load-balancer.dns_name
}

output "elastic_load_balancer_zone_id" {
  value = aws_lb.Miniproject-load-balancer.zone_id
}
