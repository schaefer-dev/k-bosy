import Foundation

public struct AutomataInfo: Codable {
    public let observableAP: [String]
    public let hiddenAP: [String]
    public let outputs: [String]
    public let initialStates: [String]

    public init(observableAP: [String], hiddenAP: [String], outputs: [String], initialStates: [String]) {
        self.observableAP = observableAP
        self.hiddenAP = hiddenAP
        self.outputs = outputs
        self.initialStates = initialStates
    }
    
    public static func fromJson(string: String) -> AutomataInfo? {

        let decoder = JSONDecoder()
        guard let data = string.data(using: .utf8) else {
            return nil
        }
        do {
            return try decoder.decode(AutomataInfo.self, from: data)
        } catch {
            return nil
        }
    }
    

    public static func from(fileName: String) throws -> AutomataInfo {
        // get file contents
        let data = try Data(contentsOf: URL(fileURLWithPath: fileName))
        return try from(data: data)
    }

    
    public static func from(data: Data) throws -> AutomataInfo {
        // parse contents of `data`
        return try JSONDecoder().decode(AutomataInfo.self, from: data)
    }
    
    
    public func jsonString() -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        do {
            let jsonData = try encoder.encode(self)

            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
        } catch {
            print(error.localizedDescription)
        }
        
        return ""
    }

}


public func readAutomataInfoFile(path: String) -> AutomataInfo? {
    /* Verify System requirements */
    if #available(OSX 10.11, *) {
        /* System requirements passed */
        let jsonURL = URL(fileURLWithPath: path)
        //print("loading json from path: " + jsonURL.path)


        /* try to read input JSON File */
        do {
            let jsonData =  try Data(contentsOf: jsonURL)
            //print("File data read.")
            // jsonData can be used
            let decoder = JSONDecoder()
            do {
                var automataInfo = try decoder.decode(AutomataInfo.self, from: jsonData)
                //print("AutomataInfoDecoding completed.")
                return automataInfo
                
                
            } catch {
                /* failed to decode content of jsonData */
                print("ERROR during Decoding: " + error.localizedDescription)
            }
        } catch {
            /* failed to read data from jsonURL */
            print("loading of jsonData error...")
        }
    } else {
        /* failed System Requirements */
        print("ERROR: Requires at least macOS 10.11")
    }
    return nil
}
