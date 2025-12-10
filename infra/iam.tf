# ECS task execution role (pull images, write logs)
resource "aws_iam_role" "ecs_task_execution" {
  name = "${var.project}-ecsTaskExecutionRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "ecs-tasks.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_exec_attach" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# API task role (access S3, SQS, RDS, Redis as needed)
resource "aws_iam_role" "api_task" {
  name = "${var.project}-apiTaskRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "ecs-tasks.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role" "worker_task" {
  name = "${var.project}-workerTaskRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "ecs-tasks.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

# Minimal S3 + SQS policy for demo
resource "aws_iam_policy" "s3_sqs_policy" {
  name = "${var.project}-s3-sqs-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["s3:*"],
        Resource = ["*"]
      },
      {
        Effect   = "Allow",
        Action   = ["sqs:*"],
        Resource = ["*"]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "api_attach_policy" {
  role       = aws_iam_role.api_task.name
  policy_arn = aws_iam_policy.s3_sqs_policy.arn
}
resource "aws_iam_role_policy_attachment" "worker_attach_policy" {
  role       = aws_iam_role.worker_task.name
  policy_arn = aws_iam_policy.s3_sqs_policy.arn
}


resource "aws_iam_role" "api_task_role" {
  name = "${var.project}-api-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "ecs-tasks.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "api_task_policy" {
  name = "${var.project}-api-task-policy"
  role = aws_iam_role.api_task_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [

      # S3: Only “videos” bucket
      {
        Effect   = "Allow",
        Action   = ["s3:PutObject", "s3:GetObject"],
        Resource = "arn:aws:s3:::${var.project}-videos/*"
      },

      # SQS: Only your job queue
      {
        Effect   = "Allow",
        Action   = ["sqs:SendMessage"],
        Resource = aws_sqs_queue.jobs.arn
      },

      # Secrets Manager: Only DB secret
      {
        Effect   = "Allow",
        Action   = ["secretsmanager:GetSecretValue"],
        Resource = aws_secretsmanager_secret.db.arn
      }
    ]
  })
}
