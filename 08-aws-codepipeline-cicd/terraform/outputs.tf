output "pipeline_name" {
  value = aws_codepipeline.main.name
}
output "codebuild_project" {
  value = aws_codebuild_project.main.name
}
output "ecr_repository_url" {
  value = aws_ecr_repository.app.repository_url
}
output "artifact_bucket" {
  value = aws_s3_bucket.artifacts.bucket
}
output "github_connection_arn" {
  description = "Complete the GitHub connection in AWS Console after apply"
  value       = aws_codestarconnections_connection.github.arn
}
