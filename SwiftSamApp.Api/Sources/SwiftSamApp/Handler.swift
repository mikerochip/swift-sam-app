import AWSLambdaRuntime
import AWSLambdaEvents

@main
struct Handler: LambdaHandler {
    typealias Request = APIGatewayV2Request
    typealias Response = APIGatewayV2Response
    
    var routeTable: [RouteKey: (Request) -> Response] = [:]
    
    init(context: LambdaInitializationContext) async throws {
        printJson("""
        {
            "Message": "I'm alive!"
        }
        """)

        routeTable[RouteKey("/", HTTPMethod.GET)] = handleHello
    }
    
    public func handle(_ request: Request, context: LambdaContext) async throws -> Response {
        printJson(context.logger, """
        {
            "Action": "Enter",
            "RequestId": "\(context.requestID)"
        }
        """)
        
        let response = routeAndHandleEvent(request)
        
        printJson(context.logger, """
        {
            "Action": "Exit",
            "RequestId": "\(context.requestID)"
        }
        """)
        return response
    }
    
    func routeAndHandleEvent(_ request: Request) -> Response {
        let routeKey = RouteKey(request.context.http.path, request.context.http.method)
        
        guard let handler = routeTable[routeKey] else {
            return Response(statusCode: .notFound, body: "Invalid Route")
        }
        
        return handler(request)
    }
    
    func handleHello(_ request: Request) -> Response {
        return Response(statusCode: .ok, body: reserializeJson("""
        {
            "Message": "Hello, world!"
        }
        """,
        pretty: true))
    }
}
