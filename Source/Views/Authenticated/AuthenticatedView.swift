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

struct AuthenticatedView: View {
    
    @ObservedObject private var model: AuthenticatedViewModel
    
    init(model: AuthenticatedViewModel) {
        self.model = model
    }
    
    var body: some View {
    
        let deviceWidth = UIScreen.main.bounds.size.width
        let refreshDisabled = !self.model.hasRefreshToken
        let signOutDisabled = !self.model.hasIdToken

        return VStack {
            
            if self.model.error != nil {
                ErrorView(model: ErrorViewModel(error: self.model.error!))
            }
           
            Text("subject")
                .labelStyle()
                .padding(.top, 20)
                .padding(.leading, 20)
                .frame(width: deviceWidth, alignment: .leading)
                
            Text(self.model.subject)
                .valueStyle()
                .padding(.leading, 20)
                .frame(width: deviceWidth, alignment: .leading)
            
            Text("access_token")
                .labelStyle()
                .padding(.top, 20)
                .padding(.leading, 20)
                .frame(width: deviceWidth, alignment: .leading)
            
            Text(self.model.accessToken)
                .valueStyle()
                .padding(.leading, 20)
                .frame(width: deviceWidth, alignment: .leading)

            Text("refresh_token")
                .labelStyle()
                .padding(.top, 20)
                .padding(.leading, 20)
                .frame(width: deviceWidth, alignment: .leading)

            Text(self.model.refreshToken)
                .valueStyle()
                .padding(.leading, 20)
                .frame(width: deviceWidth, alignment: .leading)
            
            Button(action: self.model.refreshAccessToken) {
               Text("refresh_access_token")
            }
            .padding(.top, 20)
            .padding(.leading, 20)
            .padding(.trailing, 20)
            .buttonStyle(CustomButtonStyle(disabled: refreshDisabled))
            .disabled(refreshDisabled)
            
            Button(action: self.model.startLogout) {
               Text("sign_out")
            }
            .padding(.top, 20)
            .padding(.leading, 20)
            .padding(.trailing, 20)
            .buttonStyle(CustomButtonStyle(disabled: signOutDisabled))
            .disabled(signOutDisabled)
            
            Spacer()
        }
        .onAppear(perform: self.onViewCreated)
    }
    
    func onViewCreated() {
        self.model.processTokens()
    }
        
    func getViewController() -> UIViewController {
        return UIApplication.shared.windows.first!.rootViewController!
    }
}
