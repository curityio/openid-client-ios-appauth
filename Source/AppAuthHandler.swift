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
    
    var counter = 1;
    
    func fetchMetadata() throws -> CoFuture<Void> {
        
        let promise = CoPromise<Void>()

        /*OIDAuthorizationService.discoverConfiguration(
            forIssuer: issuerUrl) { metadata, error in

                self.metadata = metadata
                if error != nil {
                    promise.fail(ErrorHandler.fromException(error: error!))
                } else {
                    promise.success(Void())
                }
        }*/
        
        if (counter == 0) {
            throw ApplicationError(area: "whatevar")
        }
        
        promise.success(Void())
        return promise
    }
}
