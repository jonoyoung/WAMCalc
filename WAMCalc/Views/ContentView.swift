//
//  ContentView.swift
//  WAMCalc
//
//  Created by Jono on 15/6/20.
//  Copyright © 2020 JYoung. All rights reserved.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) var context
    
    // Request to fetch all subjects from Core Data.
    @FetchRequest(
        entity: Subject.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Subject.name, ascending: true)]
    )
    var subjects: FetchedResults<Subject>
    
    // State to show or hide the add subject modal.
    @State private var showAddSubjectModal: Bool = false
    
    // Our WAM value that was calculated previously.
    @State private var wam: String = UserDefaults.standard.string(forKey: "wam") ?? "0"
    @State private var grade: String = UserDefaults.standard.string(forKey: "grade") ?? "None"
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("WAM Calculator")
                    .font(.title)
            
                Spacer()
                
                Button(action: { self.showAddSubjectModal.toggle() }) {
                    Image(systemName: "plus")
                }
            }
            .padding(20)
            
            VStack(alignment: .leading) {
                Text("Your WAM: \(wam)")
                Text("Grade: \(grade)")
            }
            .padding(20)
            
            List {
                ForEach(subjects) { subject in
                    Text("\(subject.name!)")
                }
                .onDelete(perform: self.removeSubject)
            }
            .padding(.bottom, 20)
        }
        .onAppear { self.calculateWam() }
        .sheet(isPresented: self.$showAddSubjectModal, onDismiss: { self.calculateWam() }) {
            AddSubjectView(showModal: self.$showAddSubjectModal).environment(\.managedObjectContext, self.context)
        }
    }
    
    // Return the grade based on the WAM given.
    func getGrade(wam: Double) -> String {
        if (wam >= 0 && wam <= 49) {
            return "Fail"
        } else if (wam >= 50 && wam <= 64) {
            return "Pass"
        } else if (wam >= 65 && wam <= 74) {
            return "Credit"
        } else if (wam >= 75 && wam <= 84) {
            return "Distinction"
        } else if (wam >= 85 && wam <= 100) {
            return "High Distinction"
        } else {
            return "None"
        }
    }
    
    // Algorithm to calculate the WAM of all subjects.
    func calculateWam() {
        // If there are no subjects then we need to set these values to 0.
        if (self.subjects.count == 0){
            self.wam = "0"
            UserDefaults.standard.set("0", forKey: "wam")
            return
        }
        
        var markSum: Double = 0.0
        var creditSum: Double = 0.0
        var wam: Double = 0.0
        var grade: String = ""
        
        for subject in self.subjects {
            markSum += (subject.finalMark * subject.creditPoints)
            creditSum += subject.creditPoints
        }
        
        wam = markSum / creditSum
        grade = self.getGrade(wam: wam)
        self.grade = grade
        self.wam = String(format: "%.0f", wam)
        
        UserDefaults.standard.set(self.wam, forKey: "wam")
        UserDefaults.standard.set(self.grade, forKey: "grade")
    }
    
    // Delete subject from Core Data.
    func removeSubject(at offsets: IndexSet) {
        for index in offsets {
            let subject = subjects[index]
            context.delete(subject)
        }
        
        do {
            try context.save()
        } catch {
            print(error)
        }
        
        // Recalculate the WAM value after deletion.
        self.calculateWam()
    }
}
