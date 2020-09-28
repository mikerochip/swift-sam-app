import AWSLambdaEvents

struct RouteKey: Hashable {
    let path: String
    let method: HTTPMethod
    
    init(_ path: String, _ method: HTTPMethod) {
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
