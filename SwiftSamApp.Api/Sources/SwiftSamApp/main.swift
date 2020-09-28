import AWSLambdaRuntime

print("I'm alive!")

Lambda.run { (context: Lambda.Context, _: String, callback: (Result<String, Error>) -> Void) in
    context.logger.debug("Entered lambda handler")
    callback(.success("Hello, world!"))
    context.logger.debug("Exited lambda handler")
}
