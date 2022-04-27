//
//  DummyModel.swift
//  bluetoothCookies
//
//  Created by Lucía on 4/27/22.
//

import Foundation

class DummyModel: ObservableObject {
    @Published var dummies = [Dummy]()
    
    init(){
        // Create an instance of data service and get the data
        //let service = DataService()
        self.dummies = [Dummy(name: "iPhone Lucia", rssi: -3), Dummy(name: "iPhone Kylie", rssi: 44), Dummy(name: "iPhone Blanca",rssi: 9)]
        
    }
    
}
