import Foundation
import Logging

func printJson(_ str:String) {
    print(reserializeJson(str))
}

func printJson(_ logger:Logger, _ str:String) {
    logger.info("\(reserializeJson(str))")
}

func reserializeJson(_ str:String, pretty:Bool = false) -> String {
    var jsonObj:Any
    do {
        // make sure this JSON is in the format we expect
        jsonObj = try JSONSerialization.jsonObject(with: str.data(using: .utf8)!)
    } catch let error as NSError {
        print("reserializeJson failed: \(error.localizedDescription)")
        return ""
    }

    let jsonDict = jsonObj as? [String:Any]
    
    let encoder = JSONEncoder()
    if pretty {
        encoder.outputFormatting = .prettyPrinted
    }
    
    let jsonStringDict = jsonDict!.mapValues { String(describing: $0) }
    let jsonStr = try! encoder.encode(jsonStringDict)
    return String(data: jsonStr, encoding: .utf8)!
}
