//
//  UserDataEditView.swift
//  WeightTracker
//
//  Created by James Maguire on 24/09/2022.
//

import SwiftUI

struct UserDataEditView: View {
    @Binding var dataStore: DataStore
    @State var wasRecorded = false
    let saveAction: ()->Void
    
    var body: some View {
        Form {
            Section(header: Text("User Data")) {
                DatePicker("D.O.B", selection: $dataStore.userData.dob, displayedComponents: [.date])
                Picker("Gender", selection: $dataStore.userData.gender) {
                    ForEach(Gender.allCases) { gender in
                        Text(gender.rawValue)
                            .tag(gender)
                    }
                }
                HStack {
                    Slider(value: $dataStore.userData.height, in: 150...210, step: 1) {
                        Text("Height")
                    }
                    .accessibilityValue("\(Int(dataStore.userData.height)) cm")
                    Spacer()
                    Text("\(Int(dataStore.userData.height)) cm")
                        .accessibilityHidden(true)
                }
            }
        }
    }
}

struct UserDataEditView_Previews: PreviewProvider {
    static var previews: some View {
        UserDataEditView(dataStore: .constant(DataStore.sampleData), saveAction: {})
    }
}
