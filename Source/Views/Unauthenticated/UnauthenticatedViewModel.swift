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
        
        Task {
            
            do {
                
                // Get metadata
                let metadata = try await self.appauth.fetchMetadata()
                
                // Initiate the redirect on the UI thread
                try await MainActor.run {
                    
                    self.error = nil
                    try self.appauth.performAuthorizationRedirect(
                        metadata: metadata,
                        clientID: self.config.clientID,
                        viewController: self.getViewController()
                    )
                }
                
                // Wait for the response
                let authorizationResponse = try await self.appauth.handleAuthorizationResponse()
                if authorizationResponse != nil {
                    
                    // Redeem the code for tokens
                    let tokenResponse = try await self.appauth.redeemCodeForTokens(
                        clientID: self.config.clientID,
                        authResponse: authorizationResponse!)
                    
                    // Update application state on the UI thread, then move the app to the authenticated view
                    await MainActor.run {
                        self.state.metadata = metadata
                        self.state.saveTokens(tokenResponse: tokenResponse)
                        self.onLoggedIn()
                    }
                }
                
            } catch {
                
                // Handle errors on the UI thread
                await MainActor.run {
                    let appError = error as? ApplicationError
                    if appError != nil {
                        self.error = appError!
                    }
                }
            }
        }
    }
    
    private func getViewController() -> UIViewController {
        let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        return scene!.keyWindow!.rootViewController!
        
    }
}
