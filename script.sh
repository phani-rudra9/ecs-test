SERVICE="test"
CLUSTER_NAME="phani"
AWS_REGION="ap-south-1"
 
# Register a new Task definition 
aws ecs register-task-definition --family fargate-task-definition --cli-input-json file://manepalli.json --region $AWS_REGION

    # Update Service in the Cluster
aws ecs update-service --cluster $CLUSTER_NAME --service $SERVICE --task-definition fargate-task-definition --desired-count 3 --region $AWS_REGION --network-configuration "awsvpcConfiguration={subnets=[subnet-01f5291b725d36de8],securityGroups=[sg-07d3b962]}"



DECRIBED_SERVICE=$(aws ecs describe-services --region $AWS_REGION --cluster $CLUSTER_NAME --services $SERVICE);
CURRENT_DESIRED_COUNT=$(echo $DECRIBED_SERVICE | jq --raw-output ".services[0].desiredCount")
    #    - echo $CURRENT_DESIRED_COUNT

CURRENT_TASK_REVISION=$(echo $DECRIBED_SERVICE | jq -r ".services[0].taskDefinition")
echo "Current Task definition in Service" + $CURRENT_TASK_REVISION

CURRENT_RUNNING_TASK=$(echo $DECRIBED_SERVICE | jq -r ".services[0].runningCount")
echo $CURRENT_RUNNING_TASK

CURRENT_STALE_TASK=$(echo $DECRIBED_SERVICE | jq -r ".services[0].deployments | .[] | select(.taskDefinition != \"$CURRENT_TASK_REVISION\") | .taskDefinition")
echo "Task defn apart from current service Taskdefn" +  $CURRENT_STALE_TASK
    #   - echo $CURRENT_STALE_TASK

tasks=$(aws ecs --region $AWS_REGION list-tasks --cluster $CLUSTER_NAME | jq -r '.taskArns | map(.[40:]) | reduce .[] as $item (""; . + $item + " ")')
echo "Tasks are as follows" 
echo $tasks
TASKS=$(aws ecs --region $AWS_REGION describe-tasks --cluster $CLUSTER_NAME --task $tasks);
    #    - echo $TASKS
OLDER_TASK=$(echo $TASKS | jq -r ".tasks[] | select(.taskDefinitionArn!= \"$CURRENT_TASK_REVISION\") | .taskArn | split(\"/\") | .[1] ")
echo "Older Task running  " + $OLDER_TASK
for old_task in $OLDER_TASK; do
     aws ecs --region $AWS_REGION stop-task --cluster $CLUSTER_NAME --task $old_task
done    

    # Run new tasks with the updated new Task-definition
aws ecs --region $AWS_REGION run-task --cluster $CLUSTER_NAME --task-definition $CURRENT_TASK_REVISION
