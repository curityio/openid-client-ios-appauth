//
// Copyright (C) 2023 Curity AB.
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

/*
 * An async helper so that waiting for an AppAuth response plays nicely with Swift async handling
 */
class LoginResponseHandler {

    var storedContinuation: CheckedContinuation<OIDAuthorizationResponse?, Error>?

    /*
     * Set a continuation and await
     */
    func waitForCallback() async throws -> OIDAuthorizationResponse? {
        
        try await withCheckedThrowingContinuation { continuation in
            storedContinuation = continuation
        }
    }

    /*
     * On Completion, this is called by AppAuth libraries on the UI thread, and code resumes
     */
    func callback(response: OIDAuthorizationResponse?, ex: Error?) {
        
        if ex != nil {
            storedContinuation?.resume(throwing: ex!)
        } else {
            storedContinuation?.resume(returning: response)
        }
    }
}

