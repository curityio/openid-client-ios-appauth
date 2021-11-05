//
// Copyright (C) 2021 Curity AB.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation
import SwiftCoroutine
import AppAuth
import SwiftJWT

class AuthenticatedViewModel: ObservableObject {

    private let config: ApplicationConfig
    private let state: ApplicationStateManager
    private let appauth: AppAuthHandler
    private let onLoggedOut: (() -> Void)

    @Published var hasRefreshToken: Bool
    @Published var hasIdToken: Bool
    @Published var subject: String
    @Published var accessToken: String
    @Published var refreshToken: String
    @Published var error: ApplicationError?
    
    struct IDTokenClaims: Claims {
        var sub: String
    }
    
    init(
        config: ApplicationConfig,
        state: ApplicationStateManager,
        appauth: AppAuthHandler,
        onLoggedOut: @escaping () -> Void) {

        self.config = config
        self.state = state
        self.appauth = appauth
        self.onLoggedOut = onLoggedOut
        self.hasRefreshToken = false
        self.hasIdToken = false
        self.subject = ""
        self.accessToken = ""
        self.refreshToken = ""
        self.error = nil
    }

    /*
     * Show token information after login
     */
    func processTokens() {

        if self.state.tokenResponse?.accessToken != nil {
            self.accessToken = self.state.tokenResponse!.accessToken!
        }

        if self.state.tokenResponse?.refreshToken != nil {
            self.hasRefreshToken = true
            self.refreshToken = self.state.tokenResponse!.refreshToken!
        }
        
        if self.state.idToken != nil {
            
            let idToken = self.state.idToken!
            self.hasIdToken = true
            
            do {

                let jwt = try JWT<IDTokenClaims>(jwtString: idToken)
                self.subject = jwt.claims.sub

            } catch {
                
                let appError = ApplicationError(title: "Failed to parse ID Token", description: error.localizedDescription)
                Logger.error(data: appError.description)
                self.error = appError
            }
        }
    }

    /*
     * Perform a refresh token grant message
     */
    func refreshAccessToken() {
        
        DispatchQueue.main.startCoroutine {

            do {

                let metadata = self.state.metadata!
                let refreshToken = self.state.tokenResponse!.refreshToken!
                var tokenResponse: OIDTokenResponse? = nil
                self.error = nil

                try DispatchQueue.global().await {

                    tokenResponse = try self.appauth.refreshAccessToken(
                        metadata: metadata,
                        clientID: self.config.clientID,
                        refreshToken: refreshToken).await()
                }
                
                if tokenResponse != nil {
                    self.state.saveTokens(tokenResponse: tokenResponse!)
                    self.processTokens()
                    
                } else {
                    self.state.clearTokens()
                    self.onLoggedOut()
                }
                

            } catch {
                
                let appError = error as? ApplicationError
                if appError != nil {
                    self.error = appError!
                }
            }
        }
    }
    
    /*
     * Run the end session redirect and handle the response
     */
    func startLogout() {

        DispatchQueue.main.startCoroutine {

            do {

                self.error = nil

                try self.appauth.performEndSessionRedirect(
                    metadata: self.state.metadata!,
                    idToken: self.state.idToken!,
                    viewController: self.getViewController()
                ).await()

                self.state.clearTokens()
                self.onLoggedOut()

            } catch {
                
                let appError = error as? ApplicationError
                if appError != nil {
                    self.error = appError!
                }
            }
        }
    }
    
    private func getViewController() -> UIViewController {
        return UIApplication.shared.windows.first!.rootViewController!
    }
}
