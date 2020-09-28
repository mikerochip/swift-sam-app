import AWSLambdaEvents
import AWSLambdaRuntime
import NIO

struct APIGatewayProxyLambda: EventLoopLambdaHandler {
    public typealias In = APIGateway.V2.Request
    public typealias Out = APIGateway.V2.Response
    
    var routeTable: [HTTPPathAndMethod: (In) -> Out] = [:]
    
    init() {
        routeTable[HTTPPathAndMethod("/", HTTPMethod.GET)] = handleHello
    }
    
    public func handle(context: Lambda.Context, event: In) -> EventLoopFuture<Out> {
        print("Entered lambda handler \(context.requestID)")
        let response = handleRoute(event)
        print("Exiting lambda handler \(context.requestID)")
        return context.eventLoop.makeSucceededFuture(response)
    }
    
    private func handleRoute(_ event: In) -> Out {
        let path = event.context.http.path
        let method = event.context.http.method
        
        guard let handler = routeTable[HTTPPathAndMethod(path, method)] else {
            return Out(statusCode: .notFound, body: "Invalid Route")
        }
        
        return handler(event)
    }
    
    private func handleHello(_ event: In) -> Out {
        return Out(statusCode: .ok, body: "Hello, world!")
    }
}
