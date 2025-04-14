import AWSLambdaEvents

struct RouteKey: Hashable {
    let path: String
    let method: HTTPRequest.Method
    
    init(_ path: String, _ method: HTTPRequest.Method) {
        self.path = path
        self.method = method
    }

    static func == (lhs: RouteKey, rhs: RouteKey) -> Bool {
        return lhs.path == rhs.path && lhs.method == rhs.method
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(path)
        hasher.combine(method.rawValue)
    }
}
