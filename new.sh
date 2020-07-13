#!/bin/bash
AWS_REGION="eu-west-2"
TASK_FAMILY="ttn-qa-webapp-task"
SERVICE_NAME="ttn-qa-webapp-service"
NEW_DOCKER_IMAGE="tomcat"
CLUSTER_NAME= "sample"
OLD_TASK_DEF=$(aws ecs describe-task-definition --task-definition $TASK_FAMILY --output json)
NEW_TASK_DEF=$(echo $OLD_TASK_DEF | jq --arg NDI $NEW_DOCKER_IMAGE '.taskDefinition.containerDefinitions[0].image=$NDI')
FINAL_TASK=$(echo $NEW_TASK_DEF | jq '.taskDefinition|{family: .family, volumes: .volumes, containerDefinitions: .containerDefinitions}')
aws ecs register-task-definition --family $TASK_FAMILY --cli-input-json "$(echo $FINAL_TASK)"
aws ecs update-service --service ${SERVICE_NAME} --cluster sample --task-definition ${TASK_FAMILY} --desired-count 3 --region ${AWS_REGION}

