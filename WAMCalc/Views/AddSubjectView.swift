//
//  AddSubjectView.swift
//  WAMCalc
//
//  Created by Jono on 15/6/20.
//  Copyright © 2020 JYoung. All rights reserved.
//

import SwiftUI
import CoreData

struct AddSubjectView: View {
    @Environment(\.managedObjectContext) var context
    
    // Binding that shows or hides this modal.
    @Binding var showModal: Bool
    
    // Alert variables.
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = "Please enter a subject name."
    
    // Our state variables to hold the values of the text fields.
    @State private var subjectName: String = ""
    @State private var subjectCreditPoints: Int = 6
    @State private var subjectFinalMark: Int = 50
    
    var body: some View {
        NavigationView {
            VStack {
                // Cancel button. (Used to support landscape orientation.)
                HStack {
                    Button(action: { self.showModal = false }) {
                        Text("Cancel")
                    }
                    
                    Spacer()
                    
                    Button(action: { self.addSubject() }) {
                        Text("Submit")
                    }
                    .alert(isPresented: self.$showAlert) {
                        Alert(title: Text("Couldn't Submit"), message: Text(self.alertMessage), dismissButton: .default(Text("OK")))
                    }
                }
                .padding(.horizontal, 20)
                
                Form {
                    Section(header: Text("Information")) {
                        TextField("Subject Name", text: self.$subjectName)
                    }

                    Section(header: Text("Credit Points")) {
                        Picker("", selection: self.$subjectCreditPoints) {
                            ForEach(0 ..< 33) {
                                Text("\($0)")
                            }
                        }
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .pickerStyle(WheelPickerStyle())
                        .labelsHidden()
                    }

                    Section(header: Text("Final Mark")) {
                        Picker("", selection: self.$subjectFinalMark) {
                            ForEach(0 ..< 101) {
                                Text("\($0)")
                            }
                        }
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .pickerStyle(WheelPickerStyle())
                        .labelsHidden()
                    }
                }
            }
            .navigationBarTitle("Add Subject")
        }
    }
    
    // Function that handles adding the subject to Core Data.
    func addSubject() {
        let newSubject = Subject(context: context)
        newSubject.id = UUID()
        newSubject.name = self.subjectName
        newSubject.creditPoints = Double(self.subjectCreditPoints)
        newSubject.finalMark = Double(self.subjectFinalMark)

        do {
            try context.save()
            self.showModal = false // Hide the modal and return to ContentView.
        } catch {
            // Something bad happened. Print the error to the console.
            print(error)
        }
    }
}

struct AddSubjectView_Previews: PreviewProvider {
    static var previews: some View {
        AddSubjectView(showModal: .constant(true))
    }
}
