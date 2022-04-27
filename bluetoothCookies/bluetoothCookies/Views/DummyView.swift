//
//  SwiftUIView.swift
//  bluetoothCookies
//
//  Created by Lucía on 4/13/22.
//

import SwiftUI
import CoreBluetooth


struct DummyView: View {


    @State var dummyArray: [Dummy]
    @State private var selectedDevice: Dummy?
    @State private var navigate = false

    var body: some View {
        
            NavigationView{
                        ZStack {
                            NavigationLink(destination: ResultView(received: "PlaceCard").navigationBarBackButtonHidden(true), isActive: $navigate){
                            }
                            VStack (spacing: 10) {
                                
                                Text("Devices")
                                    .font(.largeTitle)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                Spacer()
                                
                                // MARK: Device List
                                List(dummyArray) { peripheral in
                                    HStack {
                                        Text(peripheral.name)
                                        Spacer()
                                        Text(String(peripheral.rssi))
                                    }.onTapGesture {
                                        selectedDevice = peripheral
                                        
                                    }
                                }.frame(height: 300)
                                
                                Spacer()
                                

                                }
                            .alert(item: $selectedDevice) { show in
                                    Alert(
                                        title: Text("Connect to " + show.name),
                                                    message: Text("There is no undo"),
                                        primaryButton: .default(Text("Connect")) {
                                            print("Connecting...")
                                            navigate.toggle()
                                            },
                                        secondaryButton: .cancel()
                                    )
                                }

                        }
            }

        
    }
}

struct DummyView_Previews: PreviewProvider {
    static var previews: some View {
        let model = DummyModel()
        DummyView(dummyArray: model.dummies)
            
    }
}
