//
//  ControlView.swift
//  nexo-cam
//
//  Created by Lucía on 5/16/22.
//


import SwiftUI

struct CameraControlView: View {
  @Binding var comicSelected: Bool
  @Binding var monoSelected: Bool
  @Binding var crystalSelected: Bool

  var body: some View {
    VStack {
      Spacer()

      HStack(spacing: 12) {
        ToggleButton(selected: $comicSelected, label: "Comic")
        ToggleButton(selected: $monoSelected, label: "Mono")
        ToggleButton(selected: $crystalSelected, label: "Crystal")
      }
    }
  }
}

struct ControlView_Previews: PreviewProvider {
  static var previews: some View {
    ZStack {
      Color.black
        .edgesIgnoringSafeArea(.all)

      CameraControlView(
        comicSelected: .constant(false),
        monoSelected: .constant(true),
        crystalSelected: .constant(true))
    }
  }
}
