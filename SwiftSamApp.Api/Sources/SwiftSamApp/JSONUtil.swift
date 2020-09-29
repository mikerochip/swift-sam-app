import Logging

func printJson(_ str:String) {
    print(stripNewlines(str))
}

func printJson(_ logger:Logger, _ str:String) {
    logger.info("\(stripNewlines(str))")
}

func stripNewlines(_ str:String) -> String {
    return str.replacingOccurrences(of: "\n", with: "")
}
