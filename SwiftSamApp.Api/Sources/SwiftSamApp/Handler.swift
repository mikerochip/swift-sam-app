import AWSLambdaRuntime
import AWSLambdaEvents
import HTTPTypes

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

        routeTable[RouteKey("/", HTTPRequest.Method.get)] = handleHello
    }
    
    public func handle(_ request: Request, context: LambdaContext) async throws -> Response {
        printJson(context.logger, """
        {
            "Action": "Enter",
            "RequestId": "\(context.requestID)"
        }
        """)
        
        let response = routeAndHandleEvent(request)
        printJson(response.body!)
        
        printJson(context.logger, """
        {
            "Action": "Exit",
            "RequestId": "\(context.requestID)",
            "Response": \(response.body!)
        }
        """)
        return response
    }
    
    func routeAndHandleEvent(_ request: Request) -> Response {
        let routeKey = RouteKey(request.context.http.path, request.context.http.method)
        
        guard let handler = routeTable[routeKey] else {
            return Response(statusCode: .notFound, body: reserializeJson("""
            {
                "Error": "Invalid route",
                "Route": "\(routeKey.path)"
            }
            """,
            pretty: true))
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
