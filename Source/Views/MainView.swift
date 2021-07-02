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

import SwiftUI

struct MainView: View {

    @ObservedObject private var model: MainViewModel
    private let unauthenticatedModel: UnauthenticatedViewModel
    private let authenticatedModel: AuthenticatedViewModel

    init(model: MainViewModel) {

        self.model = model
        self.unauthenticatedModel = UnauthenticatedViewModel(appauth: model.appauth, onLoggedIn: model.onLoggedIn)
        self.authenticatedModel = AuthenticatedViewModel(appauth: model.appauth, onLoggedOut: model.onLoggedOut)
    }
    
    var body: some View {
        
        return VStack {
        
            Text("main_title")
                .headingStyle()
                .padding(.top, 20)
                .padding(.leading, 20)
            
            if (!self.model.isAuthenticated) {
                UnauthenticatedView(model: self.unauthenticatedModel)
            } else {
                AuthenticatedView(model: self.authenticatedModel)
            }
        }
        .onAppear(perform: ApplicationStateManager.load)
        .onDisappear(perform: ApplicationStateManager.save)
    }
}
