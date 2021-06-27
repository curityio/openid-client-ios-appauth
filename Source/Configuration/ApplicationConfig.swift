//
//  ApplicationConfig.swift
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

struct ApplicationConfig {

    private let issuer = "https://5c300a76b17a.eu.ngrok.io/oauth/v2/oauth-anonymous"
    private let redirectUri = "io.curity.client:/callback"
    let postLogoutRedirectUri = "io.curity.client:/logoutcallback"
    let scope = "openid profile"
    
    func getIssuerUri() -> (URL?, Error?) {
        
        guard let url = URL(string: self.issuer) else {

            let error = ApplicationError(title: "Invalid Configuration Error", description: "The issuer URI could not be parsed")
            return (nil, error)
        }
        
        return (url, nil)
    }

    func getRedirectUri() -> (URL?, Error?) {
        
        guard let url = URL(string: self.redirectUri) else {

            let error = ApplicationError(title: "Invalid Configuration Error", description: "The redirect URI could not be parsed")
            return (nil, error)
        }
        
        return (url, nil)
    }
    
    func getPostLogoutRedirectUri() -> (URL?, Error?) {
        
        guard let url = URL(string: self.postLogoutRedirectUri) else {

            let error = ApplicationError(title: "Invalid Configuration Error", description: "The post logout redirect URI could not be parsed")
            return (nil, error)
        }
        
        return (url, nil)
    }
}
