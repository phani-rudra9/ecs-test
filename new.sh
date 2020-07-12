#!/bin/bash
AWS_REGION="ap-south-1"
TASK_FAMILY="ttn-qa-webapp-task"
SERVICE_NAME="ttn-qa-webapp-service"
NEW_DOCKER_IMAGE="phani9-devops:22"
CLUSTER_NAME= "ttn-qa-cluster"
OLD_TASK_DEF=$(aws ecs describe-task-definition --task-definition $TASK_FAMILY --output json)
NEW_TASK_DEF=$(echo $OLD_TASK_DEF | jq --arg NDI $NEW_DOCKER_IMAGE '.taskDefinition.containerDefinitions[0].image=$NDI')
FINAL_TASK=$(echo $NEW_TASK_DEF | jq '.taskDefinition|{family: .family, volumes: .volumes, containerDefinitions: .containerDefinitions}')
aws ecs register-task-definition --family $TASK_FAMILY --cli-input-json "$(echo $FINAL_TASK)"
aws ecs update --service $SERVICE_NAME --cluster $CLUSTER_NAME --task-definition $TASK_FAMILY --desired-count 3 --region $AWS_REGION 

