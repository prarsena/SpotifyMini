import Foundation
import AuthenticationServices
import CommonCrypto


func generateRandomString(length: Int) -> String{
    let possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
    return String((0..<length).map{ _ in possible.randomElement()! })
}

public enum OAuth2AuthenticatorError: LocalizedError {
    case authRequestFailed(Error)
    case authorizeResponseNoUrl
    case authorizeResponseNoCode
    case tokenRequestFailed(Error)
    case tokenResponseNoData
    case tokenResponseInvalidData(String)

    var localizedDescription: String {
        switch self {
        case .authRequestFailed(let error):
            return "authorization request failed: \(error.localizedDescription)"
        case .authorizeResponseNoUrl:
            return "authorization response does not include a url"
        case .authorizeResponseNoCode:
            return "authorization response does not include a code"
        case .tokenRequestFailed(let error):
            return "token request failed: \(error.localizedDescription)"
        case .tokenResponseNoData:
            return "no data received as part of token response"
        case .tokenResponseInvalidData(let reason):
            return "invalid data received as part of token response: \(reason)"
        }
    }
}

public struct AccessTokenResponse: Codable {
    public var access_token: String
    public var refresh_token: String
    public var expires_in: Int
}

public struct RefreshToken: Codable {
    public var access_token: String
    public var token_type: String
    public var expires_in: Int
    public var scope: String
}

let creds = SecretCredentials()
public class OAuthAuthenticator: NSObject {
    
    let stateKey = "spotify_auth_state"
    
    let client_id = creds.client_id
    let client_secret = creds.client_secret;
    var redirect_uri = "spotifymini://callback";
    var callback_scheme = "spotifymini://"
    var state = generateRandomString(length: 16);
    
    public func authenticate(completion: @escaping (Result<AccessTokenResponse, OAuth2AuthenticatorError>) -> Void) {
        let authString = "\(client_id):\(client_secret)"
        let authData = authString.data(using: .utf8)
        let base64EncodedString = authData!.base64EncodedString()
        print(base64EncodedString)
        
        let authenticationSession = ASWebAuthenticationSession(
            url: URL(string: "https://accounts.spotify.com/authorize?response_type=code&client_id=\(client_id)&scope=user-read-private%20user-read-email%20user-read-currently-playing%20user-modify-playback-state&redirect_uri=\(redirect_uri)&state=\(state)")!,
            callbackURLScheme: callback_scheme) { [self] optionalUrl, optionalError in
                // authorization server stores the code_challenge and redirects the user back to the application with an authorization code, which is good for one use
                guard optionalError == nil else { completion(.failure(.authRequestFailed(optionalError!))); return }
                guard let url = optionalUrl else { completion(.failure(.authorizeResponseNoUrl)); return }
                guard let code = url.getQueryStringParameter("code") else { completion(.failure(.authorizeResponseNoCode)); return }
                print(code)
                // 4. sends this code and the code_verifier (created in step 2) to the authorization server (token endpoint)
                self.getAccessToken(basicAuthCode: base64EncodedString, code: code, redirect_uri: redirect_uri, completion: completion)
            }
        authenticationSession.presentationContextProvider = self
        authenticationSession.start()

    }
    
    public func getAccessToken(basicAuthCode: String, code: String, redirect_uri: String, completion: @escaping (Result<AccessTokenResponse, OAuth2AuthenticatorError>) -> Void) {
        print("im finna request a token)")
        
        let request = URLRequest.createTokenRequest(
            basicAuthHeader: basicAuthCode,
            code: code,
            redirectUri: redirect_uri)

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                completion(.failure(OAuth2AuthenticatorError.tokenRequestFailed(error!)))
                return
            } else {
                guard let data  = data else {
                    completion(.failure(OAuth2AuthenticatorError.tokenResponseNoData))
                    return
                }
                do {
                    //print(String(decoding: data, as: UTF8.self) )
                    let tokenResponse = try JSONDecoder().decode(AccessTokenResponse.self, from: data)
                    //let refreshResponse = try JSONDecoder().decode(, from: data)
                    //print(tokenResponse)
                    completion(.success(tokenResponse))
                } catch {
                    let reason = String(data: data, encoding: .utf8) ?? "Unknown"
                    completion(.failure(OAuth2AuthenticatorError.tokenResponseInvalidData(reason)))
                }
            }
        })
        dataTask.resume()
    }
    
    public func getRefreshToken(basicAuthHeader: String, refresh_token: String, completion: @escaping (String) -> Void ) {
        let req = URLRequest.createRefreshTokenRequest(basicAuthHeader: basicAuthHeader, refresh_token: refresh_token)
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

    
    
    private func getQueryStringParameter(url: String, param: String) -> String? {
        guard let url = URLComponents(string: url) else { return nil }
        return url.queryItems?.first(where: { $0.name == param })?.value
    }
}

extension OAuthAuthenticator: ASWebAuthenticationPresentationContextProviding {
    public func presentationAnchor(for session: ASWebAuthenticationSession)
    -> ASPresentationAnchor {
        let window = NSApplication.shared.windows.first { $0.isKeyWindow }
        return window ?? ASPresentationAnchor()
    }
}


fileprivate extension URL {
    func getQueryStringParameter(_ parameter: String) -> String? {
        guard let url = URLComponents(string: self.absoluteString) else { return nil }
        return url.queryItems?.first(where: { $0.name == parameter })?.value
    }
}

fileprivate extension URLRequest {
    static func createTokenRequest(basicAuthHeader: String, code: String, redirectUri: String) -> URLRequest {
        let request = NSMutableURLRequest(url: NSURL(string: "https://accounts.spotify.com/api/token")! as URL,cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = ["content-type": "application/x-www-form-urlencoded", "Authorization" : "Basic \(basicAuthHeader)"]
        
        request.httpBody = NSMutableData(data: "grant_type=authorization_code&code=\(code)&redirect_uri=\(redirectUri)".data(using: String.Encoding.utf8)!) as Data
        return request as URLRequest
    }
    
    static func createRefreshTokenRequest(basicAuthHeader: String, refresh_token: String) -> URLRequest {
        let request = NSMutableURLRequest(url: NSURL(string: "https://accounts.spotify.com/api/token")! as URL,cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = ["content-type": "application/x-www-form-urlencoded", "Authorization" : "Basic \(basicAuthHeader)"]
        
        request.httpBody = NSMutableData(data: "grant_type=refresh_token&refresh_token=\(refresh_token)".data(using: String.Encoding.utf8)!) as Data
        return request as URLRequest
    }
}

func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
    URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
}
