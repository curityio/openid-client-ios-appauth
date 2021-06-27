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

class AuthenticatedViewModel: ObservableObject {
    
    var events: AuthenticatedViewEvents?
    private var appauth: AppAuthHandler?
    private var onLoggedOut: (() -> Void)?

    @Published var hasRefreshToken: Bool
    @Published var subject: String
    @Published var accessToken: String
    @Published var refreshToken: String
    @Published var error: ApplicationError?
    
    init(appauth: AppAuthHandler, onLoggedOut: @escaping () -> Void) {

        self.appauth = appauth
        self.onLoggedOut = onLoggedOut
        self.events = nil
        
        self.hasRefreshToken = false
        self.subject = ""
        self.accessToken = ""
        self.refreshToken = ""
        self.error = nil
    }
    
    /*
     * Show token information after login
     */
    func processTokens() {

        self.subject = "demouser"
        
        if ApplicationStateManager.tokenResponse?.accessToken != nil {
            self.accessToken = ApplicationStateManager.tokenResponse!.accessToken!
        }

        if ApplicationStateManager.tokenResponse?.refreshToken != nil {
            self.hasRefreshToken = true
            self.refreshToken = ApplicationStateManager.tokenResponse!.refreshToken!
        }
    }

    /*
     * Perform a refresh token grant message
     */
    func refreshAccessToken() {
        
        DispatchQueue.main.startCoroutine {

            do {

                try DispatchQueue.global().await {

                    ApplicationStateManager.tokenResponse = try self.appauth!.refreshAccessToken(
                        refreshToken: ApplicationStateManager.tokenResponse!.refreshToken!,
                        metadata: ApplicationStateManager.metadata!,
                        registrationResponse: ApplicationStateManager.registrationResponse!).await()
                    
                    self.processTokens()
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

        /*DispatchQueue.main.startCoroutine {

            do {

                self.error = nil
                let authResponse = try self.appauth!.performAuthorizationRedirect(
                    metadata: ApplicationStateManager.metadata!,
                    registrationResponse: ApplicationStateManager.registrationResponse!,
                    viewController: self.events!.getViewController()
                ).await()

            } catch {
                
                let appError = error as? ApplicationError
                if appError != nil {
                    self.error = appError!
                }
            }
        }*/
    }
}

