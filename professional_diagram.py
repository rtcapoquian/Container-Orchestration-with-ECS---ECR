from diagrams import Cluster, Diagram, Edge
from diagrams.aws.network import (VPC, InternetGateway, NATGateway, 
                                 ElbApplicationLoadBalancer, PrivateSubnet, PublicSubnet)
from diagrams.aws.compute import ElasticContainerService, Fargate, EC2ContainerRegistry
from diagrams.aws.devtools import Codepipeline, Codebuild, Codedeploy
from diagrams.aws.management import Cloudwatch
from diagrams.aws.integration import SimpleNotificationServiceSns
from diagrams.aws.security import KeyManagementService, SecretsManager
from diagrams.aws.storage import SimpleStorageServiceS3
from diagrams.aws.general import InternetAlt1, General

with Diagram("AWS ECS Microservices Architecture", show=False, direction="TB", 
             filename="aws_ecs_professional_architecture", outformat="png",
             graph_attr={
                 "fontsize": "20",
                 "fontname": "Arial Bold",
                 "dpi": "300"
             },
             node_attr={
                 "fontsize": "12",
                 "fontname": "Arial Bold",
                "dpi": "300"
             },
             edge_attr={
                 "fontsize": "16",
                 "fontname": "Arial",
                 "penwidth": "2"
             }):

    # Internet and Gateway
    internet = InternetAlt1("Internet")
    igw = InternetGateway("Internet Gateway")

    with Cluster("VPC"):
        vpc = VPC("Main VPC")

        with Cluster("Public Subnets"):
            public_subnet1 = PublicSubnet("Public Subnet")
            nat_gw1 = NATGateway("NAT Gateway")
            alb = ElbApplicationLoadBalancer("Application Load Balancer")

        with Cluster("Private Subnets"):
            private_subnet1 = PrivateSubnet("Private Subnet")
            
            with Cluster("ECS Cluster"):
                ecs_cluster = ElasticContainerService("ECS Cluster")
                frontend_task1 = Fargate("Frontend Service")
                backend_task1 = Fargate("Backend Service")

    # Internet connectivity
    internet >> igw
    igw >> alb
    
    # ALB to services routing
    alb >> frontend_task1
    alb >> backend_task1

    # NAT Gateway connections
    nat_gw1 >> private_subnet1

    with Cluster("CI/CD Pipeline"):
        github = General("GitHub")
        pipeline = Codepipeline("CodePipeline")
        build = Codebuild("CodeBuild")
        ecr_frontend = EC2ContainerRegistry("Frontend Repository")
        ecr_backend = EC2ContainerRegistry("Backend Repository")
        deploy = Codedeploy("CodeDeploy")

        # Pipeline flow
        github >> pipeline >> build >> ecr_frontend
        github >> pipeline >> build >> ecr_backend
        deploy >> frontend_task1
        deploy >> backend_task1

    # Monitoring, Notifications, Secrets, Artifacts
    monitoring = Cloudwatch("CloudWatch Monitoring")
    notif = SimpleNotificationServiceSns("SNS Notifications")
    secrets = SecretsManager("Secrets Manager")
    kms = KeyManagementService("KMS Encryption")
    s3 = SimpleStorageServiceS3("S3 Artifacts")

    # Connections for monitoring and services
    frontend_task1 >> monitoring
    backend_task1 >> monitoring
    monitoring >> notif
    
    # Pipeline to S3 and encryption
    pipeline >> s3
    s3 >> kms
    
    # Services to secrets
    frontend_task1 >> secrets
    backend_task1 >> secrets
