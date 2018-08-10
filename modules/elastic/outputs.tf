output "cwl_stream_lambda_arn" {
  value = "${aws_lambda_function.cwl_stream_lambda.arn}"
}

output "lambda_name" {
  value = "${aws_lambda_function.cwl_stream_lambda.function_name}"
}