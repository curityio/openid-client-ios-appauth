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

    private var appauth: AppAuthHandler?
    private var onLoggedIn: (() -> Void)?

    @Published var error: ApplicationError?
    @Published var isRegistered: Bool
    
    init(appauth: AppAuthHandler, onLoggedIn: @escaping () -> Void) {

        self.appauth = appauth
        self.onLoggedIn = onLoggedIn
        self.error = nil
        self.isRegistered = false
    }
    
    /*
     * Startup handling to lookup metadata and do the dynamic client registration if required
     * Make HTTP requests on a worker thread and then perform updates on the UI thread
     */
    func registerIfRequired() {
        
        DispatchQueue.main.startCoroutine {
            
            do {

                self.error = nil
                var metadata = ApplicationStateManager.metadata
                var registrationResponse = ApplicationStateManager.registrationResponse

                try DispatchQueue.global().await {
                    
                    if metadata == nil {
                        metadata = try self.appauth!.fetchMetadata().await()
                    }
                    
                    if registrationResponse == nil {
                        registrationResponse = try self.appauth!.registerClient(metadata: metadata!).await()
                    }
                }
                
                ApplicationStateManager.metadata = metadata
                ApplicationStateManager.registrationResponse = registrationResponse
                self.isRegistered = true
                
            } catch {
                
                let appError = error as? ApplicationError
                if appError != nil {
                    self.error = appError!
                }
            }
        }
    }
    
    /*
     * Run the authorization redirect on the UI thread, then redeem the code for tokens on a background thread
     */
    func startLogin() {

        DispatchQueue.main.startCoroutine {

            do {
                
                let metadata = ApplicationStateManager.metadata!
                let registrationResponse = ApplicationStateManager.registrationResponse!
                self.error = nil

                let authorizationResponse = try self.appauth!.performAuthorizationRedirect(
                    metadata: metadata,
                    registrationResponse: registrationResponse,
                    viewController: self.getViewController()
                ).await()

                if authorizationResponse != nil {
                    
                    var tokenResponse: OIDTokenResponse? = nil
                    try DispatchQueue.global().await {
                        
                        tokenResponse = try self.appauth!.redeemCodeForTokens(
                            registrationResponse: registrationResponse,
                            authResponse: authorizationResponse!
                            
                        ).await()
                    }
                    
                    ApplicationStateManager.tokenResponse = tokenResponse
                    ApplicationStateManager.idToken = tokenResponse?.idToken
                    self.onLoggedIn!()
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
