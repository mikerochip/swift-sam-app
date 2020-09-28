import AWSLambdaEvents
import AWSLambdaRuntime
import NIO

struct APIGatewayProxyLambda: EventLoopLambdaHandler {
    public typealias In = APIGateway.V2.Request
    public typealias Out = APIGateway.V2.Response

    public func handle(context: Lambda.Context, event: In) -> EventLoopFuture<Out> {
        print("Entered lambda handler \(context.requestID)")
        let response = handleRoute(event)
        print("Exiting lambda handler \(context.requestID)")
        return context.eventLoop.makeSucceededFuture(response)
    }
    
    private func handleRoute(_ event: In) -> Out {
        let path = event.context.http.path
        let method = event.context.http.method
        
        if path == "/" {
            if method == HTTPMethod.GET {
                return Out(statusCode: .ok, body: handleHello(event.body))
            }
        }
        
        return Out(statusCode: .notFound, body: "Invalid Route")
    }
    
    private func handleHello(_ body: String?) -> String {
        return "Hello, world!"
    }
}
