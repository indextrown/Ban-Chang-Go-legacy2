////
////  test.swift
////  Banchango
////
////  Created by 김동현 on 10/6/24.
////
//
//import Foundation
//
//
//// https://www.youtube.com/watch?v=GxRjFLyICiA
//
//import SwiftUI
//import MapKit
//import CoreLocation
//
//// LocationManager: 사용자 위치를 관리하는 클래스
//final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
//    
//    // CLLocationManager는 iOS에서 위치 데이터를 관리하는 핵심 클래스
//    private var locationManager = CLLocationManager()
//    
//    // 사용자 위치가 처음 업데이트될 때만 카메라 위치를 업데이트하기 위해 플래그 추가
//    private var isFirstUpdate = true
//    
//    @Published var position: MapCameraPosition = .automatic
//    
//    
//    // MARK: - 지도에 표시할 주변 장소들
//    @Published var nearbyPharmacies: [PharmacyPlace] = []
//    
//    // 약국 정보를 저장하는 딕셔너리 (이름 + 주소를 key로 사용)
//    private var pharmacyDictionary: [String: PharmacyPlace] = [:]
//    
//    
//
//    override init() {
//        super.init()
//        locationManager.delegate = self
//        locationManager.requestWhenInUseAuthorization()
//        locationManager.startUpdatingLocation()
//    }
//    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        DispatchQueue.global(qos: .userInitiated).async {
//            if let location = locations.first, self.isFirstUpdate {
//                let camera = MapCamera(centerCoordinate: location.coordinate, distance: 5000, heading: 0, pitch: 0)
//                
//                // 메인 스레드에서 카메라 업데이트
//                DispatchQueue.main.async {
//                    self.position = .camera(camera)
//                    self.isFirstUpdate = false
//                }
//            }
//        }
//    }
//
//    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        print("위치 업데이트 실패: \(error.localizedDescription)")
//    }
//    
//    func moveToCurrentLocation() {
//        DispatchQueue.global(qos: .background).async { // 백그라운드에서 위치 가져오기
//            guard let location = self.locationManager.location else { return }
//
//            DispatchQueue.main.async { // 메인 스레드에서 UI 업데이트
//                self.position = .camera(MapCamera(centerCoordinate: location.coordinate, distance: 5000))
//            }
//        }
//    }
//    
//    // Pharmacy 데이터를 PharmacyPlace로 변환한 후 저장하는 메서드
//    func addNearbyPlaces(pharmacies: [Pharmacy]) {
//        
//        // MARK: - 백그라운드에서 데이터 처리 수행
//        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
//            
//            // 약한 참조 사용하여 self의 메모리 문제 방지
//            guard let self = self else { return }
//            
//            var newPlaces: [PharmacyPlace] = []
//            
//            for pharmacy in pharmacies {
//                
//                // 약국 이름 + 주소를 key로 사용
//                let key = "\(pharmacy.name) \(pharmacy.address)"
//                
//                // key가 유효한 문자열인지 확인하고, 존재하지 않으면 새로운 약국 정보를 추가
//                if self.pharmacyDictionary[key] == nil {
//                    let newPlace = PharmacyPlace(
//                        coordinate: CLLocationCoordinate2D(
//                            latitude: pharmacy.latitude,
//                            longitude: pharmacy.longitude),
//                        name: pharmacy.name
//                    )
//                    
//                    // 딕셔너리에 새로운 key와 장소를 추가
//                    self.pharmacyDictionary[key] = newPlace
//                    newPlaces.append(newPlace)
//                    
//                    print("약국 이름: \(pharmacy.name), 주소: \(pharmacy.address)")
//                }
//            }
//            
//            // MARK: - UI 업데이트는 메인 스레드에서 처리
//            DispatchQueue.main.async {
//                self.nearbyPharmacies.append(contentsOf: newPlaces)
//            }
//        }
//    }
//
//}
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//// HomeView: 지도와 UI 요소를 포함한 뷰
//struct HomeView: View {
//    @StateObject private var locationManager = LocationManager()  // 사용자 위치를 관리하는 LocationManager 인스턴스
//    @State private var searchText: String = ""                    // 검색어 상태 변수
//    let categoryArray = ["약국", "응급실"]                           // 카테고리 배열
//    @State private var selectedCategory: String?                  // 선택된 카테고리 추적 상태 변수
//    @State private var selectedPlace: PharmacyPlace?              // 사용자가 선택할 장소를 저장하는 상태 변수
//    
//    
//    // 싱글톤
//    let pharmacyService = PharmacyService.shared
//    
//    // MARK: - PharmacyServices
////    @State private var pharmacies: [PharmacyPlace] = []
////    @State private var errorMessage: String?
//    
//    // 샘플 장소 (약국) 배열
//    /*
//    let samplePharmacies = [
//        PharmacyPlace(coordinate: CLLocationCoordinate2D(latitude: 35.137155538014106, longitude: 129.10009858316897), name: "약국 1"),
//        PharmacyPlace(coordinate: CLLocationCoordinate2D(latitude: 35.13652382255772, longitude: 129.0991866321039), name: "약국 2"),
//        PharmacyPlace(coordinate: CLLocationCoordinate2D(latitude: 35.13623867161408, longitude: 129.10020587152957), name: "약국 3"),
//        PharmacyPlace(coordinate: CLLocationCoordinate2D(latitude: 35.13634176476283, longitude: 129.10090861029147), name: "약국 4")
//    ]
//     */
//    
//    var body: some View {
//        ZStack {
//            // 지도에 마커를 추가 (약국 위치 표시)
//            Map(position: $locationManager.position) {
//                UserAnnotation()
//                
//                // 마커에 커스텀 Annotation 사용
//                ForEach(locationManager.nearbyPharmacies) { pharmacy in
//                    Annotation("", coordinate: pharmacy.coordinate) {
//                        Button(action: {
//                            selectedPlace = pharmacy   // 사용자가 마커를 클릭하면 해당 장소를 선택
//                        }) {
//                            Image(systemName: "pill.circle")
//                                .resizable()
//                                .foregroundColor(.red)                  // 마커 색상 설정
//                                .background(Circle().fill(.white))      // 마커 배경 설정
//                                .frame(width: 30, height: 30)           // 마커 크기 설정
//                                .shadow(radius: 4)                      // 그림자 추가
//                        }
//                    }
//                }
//            }
//            .ignoresSafeArea()
//            .mapStyle(.standard(elevation: .realistic))
//
//            VStack {
//                // 검색창
//                HStack(spacing: 10) {
//                    TextField("검색어를 입력하시오", text: $searchText)
//                        .padding()
//                        .background(Color(.white))
//                        .cornerRadius(10)
//                        .shadow(color: .gray.opacity(1), radius: 4, x: 0, y: 2)
//
//                    Button(action: {
//                        print("검색 버튼 테스트")
//                    }) {
//                        Text("검색")
//                    }
//                    .foregroundColor(.white)
//                    .padding()
//                    .background(Color.fromHex("#5fc567") ?? Color.gray)
//                    .cornerRadius(10)
//                    .shadow(color: .gray.opacity(1), radius: 4, x: 0, y: 2)
//                }
//                .padding()
//                
//                // 카테고리 버튼들
//                HStack(spacing: 10) {
//                    ForEach(categoryArray, id: \.self) { category in
//                        Button(action: {
//                            selectedCategory = category
//                            print("\(category) 버튼 클릭됨")
//                        }) {
//                            Text(category)
//                                .foregroundColor(selectedCategory == category ? .white : .black)
//                                .frame(width: 70, height: 40)
//                                .background(selectedCategory == category ? Color.fromHex("#5fc567") ?? Color.gray : .white)
//                                .cornerRadius(10)
//                                .shadow(color: Color.gray.opacity(0.5), radius: 4, x: 0, y: 2)
//                        }
//                    }
//                }
//                
//                Spacer()
//                
//                // 내 위치로 이동 버튼
//                Button(action: {
//                    locationManager.moveToCurrentLocation()
//                }) {
//                    Text("내 위치로 이동")
//                        .foregroundColor(.white)
//                        .padding()
//                        .background(Color.fromHex("#5CC87D")!) // Hex 색상 설정
//                        .cornerRadius(10)
//                }
//                .padding(.bottom, 20)
//            }
//            .zIndex(1.0)
//        }
//        .onAppear {
//            selectedCategory = categoryArray[0]
//            
//            Task {
//                let currentLatitude = 35.13753139104897      // 위도
//                let currentLongitude = 129.10161339412642    // 경도
//                let currentLocation = CLLocation(latitude: currentLatitude, longitude: currentLongitude)
//                let result = await pharmacyService.getNearbyPharmacies(latitude: currentLatitude, longitude: currentLongitude)
//                print(result)
//            }
//                
//                    
//        }
//        .sheet(item: $selectedPlace) { place in
//            // 선택된 장소가 있을 경우 모달 뷰를 표시
//            HalfModalView(place: place)
//                .presentationDetents([.fraction(0.5)])  // 모달 뷰가 화면의 절반만 차지하도록 설정
//        }
//
//        
//
//    }
//}
//
//#Preview {
//    HomeView()
//}
//
//
//// UIColor 확장: hex 문자열을 UIColor로 변환하는 함수
//extension UIColor {
//    convenience init?(hex: String) {
//        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
//        hexSanitized = hexSanitized.hasPrefix("#") ? String(hexSanitized.dropFirst()) : hexSanitized
//
//        let length = hexSanitized.count
//        var rgb: UInt64 = 0
//
//        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
//
//        let r, g, b: CGFloat
//        if length == 6 {
//            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
//            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
//            b = CGFloat(rgb & 0x0000FF) / 255.0
//
//            self.init(red: r, green: g, blue: b, alpha: 1.0)
//        } else {
//            return nil
//        }
//    }
//}
//
//// Color 확장: hex 문자열을 Color로 변환하는 함수 (함수 이름을 변경)
//extension Color {
//    static func fromHex(_ hex: String) -> Color? {
//        guard let uiColor = UIColor(hex: hex) else { return nil }
//        return Color(uiColor)
//    }
//}
//
//// 이미지를 원형으로 보여주는 뷰
//struct CircleImage: View {
//    var body: some View {
//        Image("Cat")
//            .clipShape(Circle())
//    }
//}
//
//// 선택된 장소를 보여주는 모달 뷰
//struct HalfModalView: View {
//    var place: PharmacyPlace
//    
//    var body: some View {
//        ZStack {
//            CircleImage()
//                .frame(width: 150, height: 150)
//                .overlay(Circle().stroke(Color.white, lineWidth: 4))
//                .shadow(radius: 10)
//                .offset(y: -150)
//        }
//        
//        VStack {
//            Text("장소 이름: \(place.name)")
//                .font(.headline)
//            Text("위도: \(place.coordinate.latitude)")
//            Text("경도: \(place.coordinate.longitude)")
//            Spacer()
//        }
//        .padding()
//        .background(.white)
//        .cornerRadius(20)
//    }
//}
//
//
//
//
//
//
////        .onChange(of: locationManager.region.center) { newCenter in
////            let userLatitude = newCenter.latitude
////            let userLongitude = newCenter.longitude
////
////            // 약국 정보 받아오기
////            let result = await PharmacyService.shared.getNearbyPharmacies(latitude: userLatitude, longitude: userLongitude)
////
////            switch result {
////            case .success(let fetchedPharmacies):
////                locationManager.addNearbyPlaces(pharmacies: fetchedPharmacies)
////                pharmacies = fetchedPharmacies
////            }
////        }
//
//
//
////        .onChange(of: locationManager.region.center) { newCenter in
////            let userLatitude = newCenter.latitude
////            let userLongitude = newCenter.longitude
////
////            // 약국 정보 받아오기
////            let result = await PharmacyService.shared.getNearbyPharmacies(latitude: userLatitude, longitude: userLongitude)
////
////            switch result {
////            case .success(let fetchedPharmacies):
////                locationManager.addNearbyPlaces(pharmacies: fetchedPharmacies)
////                pharmacies = fetchedPharmacies
////            }
////        }
//
//
//
//
//
//
////
////
////// PharmacyPlace 구조체: 약국 위치를 나타내는 데이터 모델
////struct PharmacyPlace: Identifiable {
////    let id = UUID()  // 'Identifiable'을 만족하는 고유 식별자
////    let coordinate: CLLocationCoordinate2D
////    let name: String
////}
////
////
////
////
