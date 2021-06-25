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

class UnauthenticatedViewModel: ObservableObject {
    
    private let appauth: AppAuthHandler
    @Published var error: ApplicationError?
    @Published var isRegistered: Bool

    init(appauth: AppAuthHandler) {
        
        self.appauth = appauth
        self.error = nil
        self.isRegistered = false
    }
    
    func registerIfRequired() {
        
        DispatchQueue.main.startCoroutine {
            
            do {

                self.error = nil
                try DispatchQueue.global().await {
                    
                    ApplicationStateManager.metadata = try self.appauth.fetchMetadata().await()
                    ApplicationStateManager.registrationResponse = try self.appauth.registerClient(metadata: ApplicationStateManager.metadata!).await()
                }
                
                self.isRegistered = true
                
            } catch {
                
                let appError = error as? ApplicationError
                if appError != nil {
                    self.error = appError!
                }
            }
        }
    }
}
