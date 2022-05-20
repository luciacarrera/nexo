//
//  customButton.swift
//  nexo_test
//
//  Created by Lucía on 5/16/22.
//

import Foundation
import SwiftUI

struct GradientBtn: ButtonStyle {
    
    let color1: Color
    let color2: Color
    

    func makeBody(configuration: Configuration) -> some View {
        
        ZStack{
            Capsule()
                .fill(LinearGradient(gradient: Gradient(colors: [color1, color2]), startPoint: .leading, endPoint: .trailing))
                .frame(width: 200, height: 40)
                //.shadow(color: color1, radius: 3, x: 0, y: 0)
                .opacity(configuration.isPressed ? 0.2 : 1 )
               
            configuration.label
                .foregroundColor(.white)
                .font(.title2)
            
        } // End ZStack
    }
}

// MARK: Scale Button Style
struct ScaleBtn: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.80 : 1)
    }
}

