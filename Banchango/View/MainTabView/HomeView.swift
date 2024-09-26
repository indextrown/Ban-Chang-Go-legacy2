//
//  HomeView.swift
//  Banchango
//
//  Created by 김동현 on 9/10/24.
//

import SwiftUI
import MapKit
import CoreLocation

struct Place: Identifiable {
    let id = UUID() // 고유 식별자
    let coordinate: CLLocationCoordinate2D
    let name: String // 예시로 마커 이름 추가
}

struct HomeView: View {
    @State private var searchText: String = ""
    @State private var region: MKCoordinateRegion = MKCoordinateRegion()
    @State var isShowMapView: Bool = false
    @State private var nearbyPlaces: [Place] = []
    @State private var selectedPlace: Place? // 선택된 장소를 저장
    
    var body: some View {
        ZStack {
            if isShowMapView {
                // Map(coordinateRegion: $region, showsUserLocation: true)
                Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: nearbyPlaces) { place in
                    MapAnnotation(coordinate: place.coordinate) {
                        Button(action: {
                            selectedPlace = place // 마커 클릭 시 해당 장소 선택
                        }) {
                            Image(systemName: "pill.circle")
                                .resizable()
                                .foregroundColor(.red)
                                .background(Circle().fill(.white))
                                .frame(width: 40, height: 40)
                                .shadow(radius: 4)  // 그림자 추가
                                //.imageScale(.large)
                        }
                    }
                }
            }
            
            VStack {
                HStack(spacing: 10) {
                    TextField("검색어를 입력하시오", text: $searchText)
                        .padding()
                        .background(Color(.white))
                        .cornerRadius(10)
                        .shadow(color: .gray.opacity(1), radius: 4, x:0, y: 2)
                    
                    
                    
                    Button(action: {
                        print("검색 버튼 테스트")
                    }, label: {
                        Text("검색")
                    })
                    .foregroundColor(.white)
                    .padding()
                    .background(.blue)
                    .cornerRadius(10)
                    .shadow(color: .gray.opacity(1), radius: 4, x:0, y: 2)
                }
                Spacer()
                
                
                Spacer()
            }
            .padding()
        }
        .onAppear {
            setupLocation()
            addNearbyPlaces()
        }
        .sheet(item: $selectedPlace) { place in
            HalfModalView(place: place)
                .presentationDetents([.fraction(0.5)]) // 화면 절반만 차지하도록 설정
        }
    }
    
    private func setupLocation() {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        
        if let location = manager.location {
            // let latitude = manager.location?.coordinate.latitude
            // let longitude = manager.location?.coordinate.longitude
            region = MKCoordinateRegion(
                // center: CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!),
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
            isShowMapView = true
        }
    }
    
    private func addNearbyPlaces() {
        // 현재 위치를 기준으로 주변 마커를 추가합니다.
        if let currentLocation = CLLocationManager().location {
            nearbyPlaces = [
                Place(coordinate: CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude + 0.001, longitude: currentLocation.coordinate.longitude + 0.001), name: "Place 1"),
                Place(coordinate: CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude - 0.001, longitude: currentLocation.coordinate.longitude - 0.001), name: "Place 2"),
                Place(coordinate: CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude + 0.002, longitude: currentLocation.coordinate.longitude - 0.002), name: "Place 3")
            ]
        }
    }
}

#Preview {
    HomeView()
}

struct HalfModalView: View {
    var place: Place
    
    var body: some View {
        VStack {
            Text("장소 이름: \(place.name)")
                .font(.headline)
            Text("위도: \(place.coordinate.latitude)")
            Text("경도: \(place.coordinate.longitude)")
            Spacer()
        }
        .padding()
        .background(.white)
        .cornerRadius(20)
        //.shadow(radius: 10)
    }
}









// CustomMapView(region: $region)
//
//struct CustomMapView: UIViewRepresentable {
//    @Binding var region: MKCoordinateRegion
//
//    func makeUIView(context: Context) -> MKMapView {
//        let mapView = MKMapView()
//        mapView.mapType = .mutedStandard // 지도 스타일 설정
//        mapView.showsUserLocation = true
//        mapView.setRegion(region, animated: true)
//        return mapView
//    }
//
//    func updateUIView(_ uiView: MKMapView, context: Context) {
//        uiView.setRegion(region, animated: true)
//    }
//}
