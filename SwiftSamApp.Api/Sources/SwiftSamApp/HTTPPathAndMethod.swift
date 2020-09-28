import AWSLambdaEvents

struct HTTPPathAndMethod: Hashable {
    let path: String
    let method: HTTPMethod
    
    init(_ path: String, _ method: HTTPMethod) {
        self.path = path
        self.method = method
    }

    static func == (lhs: HTTPPathAndMethod, rhs: HTTPPathAndMethod) -> Bool {
        return lhs.path == rhs.path && lhs.method == rhs.method
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(path)
        hasher.combine(method.rawValue)
    }
}
