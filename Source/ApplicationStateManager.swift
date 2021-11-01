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

import AppAuth
import SwiftKeychainWrapper

class ApplicationStateManager {
    
    private var authState: OIDAuthState
    private var metadataValue: OIDServiceConfiguration? = nil
    var idToken: String? = nil
    private var storageKey = "io.curity.client"

    /*
     * Initialize the app's state when it starts
     */
    init() {
        self.authState = OIDAuthState(authorizationResponse: nil, tokenResponse: nil, registrationResponse: nil)
    }

    /*
     * Store tokens in memory
     */
    func saveTokens(tokenResponse: OIDTokenResponse) {
        
        // When refreshing tokens, the Curity Identity Server does not issue a new ID token
        // The AppAuth code does not allow us to update the token response with the original ID token
        // Therefore we store the ID token separately
        if (tokenResponse.idToken != nil) {
            self.idToken = tokenResponse.idToken
        }
    
        self.authState.update(with: tokenResponse, error: nil)
    }
    
    /*
     * Clear tokens upon logout or when the session expires
     */
    func clearTokens() {
        self.authState = OIDAuthState(authorizationResponse: nil, tokenResponse: nil, registrationResponse: nil)
        self.idToken = nil
        
        // KeychainWrapper.standard.removeObject(forKey: self.storageKey + ".token")
    }
    
    var metadata: OIDServiceConfiguration? {
        get {
            return self.metadataValue
        }
        set(value) {
            self.metadataValue = value
        }
    }
    
    var tokenResponse: OIDTokenResponse? {
        get {
            return self.authState.lastTokenResponse
        }
    }
}
