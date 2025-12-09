import SwiftUI

@main
struct Track_Time_App: App {
    var body: some Scene {
        WindowGroup {
            Root()
        }
    }
}

enum Data {

    static let applink = URL(string: "https://apps.apple.com/app/id6756315482")!
    static let terms = URL(string: "https://docs.google.com/document/d/e/2PACX-1vTa_Gi56iD0UpO2FzIknVw6oiY0MtpU0mU55nbE3KRk5z00hEGy_e2PAL6cNAb98-AKOCRCbyWcEOno/pub")!
    static let policy = URL(string: "https://docs.google.com/document/d/e/2PACX-1vTa_Gi56iD0UpO2FzIknVw6oiY0MtpU0mU55nbE3KRk5z00hEGy_e2PAL6cNAb98-AKOCRCbyWcEOno/pub")!

    static var shareMessage: String {
        """
        Track Any Moment 
        \(applink.absoluteString)
        """
    }

    static var shareItems: [Any] { [shareMessage, applink] }
}
