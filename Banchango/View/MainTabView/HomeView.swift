import SwiftUI
import MapKit
import CoreLocation

// HomeView 정의 - SwiftUI 뷰로, 지도를 보여주고 검색 기능을 제공
struct HomeView: View {
    @StateObject private var locationManager = LocationManager()     // 위치 업데이트 관리할 객체
    @State private var searchText: String = ""                       // 사용자가 입력할 검색어를 저장하는 상태 변수
    @State private var isShowMapView: Bool = true                    // 지도를 보여줄지 여부를 제어하는 상태 변수
    @State private var selectedPlace: Place?                         // 사용자가 선택할 장소를 저장하는 상태 변수
    
    // MARK: - PharmacyService
    @State private var pharmacies: [Pharmacy] = []
    @State private var errorMessage: String?
    
    var body: some View {
        ZStack {
            if isShowMapView {
                // 지도 뷰를 보여줌
                Map(coordinateRegion: $locationManager.region, showsUserLocation: true, annotationItems: locationManager.nearbyPlaces) { place in
                    // 장소에 대한 마커(annotation)을 지도에 추가
                    MapAnnotation(coordinate: place.coordinate) {
                        Button(action: {
                            selectedPlace = place   // 사용자가 마커를 클릭하면 해당 장소를 선택
                        }) {
                            Image(systemName: "pill.circle")
                                .resizable()
                                .foregroundColor(.red)                  // 마커 색상 설정
                                .background(Circle().fill(.white))      // 마커 배경 설정
                                .frame(width: 40, height: 40)           // 마커 크기 설정
                                .shadow(radius: 4)                      // 그림자 추가
                        }
                    }
                }
                .edgesIgnoringSafeArea(.top)                            // 맵이 화면 전체를 채우도록 설정
            }
            
            VStack {
                HStack(spacing: 10) {
                    // 검색어 입력 텍스트 필드
                    TextField("검색어를 입력하시오", text: $searchText)
                        .padding()
                        .background(Color(.white))
                        .cornerRadius(10)
                        .shadow(color: .gray.opacity(1), radius: 4, x: 0, y: 2)
                    
                    // 검색 버튼
                    Button(action: {
                        print("검색 버튼 테스트")
                    }) {
                        Text("검색")
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(.blue)
                    .cornerRadius(10)
                    .shadow(color: .gray.opacity(1), radius: 4, x: 0, y: 2)
                }
                
                // 현재 주소 출력
                if let address = locationManager.currentAddress {
                    Text("현재 위치: \(address)")
                }
                
                // 지도 중심 위치 출력
                Text("지도 중심: \(locationManager.region.center.latitude), \(locationManager.region.center.longitude)")
                    .padding()
                    .background(.gray.opacity(0.2))
                    .cornerRadius(10)
                
                Spacer()
                
                // 내 위치로 이동하는 버튼 추가
                Button(action: {
                    locationManager.updateRegionToCurrentLocation()
                }) {
                    Text("내 위치로 이동")
                        .foregroundColor(.white)
                        .padding()
                        .background(.blue)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
        .onAppear {
            isShowMapView = true
        }
        .onChange(of: locationManager.region.center) { newCenter in
            Task {
                let userLatitude = newCenter.latitude
                let userLongitude = newCenter.longitude
                
                // 약국 정보를 받아옴
                let result = await PharmacyService.shared.getNearbyPharmacies(latitude: userLatitude, longitude: userLongitude)
                
                switch result {
                case .success(let fetchedPharmacies):
                    // 약국 정보를 기반으로 주변 장소 추가
                    locationManager.addNearbyPlaces(pharmacies: fetchedPharmacies)
                    pharmacies = fetchedPharmacies
                    
                    for pharmacy in fetchedPharmacies {
                        print("약국 이름: \(pharmacy.name), 주소: \(pharmacy.address)")
                    }
                    
                case .failure(let error):
                    errorMessage = "데이터를 불러오지 못했습니다: \(error)"
                }
            }
        }
        .sheet(item: $selectedPlace) { place in
            // 선택된 장소가 있을 경우 모달 뷰를 표시
            HalfModalView(place: place)
                .presentationDetents([.fraction(0.5)])  // 모달 뷰가 화면의 절반만 차지하도록 설정
        }
    }
}

// Place 모델 정의 - 지도에 표시할 장소를 나타내는 구조체
struct Place: Identifiable {
    let id = UUID()                         // 고유 식별자(각 장소를 구분)
    let coordinate: CLLocationCoordinate2D  // 장소의 좌표 (위도와 경도)
    let name: String                        // 장소의 이름
}

// LocationManager 클래스 정의 - 위치 업데이트를 관리하는 클래스
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    // CLLocationManager는 iOS에서 위치 데이터를 관리하는 핵심 클래스
    private let locationManager = CLLocationManager()
    
    // 역지오코딩을 위한 CLGeocoder
    private let geocoder = CLGeocoder() // 역지오코딩을 위한 CLGeocoder
    
    // @Published: 값이 변경될 때마다 SwiftUI 뷰가 자동으로 업데이트됨
    @Published var region = MKCoordinateRegion()    // 현재 지도의 영역(중심 좌표와 범위)
    @Published var currentAddress: String?          // 현재 위치의 주소 저장
    @Published var currentLocation: CLLocation? {   // 사용자의 현재 위치
        didSet {
            if let location = currentLocation {
                // 주소 변환 (역지오코딩)
                reverseGeocode(location: location)
            }
        }
    }
    
    // 지도에 표시할 주변 장소들
    @Published var nearbyPlaces: [Place] = []
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    var isMapInitialized = false // 최초로 카메라 이동을 제어하기 위한 변수
    
    // 위치가 업데이트될 때마다 호출되는 함수
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        DispatchQueue.main.async {
            self.currentLocation = location
            
            // 지도 초기화 여부 확인 후 초기화
            if !self.isMapInitialized {
                self.region = MKCoordinateRegion(
                    center: location.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
                self.isMapInitialized = true
            }
        }
    }
    
    // 약국 데이터를 기반으로 주변 장소를 추가하는 함수
    func addNearbyPlaces(pharmacies: [Pharmacy]) {
        let places = pharmacies.map { pharmacy in
            Place(coordinate: CLLocationCoordinate2D(latitude: pharmacy.latitude, longitude: pharmacy.longitude), name: pharmacy.name)
        }
        
        // 주변 장소 목록을 업데이트
        DispatchQueue.main.async {
            self.nearbyPlaces = places
        }
    }
    
    // 좌표를 주소로 변환하는 함수
    private func reverseGeocode(location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self, error == nil else { return }
            if let placemark = placemarks?.first {
                self.currentAddress = [
                    placemark.thoroughfare,
                    placemark.locality,
                    placemark.administrativeArea,
                    placemark.country
                ]
                .compactMap { $0 }
                .joined(separator: ", ")
            }
        }
    }
    
    // 내 위치로 카메라 이동하는 함수
    func updateRegionToCurrentLocation() {
        guard let location = currentLocation else { return }
        DispatchQueue.main.async {
            self.region = MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        }
    }
}

// 선택된 장소를 보여주는 모달 뷰
struct HalfModalView: View {
    var place: Place
    
    var body: some View {
        ZStack {
            CircleImage()
                .frame(width: 150, height: 150)
                .overlay(Circle().stroke(Color.white, lineWidth: 4))
                .shadow(radius: 10)
                .offset(y: -150)
        }
        
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
    }
}

// 이미지를 원형으로 보여주는 뷰
struct CircleImage: View {
    var body: some View {
        Image("Cat")
            .clipShape(Circle())
    }
}

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

#Preview {
    HomeView()
}










//
////
////  HomeView.swift
////  Banchango
////
////  Created by 김동현 on 9/10/24.
////
//
//import SwiftUI
//import MapKit
//import CoreLocation
//
//// HomeView 정의 - SwiftUI 뷰로, 지도를 보여주고 검색 기능을 제공
//struct HomeView: View {
//    @StateObject private var locationManager = LocationManager()     // 위치 업데이트 관리할 객체
//    @State private var searchText: String = ""                       // 사용자가 입력할 검색어를 저장하는 상태 변수
//    @State private var isShowMapView: Bool = true                    // 지도를 보여줄지 여부를 제어하는 상태 변수
//    @State private var selectedPlace: Place?                         // 사용자가 선택할 장소를 저장하는 상태 변수
//    
//    // MARK: - PharmacyService
//    @State private var pharmacies: [Pharmacy] = []
//    @State private var errorMessage: String?
//    
//    var body: some View {
//        ZStack {
//            if isShowMapView {
//                // 지도 뷰를 보여줌
//                Map(coordinateRegion: $locationManager.region, showsUserLocation: true, annotationItems: locationManager.nearbyPlaces) { place in
//                    // 장소에 대한 마커(annotation)을 지도에 추가
//                    MapAnnotation(coordinate: place.coordinate) {
//                        Button(action: {
//                            selectedPlace = place   // 사용자가 마커를 클릭하면 해당 장소를 선택
//                        }) {
//                            Image(systemName: "pill.circle")
//                                .resizable()
//                                .foregroundColor(.red)                  // 마커 색상 설정
//                                .background(Circle().fill(.white))      // 마커 배경 설정
//                                .frame(width: 40, height: 40)           // 마커 크기 설정
//                                .shadow(radius: 4)                      // 그림자 추가
//                        }
//                    }
//                }
//                .edgesIgnoringSafeArea(.top)                            // 맵이 화면 전체를 채우도록 설정
//            }
//            
//            VStack {
//                HStack(spacing: 10) {
//                    // 검색어 입력 텍스트 필드
//                    TextField("검색어를 입력하시오", text: $searchText)
//                        .padding()
//                        .background(Color(.white))
//                        .cornerRadius(10)
//                        .shadow(color: .gray.opacity(1), radius: 4, x: 0, y: 2)
//                    
//                    // 검색 버튼
//                    Button(action: {
//                        print("검색 버튼 테스트")
//                    }) {
//                        Text("검색")
//                    }
//                    .foregroundColor(.white)
//                    .padding()
//                    .background(.blue)
//                    .cornerRadius(10)
//                    .shadow(color: .gray.opacity(1), radius: 4, x: 0, y: 2)
//                }
//                
//                // 현재 주소 출력
//                if let address = locationManager.currentAddress {
//                    Text("현재 위치: \(address)")
//                }
//                
//                // 지도 중심 위치 출력
//                Text("지도 중심: \(locationManager.region.center.latitude), \(locationManager.region.center.longitude)")
//                    .padding()
//                    .background(.gray.opacity(0.2))
//                    .cornerRadius(10)
//                
//                Spacer()
//                
//                // 내 위치로 이동하는 버튼 추가
//                Button(action: {
//                    locationManager.updateRegionToCurrentLocation()
//                }) {
//                    Text("내 위치로 이동")
//                        .foregroundColor(.white)
//                        .padding()
//                        .background(.blue)
//                        .cornerRadius(10)
//                }
//            }
//            .padding()
//        }
//        .onAppear {
//            // 뷰가 나타날 때 지도 보여줌
//            DispatchQueue.main.async {
//                isShowMapView = true
//            }
//            
//            // MARK: - 약국 정보 가져오기
//            /*
//            let q0 = "부산"
//            let q1 = "남구"
//            let pageNo = "1"
//            let numOfRows = "1"
//            let qn = "일층약국"
//            
//            DispatchQueue.global().async {
//                let pharmacies = PharmacyManager.shared.getPharmacyInfo(q0: q0, q1: q1, pageNo: pageNo, numOfRows: numOfRows, qn: qn)
//                if let pharmacy = pharmacies {
//                    print("약국 이름: \(pharmacy.name)")
//                    print("주소: \(pharmacy.address)")
//                    print("운영 시간: \(pharmacy.operatingHours)")
//                }
//            }
//             */
//            
////            Task {
//////                let userLatitude = locationManager.region.center.latitude // 사용자 현재 위치의 위도
//////                let userLongitude = locationManager.region.center.longitude // 사용자 현재 위치의 경도
////                let userLatitude = 35.137552 // 사용자 현재 위치의 위도
////                let userLongitude = 129.101507 // 사용자 현재 위치의 경도
////                let result = await PharmacyService.shared.getNearbyPharmacies(latitude: userLatitude, longitude: userLongitude)
////
////                switch result {
////                case .success(let fetchedPharmacies):
////                    pharmacies = fetchedPharmacies
////                    // 성공적으로 약국 데이터를 가져온 후, 결과를 출력합니다.
////                    for pharmacy in fetchedPharmacies {
////                        print("약국 이름: \(pharmacy.name), 주소: \(pharmacy.address)")
////                    }
////
////                case .failure(let error):
////                    errorMessage = "데이터를 불러오지 못했습니다: \(error)"
////                }
////            }
//
//            
//        }
//        // 사용자 위치가 업데이트될 때 약국 검색을 실행
//        .onChange(of: locationManager.region.center) { newCenter in
//            Task {
//                let userLatitude = newCenter.latitude
//                let userLongitude = newCenter.longitude
//                
//                let result = await PharmacyService.shared.getNearbyPharmacies(latitude: userLatitude, longitude: userLongitude)
//                
//                switch result {
//                case .success(let fetchedPharmacies):
//                    pharmacies = fetchedPharmacies
//                    // 성공적으로 약국 데이터를 가져온 후, 결과를 출력합니다.
//                    for pharmacy in fetchedPharmacies {
//                        print("약국 이름: \(pharmacy.name), 주소: \(pharmacy.address)")
//                    }
//                    
//                case .failure(let error):
//                    errorMessage = "데이터를 불러오지 못했습니다: \(error)"
//                }
//            }
//        }
//        .sheet(item: $selectedPlace) { place in
//            // 선택된 장소가 있을 경우 모달 뷰를 표시
//            HalfModalView(place: place)
//                .presentationDetents([.fraction(0.5)])  // 모달 뷰가 화면의 절반만 차지하도록 설정
//        }
//    }
//}
//
//// Place 모델 정의 - 지도에 표시할 장소를 나타내는 구조체
//struct Place: Identifiable {
//    let id = UUID()                         // 고유 식별자(각 장소를 구분)
//    let coordinate: CLLocationCoordinate2D  // 장소의 좌표 (위도와 경도)
//    let name: String                        // 장소의 이름
//}
//
//// LocationManager 클래스 정의 - 위치 업데이트를 관리하는 클래스
//class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
//    
//    // CLLocationManager는 iOS에서 위치 데이터를 관리하는 핵심 클래스
//    private let locationManager = CLLocationManager()
//    
//    // 역지오코딩을 위한 CLGeocoder
//    private let geocoder = CLGeocoder() // 역지오코딩을 위한 CLGeocoder
//    
//    // @Published: 값이 변경될 때마다 SwiftUI 뷰가 자동으로 업데이트됨
//    @Published var region = MKCoordinateRegion()    // 현재 지도의 영역(중심 좌표와 범위)
//    @Published var currentAddress: String?          // 현재 위치의 주소 저장
//    @Published var currentLocation: CLLocation? {   // 사용자의 현재 위치
//        didSet {
//            if let location = currentLocation {
//                // 주소 변환 (역지오코딩)
//                reverseGeocode(location: location)
//                
//                DispatchQueue.main.async {
//                    // 현재 위치 기반으로 주변 장소 추가
//                    self.addNearbyPlaces(location: location)
//                }
//            }
//        }
//    }
//    
//    // 지도에 표시할 주변 장소들
//    @Published var nearbyPlaces: [Place] = []
//    
//    override init() {
//        super.init()
//        self.locationManager.delegate = self
//        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        self.locationManager.requestWhenInUseAuthorization()
//        self.locationManager.startUpdatingLocation()
//    }
//    
//    var isMapInitialized = false // 최초로 카메라 이동을 제어하기 위한 변수
//    
//    // 위치가 업데이트될 때마다 호출되는 함수
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let location = locations.last else { return }
//        
//        DispatchQueue.main.async {
//            self.currentLocation = location
//            
//            // 지도 초기화 여부 확인 후 초기화
//            if !self.isMapInitialized {
//                self.region = MKCoordinateRegion(
//                    center: location.coordinate,
//                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
//                )
//                self.isMapInitialized = true
//            }
//        }
//    }
//    
//    // 사용자 위치를 기반으로 주변 장소를 추가하는 함수
//    private func addNearbyPlaces(location: CLLocation) {
//        let places = [
//            Place(coordinate: CLLocationCoordinate2D(latitude: location.coordinate.latitude + 0.001, longitude: location.coordinate.longitude + 0.001), name: "Place 1"),
//            Place(coordinate: CLLocationCoordinate2D(latitude: location.coordinate.latitude - 0.001, longitude: location.coordinate.longitude - 0.001), name: "Place 2"),
//            Place(coordinate: CLLocationCoordinate2D(latitude: location.coordinate.latitude + 0.002, longitude: location.coordinate.longitude - 0.002), name: "Place 3")
//        ]
//        
//        // 주변 장소 목록을 업데이트
//        DispatchQueue.main.async {
//            self.nearbyPlaces = places
//        }
//    }
//    
//    // 좌표를 주소로 변환하는 함수
//    private func reverseGeocode(location: CLLocation) {
//        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
//            guard let self = self, error == nil else { return }
//            if let placemark = placemarks?.first {
//                self.currentAddress = [
//                    placemark.thoroughfare,
//                    placemark.locality,
//                    placemark.administrativeArea,
//                    placemark.country
//                ]
//                .compactMap { $0 }
//                .joined(separator: ", ")
//            }
//        }
//    }
//    
//    // 내 위치로 카메라 이동하는 함수
//    func updateRegionToCurrentLocation() {
//        guard let location = currentLocation else { return }
//        DispatchQueue.main.async {
//            self.region = MKCoordinateRegion(
//                center: location.coordinate,
//                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
//            )
//        }
//    }
//}
//
//// 선택된 장소를 보여주는 모달 뷰
//struct HalfModalView: View {
//    var place: Place
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
//// 이미지를 원형으로 보여주는 뷰
//struct CircleImage: View {
//    var body: some View {
//        Image("Cat")
//            .clipShape(Circle())
//    }
//}
//
//extension CLLocationCoordinate2D: Equatable {
//    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
//        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
//    }
//}
//
//#Preview {
//    HomeView()
//}
//
