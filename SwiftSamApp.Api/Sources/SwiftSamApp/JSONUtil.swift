import Foundation
import Logging

func printJson(_ str:String) {
    print(reserializeJson(str))
}

func printJson(_ logger:Logger, _ str:String) {
    logger.info("\(reserializeJson(str))")
}

func reserializeJson(_ str:String, pretty:Bool = false) -> String {
    var json:Any
    do {
        // make sure this JSON is in the format we expect
        json = try JSONSerialization.jsonObject(with: str.data(using: .utf8)!)
    } catch let error as NSError {
        print("reserializeJson() failed: \(error.localizedDescription)")
        return ""
    }

    // let json = try! JSONSerialization.jsonObject(with: str.data(using: .utf8)!)
    let jsonDict = json as! [String:String]
    
    let encoder = JSONEncoder()
    if pretty {
        encoder.outputFormatting = .prettyPrinted
    }
    
    let jsonData = try! encoder.encode(jsonDict)
    return String(data: jsonData, encoding: .utf8)!
}
