import AWSLambdaEvents
import AWSLambdaRuntime
import NIO

struct APIGatewayProxyLambda: EventLoopLambdaHandler {
    typealias In = APIGateway.V2.Request
    typealias Out = APIGateway.V2.Response
    
    var routeTable: [RouteKey: (In) -> Out] = [:]
    
    init() {
        routeTable[RouteKey("/", HTTPMethod.GET)] = handleHello
    }
    
    public func handle(context: Lambda.Context, event: In) -> EventLoopFuture<Out> {
        printJson(context.logger, """
        {
            "Action": "Enter",
            "RequestId": "\(context.requestID)"
        }
        """)
        
        let response = handleRoute(event)
        
        printJson(context.logger, """
        {
            "Action": "Exit",
            "RequestId": "\(context.requestID)"
        }
        """)
        return context.eventLoop.makeSucceededFuture(response)
    }
    
    func handleRoute(_ event: In) -> Out {
        let path = event.context.http.path
        let method = event.context.http.method
        
        guard let handler = routeTable[RouteKey(path, method)] else {
            return Out(statusCode: .notFound, body: "Invalid Route")
        }
        
        return handler(event)
    }
    
    func handleHello(_ event: In) -> Out {
        return Out(statusCode: .ok, body: convertToJson("""
        {
            "Message": "Hello, world!"
        }
        """))
    }
}
