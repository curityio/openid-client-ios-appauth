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

struct ErrorView: View {

    @ObservedObject private var model: ErrorViewModel
    
    init(model: ErrorViewModel) {
        self.model = model
    }
    
    var body: some View {
    
        return VStack {
            
            Text(self.model.title)
                .labelStyle()
                .padding(.top, 20)
                .padding(.leading, 20)

            Text(self.model.description)
                .errorValueStyle()
                .padding(.leading, 20)
                .padding(.trailing, 20)
        }
    }
}
