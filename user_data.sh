#! /bin/bash
sudo apt-get update
echo "ECS_CLUSTER=${ecs_cluster}" >> /etc/ecs/ecs.config