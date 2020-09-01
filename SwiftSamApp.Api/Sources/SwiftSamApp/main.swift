import AWSLambdaRuntime

Lambda.run { (_: Lambda.Context, _: String, callback: (Result<String, Error>) -> Void) in
    callback(.success("Hello, world!"))
}
