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

struct UnauthenticatedView: View {
    
    @ObservedObject private var model: UnauthenticatedViewModel
    
    init(model: UnauthenticatedViewModel) {
        self.model = model
    }
    
    var body: some View {
    
        let authenticationDisabled = !self.model.isRegistered
        return VStack {
            
            if self.model.error != nil {
                ErrorView(model: ErrorViewModel(error: self.model.error!))
            }
            
            Text("welcome_message")
                .labelStyle()
                .padding(.top, 20)
            
            Image("StartIllustration")
                .aspectRatio(contentMode: .fit)
                .padding(.top, 20)
            
            Button(action: self.model.startLogin) {
               Text("start_authentication")
            }
            .padding(.top, 20)
            .padding(.leading, 20)
            .padding(.trailing, 20)
            .buttonStyle(CustomButtonStyle(disabled: authenticationDisabled))
            .disabled(authenticationDisabled)
            
            Spacer()
        }
        .onAppear(perform: self.onViewCreated)
    }
    
    func onViewCreated() {
        self.model.registerIfRequired()
    }
}
