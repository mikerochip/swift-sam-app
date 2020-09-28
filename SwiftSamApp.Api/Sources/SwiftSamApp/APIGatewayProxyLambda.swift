import AWSLambdaEvents
import AWSLambdaRuntime
import NIO

struct APIGatewayProxyLambda: EventLoopLambdaHandler {
    public typealias In = APIGateway.V2.Request
    public typealias Out = APIGateway.V2.Response

    public func handle(context: Lambda.Context, event: APIGateway.V2.Request) -> EventLoopFuture<APIGateway.V2.Response> {
        print("Entered lambda handler \(context.requestID)")
        
        let response = APIGateway.V2.Response(
            statusCode: .ok,
            body: "Hello, world!")
        
        print("Exiting lambda handler \(context.requestID)")
        return context.eventLoop.makeSucceededFuture(response)
    }
}
