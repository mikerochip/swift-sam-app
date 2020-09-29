
func printJson(_ str:String) {
    print(stripNewlines(str))
}

func stripNewlines(_ str:String) -> String {
    return str.replacingOccurrences(of: "\n", with: "")
}
