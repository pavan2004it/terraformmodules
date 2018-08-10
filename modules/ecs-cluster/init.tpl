#!/bin/bash
sudo yum -y update
echo ECS_CLUSTER=${ecs_cluster_name}>> /etc/ecs/ecs.config
