//
//  SpotifyFunctions.swift
//  spotifymini
//
//  Created by admin on 4/6/23.
//

import Foundation

extension OAuthAuthenticator {
    
    public func getMySpotifyData(bearerToken: String, completion: @escaping (String) -> Void ) {
        let req = URLRequest.createSpotifyRequest(bearerToken: bearerToken)
        let session = URLSession.shared
        let dataTask = session.dataTask(with: req, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                //completion(.failure(OAuth2AuthenticatorError.tokenRequestFailed(error!)))
                completion("Err \(String(describing: error))")
                return
            } else {
                guard let data  = data else {
                    completion("no response")
                    return
                }
                do {
                    print(String(decoding: data, as: UTF8.self) )
                    completion(String(decoding: data, as: UTF8.self))
                }
            }
        })
        dataTask.resume()
    }
    
    public func getCurrentSong (bearerToken: String, completion:
        @escaping (String) -> Void) {
        let req = URLRequest.createGetCurrentSongRequest(bearerToken: bearerToken)
        let session = URLSession.shared
        let dataTask = session.dataTask(with: req, completionHandler: {
            (data, response, error) -> Void in
            if (error != nil) {
                completion("Err \(String(describing: error))")
                return
            } else {
                guard let data  = data else {
                    completion("no response")
                    return
                }
                do {
                    completion(String(decoding: data, as: UTF8.self) )
                }
            }
        })
        dataTask.resume()
    }
    
    public func changeSong (verb: String, bearerToken: String, completion:
        @escaping (String) -> Void) {
        let req = URLRequest.createChangeSongRequest(verb: verb, bearerToken: bearerToken)
        let session = URLSession.shared
        let dataTask = session.dataTask(with: req, completionHandler: {
            (data, response, error) -> Void in
            if (error != nil) {
                completion("Err \(String(describing: error))")
                return
            } else {
                guard let data  = data else {
                    completion("no response")
                    return
                }
                do {
                    sleep(1)
                    print(String(decoding: data, as: UTF8.self))
                    completion(String(decoding: data, as: UTF8.self))
                }
            }
        })
        
        dataTask.resume()
    }
    
    public func playPauseSong(verb: String, bearerToken: String, completion:
                                @escaping (String) -> Void) {
        
        let req = URLRequest.createPlayPauseRequest(verb: verb, bearerToken: bearerToken)
        let session = URLSession.shared
        let dataTask = session.dataTask(with: req, completionHandler: {
            (data, response, error) -> Void in
            if (error != nil) {
                completion("Err \(String(describing: error))")
                return
            } else {
                guard let data  = data else {
                    completion("no response")
                    return
                }
                do {
                    //print(String(decoding: data, as: UTF8.self))
                    completion(String(decoding: data, as: UTF8.self))
                }
            }
        })
        dataTask.resume()
    }
}

fileprivate extension URLRequest {
    static func createSpotifyRequest(bearerToken: String) -> URLRequest {
        let request = NSMutableURLRequest(url: NSURL(string: "https://api.spotify.com/v1/me")! as URL,cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = ["content-type": "application/x-www-form-urlencoded", "Authorization" : "Bearer \(bearerToken)"]
        
        return request as URLRequest
    }
    
    static func createGetCurrentSongRequest(bearerToken: String) -> URLRequest {
        let request = NSMutableURLRequest(url: NSURL(string: "https://api.spotify.com/v1/me/player/currently-playing?additional_types=track,episode")! as URL,cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = ["content-type": "application/x-www-form-urlencoded", "Authorization" : "Bearer \(bearerToken)"]
        
        return request as URLRequest
    }
    
    static func createChangeSongRequest(verb: String, bearerToken: String) -> URLRequest {
        let request = NSMutableURLRequest(url: NSURL(string: "https://api.spotify.com/v1/me/player/\(verb)")! as URL,cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = ["content-type": "application/x-www-form-urlencoded", "Authorization" : "Bearer \(bearerToken)"]
        return request as URLRequest
    }
    
    static func createPlayPauseRequest(verb: String, bearerToken: String) -> URLRequest {
        let request = NSMutableURLRequest(url: NSURL(string: "https://api.spotify.com/v1/me/player/\(verb)")! as URL,cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        request.httpMethod = "PUT"
        request.allHTTPHeaderFields = ["content-type": "application/x-www-form-urlencoded", "Authorization" : "Bearer \(bearerToken)"]
        return request as URLRequest
    }
}
