import Foundation
import Logging

func printJson(_ str:String) {
    print(convertToJson(str))
}

func printJson(_ logger:Logger, _ str:String) {
    logger.info("\(convertToJson(str))")
}

func convertToJson(_ str:String) -> String {
    let json = try! JSONSerialization.jsonObject(with: str.data(using: .utf8)!)
    let jsonData = try! JSONEncoder().encode(json as! [String:String])
    return String(data: jsonData, encoding: .utf8)!
}
