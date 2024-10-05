//import SwiftUI
//import MapKit
//import CoreLocation
//
//final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
//    private var locationManager = CLLocationManager()
//    
//    // 사용자 위치가 처음 업데이트될 때만 카메라 위치를 업데이트하기 위해 플래그 추가
//    private var isFirstUpdate = true
//    
//    @Published var position = MapCameraPosition.region(MKCoordinateRegion(
//        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
//        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
//    ))
//
//    override init() {
//        super.init()
//        locationManager.delegate = self
//        locationManager.requestWhenInUseAuthorization()  // 권한 요청
//        locationManager.startUpdatingLocation()
//    }
//    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        if let location = locations.first, isFirstUpdate {
//            position = .region(MKCoordinateRegion(
//                center: location.coordinate,
//                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
//            ))
//            
//            // 처음 업데이트 후에는 다시 원래 자리로 돌아가지 않도록 설정
//            isFirstUpdate = false
//        }
//    }
//
//    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        print("위치 업데이트 실패: \(error.localizedDescription)")
//    }
//    
//    // 1) 현재 위치로 이동하는 메소드 추가
//    func moveToCurrentLocation() {
//        guard let location = locationManager.location else { return }
//        
//        DispatchQueue.main.async {
//            self.position = .region(MKCoordinateRegion(
//                center: location.coordinate,
//                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01) // span 값을 updateRegionToCurrentLocation 함수와 동일하게 변경
//            ))
//        }
//    }
//
//    // 2) 지도가 움직인후에 현재 위치로 이동하는 메소드
//    func moveToCurrentLocation2() {
//        if let location = locationManager.location {
//            position = .region(MKCoordinateRegion(
//                center: location.coordinate,
//                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
//            ))
//        }
//    }
//}
//
//struct HomeView: View {
//    @StateObject private var locationManager = LocationManager()
//    @State private var searchText: String = ""                       // 사용자가 입력할 검색어를 저장하는 상태 변수
//    let categoryArray = ["약국", "응급실"]
//    @State private var selectedCategory: String? // 선택된 버튼을 추적하는 상태 변수
//
//    // MARK: - 샘플 장소
//    let samplePharmacies = [
//            PharmacyPlace(coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), name: "약국 1"),
//            PharmacyPlace(coordinate: CLLocationCoordinate2D(latitude: 37.7789, longitude: -122.4194), name: "약국 2"),
//            PharmacyPlace(coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4234), name: "약국 3"),
//            PharmacyPlace(coordinate: CLLocationCoordinate2D(latitude: 37.7789, longitude: -122.4234), name: "약국 4")
//        ]
//    
//    
//    var body: some View {
//        ZStack {
//            Map(position: $locationManager.position) {
//                // 필요시 사용자 주석이나 추가적인 맵 마커를 여기에 추가
//                UserAnnotation()
//                
//                // 샘플 약국 마커를 지도에 추가
//  
//                
//            }
//            .ignoresSafeArea()
//            
//            VStack {
//                // 검색창
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
//                .padding()
//                
//                // 배열 개수만큼 버튼 생성
//                HStack(spacing: 10) {
//                    ForEach(categoryArray, id: \.self) { category in
//                        Button(action: {
//                            selectedCategory = category
//                            print("\(category) 버튼 클릭됨")
//                        }) {
//                            Text(category)
//                                .foregroundColor(selectedCategory == category ? .white : .black)
//                                .frame(width: 70, height: 40)
//                                .background(selectedCategory == category ? .blue : .white)
//                                .cornerRadius(10)
//                                .shadow(color: Color.gray.opacity(0.5), radius: 4, x: 0, y: 2)  // 버튼 그림자
//                        }
//                    }
//                }
//                
//                Spacer()
//                
//                // 내위치로 이동
//                Button(action: {
//                    locationManager.moveToCurrentLocation()
//                }) {
//                    Text("내 위치로 이동")
//                        .foregroundColor(.white)
//                        .padding()
//                        .background(.blue)
//                        .cornerRadius(10)
//                }
//                .padding(.bottom, 20)   // 버튼 하단 20포인트 패딩 추가
//            }
//            .zIndex(1.0)
//            
//        }
//        .onAppear {
//            selectedCategory = categoryArray[0]
//        }
//    }
//}
//
//#Preview {
//    HomeView()
//}
//
//struct PharmacyPlace {
//    let id = UUID()                         // 고유 식별자(각 장소를 구분)
//    let coordinate: CLLocationCoordinate2D  // 장소의 좌표 (위도와 경도)
//    let name: String                        // 장소의 이름
//}
//



import SwiftUI
import MapKit
import CoreLocation

// LocationManager: 사용자 위치를 관리하는 클래스
final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()
    
    // 사용자 위치가 처음 업데이트될 때만 카메라 위치를 업데이트하기 위해 플래그 추가
    private var isFirstUpdate = true
    
    @Published var position: MapCameraPosition = .automatic

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        if let location = locations.first, isFirstUpdate {
////            position = .camera(MapCamera(centerCoordinate: location.coordinate, distance: 5000))
////            
////            // 처음 업데이트 후에는 다시 원래 자리로 돌아가지 않도록 설정
////            isFirstUpdate = false
//            DispatchQueue.main.async {
//                // 메인 스레드에서 UI 업데이트
//                self.position = .camera(MapCamera(centerCoordinate: location.coordinate, distance: 5000))
//                self.isFirstUpdate = false
//            }
//        }
//    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        DispatchQueue.global(qos: .userInitiated).async { // QoS 추가
            if let location = locations.first, self.isFirstUpdate {
                let region = MKCoordinateRegion(
                    center: location.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                )

                DispatchQueue.main.async {
                    self.position = .region(region)
                    self.isFirstUpdate = false
                }
            }
        }
    }


    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("위치 업데이트 실패: \(error.localizedDescription)")
    }
    
    // 1) 현재 위치로 이동하는 메소드 추가
//    func moveToCurrentLocation() {
//        guard let location = locationManager.location else { return }
//        DispatchQueue.main.async {
//            self.position = .camera(MapCamera(centerCoordinate: location.coordinate, distance: 5000))
//        }
//    }
    func moveToCurrentLocation() {
        DispatchQueue.global(qos: .background).async { // 백그라운드에서 위치 가져오기
            guard let location = self.locationManager.location else { return }

            DispatchQueue.main.async { // 메인 스레드에서 UI 업데이트
                self.position = .camera(MapCamera(centerCoordinate: location.coordinate, distance: 5000))
            }
        }
    }

}

// PharmacyPlace 구조체: 약국 위치를 나타내는 데이터 모델
struct PharmacyPlace: Identifiable {
    let id = UUID()  // 'Identifiable'을 만족하는 고유 식별자
    let coordinate: CLLocationCoordinate2D
    let name: String
}

// HomeView: 지도와 UI 요소를 포함한 뷰
struct HomeView: View {
    @StateObject private var locationManager = LocationManager()  // 사용자 위치를 관리하는 LocationManager 인스턴스
    @State private var searchText: String = ""                    // 검색어 상태 변수
    let categoryArray = ["약국", "응급실"]                          // 카테고리 배열
    @State private var selectedCategory: String?                  // 선택된 카테고리 추적 상태 변수

    // 샘플 장소 (약국) 배열
    let samplePharmacies = [
        PharmacyPlace(coordinate: CLLocationCoordinate2D(latitude: 35.137155538014106, longitude: 129.10009858316897), name: "약국 1"),
        PharmacyPlace(coordinate: CLLocationCoordinate2D(latitude: 35.13652382255772, longitude: 129.0991866321039), name: "약국 2"),
        PharmacyPlace(coordinate: CLLocationCoordinate2D(latitude: 35.13623867161408, longitude: 129.10020587152957), name: "약국 3"),
        PharmacyPlace(coordinate: CLLocationCoordinate2D(latitude: 35.13634176476283, longitude: 129.10090861029147), name: "약국 4")
    ]
    
    var body: some View {
        ZStack {
            // 지도에 마커를 추가 (약국 위치 표시)
                Map(position: $locationManager.position) {
                    UserAnnotation()
//                    ForEach(samplePharmacies) { pharmacy in
//                        Marker(pharmacy.name, coordinate: pharmacy.coordinate)
//                    }
            
//                MapAnnotation(coordinate: place.coordinate) {
//                    Button(action: {
//                        selectedPlace = place   // 사용자가 마커를 클릭하면 해당 장소를 선택
//                    }) {
//                        Image(systemName: "pill.circle")
//                            .resizable()
//                            .foregroundColor(.red)                  // 마커 색상 설정
//                            .background(Circle().fill(.white))      // 마커 배경 설정
//                            .frame(width: 40, height: 40)           // 마커 크기 설정
//                            .shadow(radius: 4)                      // 그림자 추가
//                    }
//                }
            }
            
            .ignoresSafeArea()
            .mapStyle(.standard(elevation: .realistic))

            VStack {
                // 검색창
                HStack(spacing: 10) {
                    TextField("검색어를 입력하시오", text: $searchText)
                        .padding()
                        .background(Color(.white))
                        .cornerRadius(10)
                        .shadow(color: .gray.opacity(1), radius: 4, x: 0, y: 2)

                    Button(action: {
                        print("검색 버튼 테스트")
                    }) {
                        Text("검색")
                    }
                    .foregroundColor(.white)
                    .padding()
                    //.background(.blue)
                    .background(Color.fromHex("#5fc567") ?? Color.gray)
                    .cornerRadius(10)
                    .shadow(color: .gray.opacity(1), radius: 4, x: 0, y: 2)
                }
                .padding()
                
                // 카테고리 버튼들
                HStack(spacing: 10) {
                    ForEach(categoryArray, id: \.self) { category in
                        Button(action: {
                            selectedCategory = category
                            print("\(category) 버튼 클릭됨")
                        }) {
                            Text(category)
                                .foregroundColor(selectedCategory == category ? .white : .black)
                                .frame(width: 70, height: 40)
                                //.background(selectedCategory == category ? .blue : .white)
                                .background(selectedCategory == category ? Color.fromHex("#5fc567") ?? Color.gray : .white)
                            
                                .cornerRadius(10)
                                .shadow(color: Color.gray.opacity(0.5), radius: 4, x: 0, y: 2)
                        }
                    }
                }
                
                Spacer()
                
                // 내 위치로 이동 버튼
                Button(action: {
                    locationManager.moveToCurrentLocation()
                }) {
                    Text("내 위치로 이동")
                        .foregroundColor(.white)
                        .padding()
                        //.background(.green)
                        .background(Color.fromHex("#5fc567") ?? Color.gray) // Hex 색상 설정
                        .cornerRadius(10)
                }
                .padding(.bottom, 20)
            }
            .zIndex(1.0)
        }
        .onAppear {
            selectedCategory = categoryArray[0]
        }
    }
}

#Preview {
    HomeView()
}
// 33683f





// UIColor 확장: hex 문자열을 UIColor로 변환하는 함수
extension UIColor {
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.hasPrefix("#") ? String(hexSanitized.dropFirst()) : hexSanitized

        let length = hexSanitized.count
        var rgb: UInt64 = 0

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        let r, g, b: CGFloat
        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0

            self.init(red: r, green: g, blue: b, alpha: 1.0)
        } else {
            return nil
        }
    }
}

// Color 확장: hex 문자열을 Color로 변환하는 함수 (함수 이름을 변경)
extension Color {
    static func fromHex(_ hex: String) -> Color? {
        guard let uiColor = UIColor(hex: hex) else { return nil }
        return Color(uiColor)
    }
}
