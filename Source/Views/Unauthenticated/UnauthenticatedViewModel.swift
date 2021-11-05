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

class UnauthenticatedViewModel: ObservableObject {

    private let config: ApplicationConfig
    private let state: ApplicationStateManager
    private let appauth: AppAuthHandler
    private let onLoggedIn: () -> Void

    @Published var error: ApplicationError?
    
    init(
        config: ApplicationConfig,
        state: ApplicationStateManager,
        appauth: AppAuthHandler,
        onLoggedIn: @escaping () -> Void) {

        self.config = config
        self.state = state
        self.appauth = appauth
        self.onLoggedIn = onLoggedIn
        self.error = nil
    }
    
    /*
     * Run front channel operations on the UI thread and back channel operations on a background thread
     */
    func startLogin() {

        DispatchQueue.main.startCoroutine {

            do {

                // Get metadata if required
                var metadata: OIDServiceConfiguration? = nil
                if metadata == nil {
                    try DispatchQueue.global().await {
                        metadata = try self.appauth.fetchMetadata().await()
                    }
                }

                // Then redirect on the UI thread
                self.error = nil
                let authorizationResponse = try self.appauth.performAuthorizationRedirect(
                    metadata: metadata!,
                    clientID: self.config.clientID,
                    viewController: self.getViewController()
                ).await()

                if authorizationResponse != nil {

                    // Redeem the code for tokens
                    var tokenResponse: OIDTokenResponse? = nil
                    try DispatchQueue.global().await {
                        
                        tokenResponse = try self.appauth.redeemCodeForTokens(
                            clientID: self.config.clientID,
                            authResponse: authorizationResponse!
                            
                        ).await()
                    }

                    // Update application state, then move the app to the authenticated view
                    self.state.metadata = metadata
                    self.state.saveTokens(tokenResponse: tokenResponse!)
                    self.onLoggedIn()
                }

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
