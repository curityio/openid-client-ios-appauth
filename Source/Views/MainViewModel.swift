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

class MainViewModel: ObservableObject {
    
    private let config: ApplicationConfig
    private let state: ApplicationStateManager
    private let appauth: AppAuthHandler
    private var unauthenticatedModel: UnauthenticatedViewModel?
    private var authenticatedModel: AuthenticatedViewModel?

    @Published var isAuthenticated = false
    
    init(config: ApplicationConfig, state: ApplicationStateManager, appauth: AppAuthHandler) {
        
        // Create globals
        self.config = try! ApplicationConfigLoader.load()
        self.state = ApplicationStateManager()
        self.appauth = AppAuthHandler(config: self.config)
        
        // These are created on first use
        self.unauthenticatedModel = nil
        self.authenticatedModel = nil
    }
    
    /*
     * Create on first use because Swift does not like passing the callback from the init function
     */
    func getUnauthenticatedViewModel() -> UnauthenticatedViewModel {
        
        if self.unauthenticatedModel == nil {
            self.unauthenticatedModel = UnauthenticatedViewModel(
                config: self.config,
                state: self.state,
                appauth: self.appauth,
                onLoggedIn: self.onLoggedIn)
        }
    
        return self.unauthenticatedModel!
    }
    
    /*
     * Create on first use because Swift does not like passing the callback from the init function
     */
    func getAuthenticatedViewModel() -> AuthenticatedViewModel {
        
        if self.authenticatedModel == nil {
            self.authenticatedModel = AuthenticatedViewModel(
                config: self.config,
                state: self.state,
                appauth: self.appauth,
                onLoggedOut: self.onLoggedOut)
        }
    
        return self.authenticatedModel!
    }
    
    func onLoggedIn() {
        self.isAuthenticated = true
    }

    func onLoggedOut() {
        self.isAuthenticated = false
    }
}
