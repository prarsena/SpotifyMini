//
//  AppDelegate.swift
//  spotifymini
//
//  Created by admin on 4/6/23.
//

import Cocoa
import SwiftUI

let defaults = UserDefaults.standard
let bearer = defaults.object(forKey:"BearerToken") as? String
let reToken = defaults.object(forKey:"RefreshToken") as? String

class AppData: ObservableObject {
    @Published var bearerToken: String = bearer ?? ""
    @Published var refreshToken: String = reToken ?? ""
    @Published var base64EncodedString: String = ""
}

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    var popover: NSPopover!
    var statusBarItem: NSStatusItem!
    @State var appData = AppData()
    let defaults = UserDefaults.standard
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView(appData: $appData)

        // Create the popover
        let popover = NSPopover()
        popover.contentSize = NSSize(width: 500, height: 250)
        popover.appearance = NSAppearance(named: .aqua)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: contentView)
        self.popover = popover
        
        // Create the status item
        self.statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))
        
        if let button = self.statusBarItem.button {
            button.image = NSImage(named: "SpotifyIcon24")
            button.action = #selector(togglePopover(_:))
        }
    }
    
    @objc func togglePopover(_ sender: AnyObject?) {
        if let button = self.statusBarItem.button {
            if self.popover.isShown {
                self.popover.performClose(sender)
            } else {
                self.popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            }
        }
    }

    func application(_ application: NSApplication,
                     open urls: [URL]){
        
        print("help \(urls[0])" )
        let codeUrl = urls[0]
        let myCode = codeUrl.valueOf("code") ?? "none"
        let creds = SecretCredentials()
        let client_id = creds.client_id
        let client_secret = creds.client_secret;
        let authString = "\(client_id):\(client_secret)"
        let authData = authString.data(using: .utf8)
        let base64EncodedString = authData!.base64EncodedString()
        self.appData.base64EncodedString = base64EncodedString
        
        let auth = OAuthAuthenticator()
        
        auth.getAccessToken(basicAuthCode: base64EncodedString, code: myCode, redirect_uri: "spotifymini://callback", completion: {
            (result) in DispatchQueue.main.async {
                
                let strResult = String(describing: result)
                
                let removeParenths = strResult[strResult.index(strResult.startIndex, offsetBy:34) ..< strResult.index(strResult.endIndex, offsetBy: -2)]
                let jsonString = "{ \(removeParenths) }"
                var termsArray = jsonString.split(separator: " ")
                termsArray[1] = "\"access_token\":"
                termsArray[3] = "\"refresh_token\":"
                termsArray[5] = "\"expires_in\":"
                
                let jsonStrings = termsArray.joined(separator: "")
                
                let jsonData = Data(jsonStrings.utf8)
                
                do {
                    let tokenResponse = try JSONDecoder().decode(AccessTokenResponse.self, from: jsonData)
                        print(tokenResponse.access_token)
                        self.appData.bearerToken = tokenResponse.access_token
                        self.appData.refreshToken = tokenResponse.refresh_token
                    
                    self.defaults.set(tokenResponse.access_token, forKey: "BearerToken")
                    self.defaults.set(tokenResponse.refresh_token, forKey: "RefreshToken")
                }
                catch {
                    print("coudln't decode this one")
                }
            }
        })

    }
}

func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { true }

extension URL {
    func valueOf(_ queryParameterName: String) -> String? {
        guard let url = URLComponents(string: self.absoluteString) else { return nil }
        return url.queryItems?.first(where: { $0.name == queryParameterName })?.value
    }
}
