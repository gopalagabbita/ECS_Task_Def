#!/bin/bash

# Validate required inputs
if [[ -z "${INPUT_IMAGE_URI}" ]]; then
  echo "Error: Missing required input: IMAGE_URI"
  exit 1
fi

# need to add validation for all parameters

# Base JSON template (modify for your container definitions) & Adjust for launch type
if [[ "${INPUT_LAUNCH_TYPE}" == "FARGATE" ]]; then
  echo "Using Fargate launch type..."
  cat <<EOF > task-definition.json
  {
    "family": "${INPUT_TASK_FAMILY}",
    "networkMode": "${INPUT_NETWORK_MODE}",
    "containerDefinitions": [
      {
        "name": "${INPUT_CONTAINER_NAME}",
        "image": "${INPUT_IMAGE_URI}",
        "portMappings": [
          {
            "name": "${INPUT_PORT}",
            "containerPort": ${INPUT_PORT},
            "hostPort": ${INPUT_PORT},
            "protocol": "${INPUT_PROTOCOL}",
            "appProtocol": "${INPUT_APPPROTOCOL}"
          }
        ],
        "essential": true,
        "environment":${INPUT_ENV_VARIABLE}
      }
    ],
    "executionRoleArn": "${INPUT_EX_ROLE}",
    "compatibilities": [
        "EC2",
        "FARGATE"
    ],
    "requiresCompatibilities": [
        "FARGATE"
    ],
    "cpu": "${INPUT_CPU}",
    "memory": "${INPUT_MEMORY}",
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-create-group": "true",
        "awslogs-group": "/ecs/${INPUT_CONTAINER_NAME}",
        "awslogs-region": "us-east-1",
        "awslogs-stream-prefix": "ecs"
       },
      "secretOptions": []
    }
  }
EOF

else
  # Add EC2-specific configurations (e.g., instance type, IAM role)
  echo "Using EC2 launch type..."
  cat <<EOF > task-definition.json
  {
    "family": "${INPUT_TASK_FAMILY}",
    "networkMode": "${INPUT_NETWORK_MODE}",
    "containerDefinitions": [
      {
        "name": "${INPUT_CONTAINER_NAME}",
        "image": "${INPUT_IMAGE_URI}",
        "cpu": "${INPUT_CPU}",
        "memory": "${INPUT_MEMORY}"
        "portMappings": [
          {
            "name": "${INPUT_PORT}",
            "containerPort": ${INPUT_PORT},
            "hostPort": ${INPUT_PORT},
            "protocol": "${INPUT_PROTOCOL}",
            "appProtocol": "${INPUT_APPPROTOCOL}"
          }
        ],
        "essential": true,
        "environment":${INPUT_ENV_VARIABLE}
      }
    ],
    "executionRoleArn": "${INPUT_EX_ROLE}",
    "compatibilities": [
        "EC2",
        "FARGATE"
    ],
    "requiresCompatibilities": [
        "EC2"
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-create-group": "true",
        "awslogs-group": "/ecs/${INPUT_CONTAINER_NAME}",
        "awslogs-region": "us-east-1",
        "awslogs-stream-prefix": "ecs"
       },
      "secretOptions": []
    }
  }
EOF
fi

echo "Created task definition: task-definition.json"