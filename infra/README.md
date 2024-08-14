# Getting Started

# Requirements
* awscli
* [Session Manager Plugin](https://docs.aws.amazon.com/systems-manager/latest/userguide/install-plugin-macos-overview.html)


### Port forwarding to AWS services

**RDS Instance**
```bash
aws ssm start-session \
    --target <ssm_host_instance_id> \
    --document-name AWS-StartPortForwardingSessionToRemoteHost \
    --parameters host="<rds_endpoint>",localPortNumber="3306",portNumber="3306"
```

**EC2 Instance**
```bash
aws ssm start-session \
    --target <ssm_host_instance_id> \
    --document-name AWS-StartPortForwardingSessionToRemoteHost \
    --parameters host="<app_server_private_ip>",localPortNumber="8080",portNumber="80"
```