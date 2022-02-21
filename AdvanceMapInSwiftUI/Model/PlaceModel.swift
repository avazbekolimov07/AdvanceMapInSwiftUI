//
//  PlaceModel.swift
//  AdvanceMapInSwiftUI
//
//  Created by 1 on 22/09/21.
//

import SwiftUI
import MapKit

struct PlaceModel: Identifiable {
    
    var id = UUID().uuidString
    var placemark: CLPlacemark
}
