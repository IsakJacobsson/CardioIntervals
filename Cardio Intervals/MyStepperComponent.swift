//
//  MyStepper.swift
//  Cardio Intervals
//
//  Created by Isak Jacobsson on 2024-05-04.
//

import SwiftUI

struct MyStepperComponent: View {
    @State private var elements = [element(number:1,color: .red), element(number:2,color: .green), element(number:3,color: .orange), element(number:4,color: .blue), element(number:5,color: .white), element(number:6,color: .yellow)]
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack {
                ForEach(elements, id: \.uuid) { element in
                    Text("\(element.number)")
                        .font(.largeTitle)
                        .background(element.color)
                        .containerRelativeFrame(.vertical, count: 1, spacing: 0)
                        .scrollTransition { content, phase in
                            content
                                .scaleEffect(x: phase.isIdentity ? 1.0 : 0.6, y: phase.isIdentity ? 1.0 : 0.6)
                        }
                }
            }
            .scrollTargetLayout()
        }
        .background(Color.seethrough)
        .contentMargins(100, for: .scrollContent)
        .scrollTargetBehavior(.viewAligned)
    }
    
    struct element {
        let uuid = UUID()
        var number: Int
        var color: Color
    }
}
