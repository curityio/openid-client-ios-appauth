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
import SwiftCoroutine

class AppAuthHandler {
    
    func fetchMetadata(issuer: String) throws -> CoFuture<OIDServiceConfiguration> {
        
        let promise = CoPromise<OIDServiceConfiguration>()
        
        guard let issuerUrl = URL(string: issuer) else {

            let error = ApplicationError(title: "Invalid Configuration Error", description: "The issuer URL could not be parsed")
            promise.fail(error)
            return promise
        }

        OIDAuthorizationService.discoverConfiguration(forIssuer: issuerUrl) { metadata, ex in

                if metadata != nil {

                    Logger.info(data: "Discovery document retrieved successfully")
                    Logger.debug(data: metadata.debugDescription)
                    promise.success(metadata!)

                } else {

                    let error = self.createAuthorizationError(title: "Metadata Download Error", ex: ex)
                    promise.fail(error)
                }
        }
        
        return promise
    }
    
    private func createAuthorizationError(title: String, ex: Error?) -> ApplicationError {
        
        var parts = [String]()
        if (ex == nil) {

            parts.append("Unknown Error")

        } else {
        
            let nsError = ex! as NSError
            
            if nsError.domain.contains("org.openid.appauth") {
                parts.append("(\(nsError.domain) / \(String(nsError.code)))")
            }
            
            if !ex!.localizedDescription.isEmpty {
                parts.append(ex!.localizedDescription)
            }
        }
        
        let fullDescription = parts.joined(separator: " : ")
        let error = ApplicationError(title: title, description: fullDescription)
        Logger.error(data: "\(error.title) : \(error.description)")
        return error
    }
}
