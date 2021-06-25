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
    
    var body: some View {
    
        return VStack {
            
            Text("Curity AppAuth Demo App")
                .fontWeight(.bold)
                .padding(.top, 20)
                .font(.system(size: 28))
                .frame(alignment: .leading)
                .padding(.leading, 20)
    
            Text("Welcome to the SwiftUI AppAuth demo")
                .padding(.top, 20)
                .font(.system(size: 20))
                .frame(alignment: .leading)
                .padding(.leading, 20)
            
            Image("StartIllustration")
                .aspectRatio(contentMode: .fit)
                .padding(.top, 20)
            
            Button(action: self.onStartAuthentication) {
               Text("Start Authentication")
            }
            .padding(.top, 20)
            .padding(.leading, 20)
            .padding(.trailing, 20)
            .buttonStyle(CustomButtonStyle(disabled: false))
            
            Spacer()
        }
    }
        
    func onStartAuthentication() {
        print("*** YAY START AUTH")
    }
}
