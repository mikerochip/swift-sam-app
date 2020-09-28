import AWSLambdaEvents
import AWSLambdaRuntime
import NIO

print("I'm alive!")

Lambda.run(APIGatewayProxyLambda())

struct APIGatewayProxyLambda: EventLoopLambdaHandler {
    public typealias In = APIGateway.V2.Request
    public typealias Out = APIGateway.V2.Response

    public func handle(context: Lambda.Context, event: APIGateway.V2.Request) -> EventLoopFuture<APIGateway.V2.Response> {
        context.logger.debug("Entered lambda handler \(context.requestID)")
        
        let response = APIGateway.V2.Response(
            statusCode: .ok,
            body: "Hello, world!")
        
        context.logger.debug("Exiting lambda handler \(context.requestID)")
        return context.eventLoop.makeSucceededFuture(response)
    }
}
