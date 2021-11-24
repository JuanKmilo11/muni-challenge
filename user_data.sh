#! /bin/bash
sudo apt-get update
echo ECS_CLUSTER=${ecs_cluster} >> /etc/ecs/ecs.config
echo ECS_CONTAINER_INSTANCE_TAGS={"Name": "ECS-Instance"} >> /etc/ecs/ecs.config