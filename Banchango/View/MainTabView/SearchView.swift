//
//  SearchView.swift
//  Banchango
//
//  Created by 김동현 on 9/16/24.
//

import SwiftUI
import MapKit

// Identifiable을 따르는 구조체
struct UserLocation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

struct SearchView: View {
//    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(
//        latitude: 37.5666791,
//        longitude: 126.9782914),
//        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
    
    @StateObject private var locationManager = LocationManagerBeta()
    var body: some View {
        Text("Favorite View")
        // Map(coordinateRegion: $locationManager.region)
//        Map(coordinateRegion: $locationManager.region, annotationItems: [locationManager.userLocation].compactMap { $0 }) { location in
//            MapMarker(coordinate: location.coordinate, tint: .blue) // 현재 위치에 파란색 마커 추가
//        }
//            .ignoresSafeArea()
    }
        
}

#Preview {
    SearchView()
}





import CoreLocation

class LocationManagerBeta: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()
    
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(
            latitude: 37.5666791, // 기본 좌표 (서울시청)
            longitude: 126.9782914),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    // 사용자 위치를 저장할 Identifiable 객체
    @Published var userLocation: UserLocation?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        // Identifiable 객체로 변환하여 저장
        userLocation = UserLocation(coordinate: location.coordinate)
        
        // 사용자의 현재 위치로 지도를 업데이트
        region = MKCoordinateRegion(
            center: location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    }
}




//import CoreLocation

//
//class LocationManagerBeta: NSObject, ObservableObject, CLLocationManagerDelegate {
//    private var locationManager = CLLocationManager()
//    @Published var currentLocation: CLLocation? // 사용자의 현재 위치 저장
//
//    @Published var region = MKCoordinateRegion(
//        center: CLLocationCoordinate2D(
//                    latitude: 37.5666791, // 기본 좌표 (서울시청)
//                    longitude: 126.9782914),
//                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
//    )
//
//    override init() {
//        super.init()
//        locationManager.delegate = self
//        locationManager.requestWhenInUseAuthorization()
//        locationManager.startUpdatingLocation()
//    }
//
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let location = locations.first else { return }
//        currentLocation = location  // 현재 위치 저장
//        region = MKCoordinateRegion(
//            center: location.coordinate,
//            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
//        )
//
//    }
//}
