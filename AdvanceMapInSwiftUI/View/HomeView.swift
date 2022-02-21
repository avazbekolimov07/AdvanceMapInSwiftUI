//
//  HomeView.swift
//  AdvanceMapInSwiftUI
//
//  Created by 1 on 21/09/21.
//

import SwiftUI
import CoreLocation
import MapKit

struct HomeView: View {
    @StateObject var mapData = MapViewModel()
    //Location Manager
    @State var locationManager = CLLocationManager()
    
    
    var body: some View {
        ZStack {
            VStack {
            MapView()
            //using it as environment object so that it can be used ints subViews
                .environmentObject(mapData)
                .ignoresSafeArea(.all, edges: .all)
            }
            VStack {
                VStack(spacing: 0) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search", text: $mapData.searchTxt)
                            .colorScheme(.light)
                    } //: HStack
                    .padding(.vertical, 10)
                    .padding(.horizontal)
                    .background(Color.white)
                    .cornerRadius(8)
                    
                    //Displaying results
                    
                    if !mapData.places.isEmpty && mapData.searchTxt != ""{
                        ScrollView {
                            VStack(spacing: 15){
                                ForEach(mapData.places) { place in
                                    Text(place.placemark.name ?? "")
                                        .foregroundColor(.black)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.leading)
                                        .onTapGesture {
                                            mapData.selectPlace(place: place)
                                        }
                                    Divider()
                                } //: Loop
                            } //: VStack
                            .padding(.top)
                        } //: Scroll
                        .background(Color.white)
                    } //: If
                    
                } //: VStack
                .padding()
                
                Spacer()
                
                VStack {
                    Button {
                        mapData.focusLocation()
                    } label: {
                        Image(systemName: "location.fill")
                            .font(.title2)
                            .padding(10)
                            .background(Color.primary)
                            .clipShape(Circle())
                    }
                    
                    
                    Button {
                        mapData.updateMapType()
                    } label: {
                        Image(systemName: mapData.mapType == .standard ? "network" : "map")
                            .font(.title2)
                            .padding(10)
                            .background(Color.primary)
                            .clipShape(Circle())
                    }
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding()
                }
            
        } //: ZSTACK
        .onAppear(perform: {
            locationManager.delegate = mapData
            locationManager.requestWhenInUseAuthorization()
        })
        //Permisson Denied Alert
        .alert(isPresented: $mapData.permissionDenied, content: {
            
            Alert(title: Text("Permission Denied"), message: Text("Please Enable Permission In App Settings"), dismissButton: .default(Text("Goto Settings"), action: {
                
                //Redirecting User to Settings
                UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
            }))
        }) //: Alert
        .onChange(of: mapData.searchTxt) { newValue in
            // Searching Places
            
            // You can use your own delay time to avoid Continous Search Request
            let delay = 0.3
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                if newValue == mapData.searchTxt {
                   // Search
                    self.mapData.searchQuery()
                }
            } // :DispatchQueue
        } // :onChange
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
