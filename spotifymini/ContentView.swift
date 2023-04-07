//
//  ContentView.swift
//  spotifymini
//
//  Created by admin on 4/6/23.
//

import SwiftUI

struct ContentView: View {
    @Binding var appData: AppData
    @State var myText = "Hi all"
    @State var trackName = "no idea"
    @State var artistName = "no idea"
    @State var albumName = "no idea"
    @State var artistArtwork = "no idea"
    @State var artistImage = NSImage(named: "black_and_white_pixels")
    @State var playPauseStatus = false
    @State var playStatusVerb = "play"
    @State var refreshToggle = false
    
    var backButton = NSImage(named: "NSTouchBarSkipToStartTemplate")
    var forwardButton = NSImage(named: "NSTouchBarSkipToEndTemplate")
    var pauseButton = NSImage(named: "NSTouchBarPauseTemplate")
    var playButton = NSImage(named: "NSTouchBarPlayTemplate")
    
    
    var body: some View {
        let authentic = OAuthAuthenticator()
        
        VStack(){
            //Text("Hello, SpotMini!")
            //    .font(.system(size: 24, weight: .bold, design: .default))
            
            HStack(alignment: .top){
                /*
                Button("My Account", action: {
                    authentic.getMySpotifyData(bearerToken: appData.bearerToken, completion: {
                        response in DispatchQueue.main.async {
                            print(response)
                        }
                    })
                })
              */
                
                Button("Now Playing", action: {
                    authentic.getCurrentSong(bearerToken: appData.bearerToken, completion: {
                        response in DispatchQueue.main.async {
                            print(response)
                            let jsonData = Data(response.utf8)
                            do {
                                let tokenResponse = try JSONDecoder().decode(SpotifyItem.self, from: jsonData)
                                print(tokenResponse.item.name)
                                trackName = tokenResponse.item.name
                                artistName = tokenResponse.item.artists[0].name
                                albumName = tokenResponse.item.album.name
                                artistArtwork = tokenResponse.item.album.images[0].url
                                playPauseStatus = tokenResponse.is_playing
                                do {
                                    let imageData = try Data(contentsOf: URL(string:artistArtwork)!)
                                    guard let img = NSImage(data: imageData) else {
                                        print("Cannot load data as image")
                                        return
                                    }
                                    let imgSize = NSMakeSize(100.0, 100.0)
                                    let resizedImage = resizeImage(image: img, maxSize: imgSize)
                                    artistImage = resizedImage
                                } catch {
                                    print(error)
                                }
                            } catch {
                                print("coulldn't parse")
                            }
                        }
                    })
                })
                
                Button("Refresh token", action: {
                    authentic.getRefreshToken(basicAuthHeader: appData.base64EncodedString, refresh_token: appData.refreshToken, completion: { result in
                        
                        DispatchQueue.main.async {
                            print("refresh token? \(result)")
                            let dataResult = Data(result.utf8)
                            do {
                                let tokenResponse = try JSONDecoder().decode(RefreshToken.self, from: dataResult)
                                self.appData.bearerToken = tokenResponse.access_token
                            } catch {
                                print("couldnt parse")
                            }
                        }
                    })
                })
                
                Button("Log into spotify", action: {
                    authentic.authenticate() { result in
                        var message: String = ""
                        switch result {
                        case .success(let accessTokenResponse):
                            message = accessTokenResponse.access_token
                        case .failure(let error):
                            message = error.localizedDescription
                        }
                        
                        DispatchQueue.main.async {
                            print("finished logging in")
                            myText = message
                            
                        }
                    }
                })
            }
            HStack(){
                VStack(alignment: .leading){
                    Image(nsImage: artistImage!)
                }
                VStack(alignment: .trailing) {
                    HStack(){
                        Text(trackName)
                            .font(.system(size: 24, weight: .light, design: .default))
                            .frame(alignment: .trailing)
                    }
                    HStack(){
                        Text(albumName)
                            .font(.system(size: 20, weight: .light, design: .default))
                            .frame(alignment: .trailing)
                    }
                    HStack(){
                        Text(artistName)
                            .font(.system(size: 20, weight: .light, design: .default))
                            .frame(alignment: .trailing)
                    }
                }
            }
            HStack{
                Button{
                    authentic.changeSong(verb: "previous", bearerToken: appData.bearerToken, completion: {
                        response in DispatchQueue.main.async {
                            print(response)
                            
                            authentic.getCurrentSong(bearerToken: appData.bearerToken, completion: {
                                
                                response in DispatchQueue.main.async {
                                    print(response)
                                    sleep(2)
                                    let jsonData = Data(response.utf8)
                                    do {
                                        let tokenResponse = try JSONDecoder().decode(SpotifyItem.self, from: jsonData)
                                        print(tokenResponse.item.name)
                                        trackName = tokenResponse.item.name
                                        artistName = tokenResponse.item.artists[0].name
                                        albumName = tokenResponse.item.album.name
                                        artistArtwork = tokenResponse.item.album.images[0].url
                                        do {
                                            let imageData = try Data(contentsOf: URL(string:artistArtwork)!)
                                            guard let img = NSImage(data: imageData) else {
                                                print("Cannot load data as image")
                                                return
                                            }
                                            let imgSize = NSMakeSize(100.0, 100.0)
                                            let resizedImage = resizeImage(image: img, maxSize: imgSize)
                                            artistImage = resizedImage
                                        } catch {
                                            print(error)
                                        }
                                    } catch {
                                        print("coulldn't parse")
                                    }
                                }
                            })
                        }
                    })
                } label: {
                    Image(nsImage: backButton!)
                }
                
                if playPauseStatus{
                    Button{
                        authentic.playPauseSong(verb: "pause", bearerToken: appData.bearerToken, completion: {
                            response in DispatchQueue.main.async{
                                print(response)
                                playStatusVerb = "pause"
                                playPauseStatus = false
                                //refreshToggle.toggle()
                            }
                        })
                    } label: {
                        Image(nsImage: pauseButton!)
                    }
                    
                } else {
                    Button{
                        authentic.playPauseSong(verb: "play", bearerToken: appData.bearerToken, completion: {
                            response in DispatchQueue.main.async{
                                print(response)
                                playStatusVerb = "play"
                                playPauseStatus = true
                                //refreshToggle.toggle()
                            }
                        })
                    } label: {
                       Image(nsImage: playButton!)
                   }
                }
            
                
                Button{
                    authentic.changeSong(verb: "next", bearerToken: appData.bearerToken, completion: {
                        response in DispatchQueue.main.async {
                            print(response)
                            
                            authentic.getCurrentSong(bearerToken: appData.bearerToken, completion: {
                                response in DispatchQueue.main.async {
                                    
                                    let jsonData = Data(response.utf8)
                                    do {
                                        let tokenResponse = try JSONDecoder().decode(SpotifyItem.self, from: jsonData)
                                        print(tokenResponse.item.name)
                                        trackName = tokenResponse.item.name
                                        artistName = tokenResponse.item.artists[0].name
                                        albumName = tokenResponse.item.album.name
                                        artistArtwork = tokenResponse.item.album.images[0].url
                                        playPauseStatus = tokenResponse.is_playing
                                        do {
                                            let imageData = try Data(contentsOf: URL(string:artistArtwork)!)
                                            guard let img = NSImage(data: imageData) else {
                                                print("Cannot load data as image")
                                                return
                                            }
                                            let imgSize = NSMakeSize(100.0, 100.0)
                                            let resizedImage = resizeImage(image: img, maxSize: imgSize)
                                            artistImage = resizedImage
                                        } catch {
                                            print(error)
                                        }
                                    } catch {
                                        print("coulldn't parse")
                                    }
                                }
                            })
                        }
                    })
                } label: {
                    Image(nsImage: forwardButton!)
                }
            }
            HStack {
                Button("Quit", action: {
                    print("Shutting down")
                    NSApplication.shared.terminate(self)
                })
                //Text(String(refreshToggle)).hidden()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .border(Color.black, width: 1)
        //.background(Color.blue)
        .opacity(0.75)
        .onAppear(){
            authentic.getCurrentSong(bearerToken: appData.bearerToken, completion: {
                response in DispatchQueue.main.async {
                    print(response)
                    let jsonData = Data(response.utf8)
                    do {
                        let tokenResponse = try JSONDecoder().decode(SpotifyItem.self, from: jsonData)
                        print(tokenResponse.item.name)
                        trackName = tokenResponse.item.name
                        artistName = tokenResponse.item.artists[0].name
                        albumName = tokenResponse.item.album.name
                        artistArtwork = tokenResponse.item.album.images[0].url
                        playPauseStatus = tokenResponse.is_playing
                        
                        do {
                            let imageData = try Data(contentsOf: URL(string:artistArtwork)!)
                            guard let img = NSImage(data: imageData) else {
                                print("Cannot load data as image")
                                return
                            }
                            let imgSize = NSMakeSize(100.0, 100.0)
                            let resizedImage = resizeImage(image: img, maxSize: imgSize)
                            artistImage = resizedImage
                        } catch {
                            print(error)
                        }
                    } catch {
                        print("coulldn't parse")
                    }
                }
            })
        }
    }
}
