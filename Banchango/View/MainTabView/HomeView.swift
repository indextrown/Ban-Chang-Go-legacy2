import SwiftUI
import MapKit
import CoreLocation

// LocationManager: 사용자 위치를 관리하는 클래스
final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()
    
    // 사용자 위치가 처음 업데이트될 때만 카메라 위치를 업데이트하기 위해 플래그 추가
    private var isFirstUpdate = true
    
    @Published var position: MapCameraPosition = .automatic
    
    // MARK: - 현재 지도의 영역(중심 좌표와 범위)
    @Published var region = MKCoordinateRegion()

    // 디바운스를 위한 작업 항목
    private var debounceWorkItem: DispatchWorkItem?
    
    // 약국 데이터를 저장하는 배열
    @Published var pharmacies: [PharmacyPlace] = []

    // 약국 정보를 저장하는 딕셔너리 (이름 + 주소를 key로 사용)
    private var pharmacyDictionary: [String: PharmacyPlace] = [:]

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        DispatchQueue.global(qos: .userInitiated).async {
            if let location = locations.first, self.isFirstUpdate {
                let camera = MapCamera(centerCoordinate: location.coordinate, distance: 5000, heading: 0, pitch: 0)
                
                // 메인 스레드에서 카메라 업데이트
                DispatchQueue.main.async {
                    self.position = .camera(camera)
                    self.isFirstUpdate = false
                    
                    self.region = MKCoordinateRegion(
                        center: location.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    )
                }
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("위치 업데이트 실패: \(error.localizedDescription)")
    }
    
    func moveToCurrentLocation() {
        DispatchQueue.global(qos: .background).async { // 백그라운드에서 위치 가져오기
            guard let location = self.locationManager.location else { return }

            DispatchQueue.main.async { // 메인 스레드에서 UI 업데이트
                self.position = .camera(MapCamera(centerCoordinate: location.coordinate, distance: 5000))
            }
        }
    }
    
    // 약국 데이터를 기반으로 주변 장소를 추가하는 함수 (비동기 처리 추가)
    func addNearbyPlaces(pharmacies: [Pharmacy]) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return } // self의 메모리 문제 방지

            var newPlaces: [PharmacyPlace] = []

            for pharmacy in pharmacies {
                let key = "\(pharmacy.name) \(pharmacy.address)"
            
                let string = pharmacy.address.components(separatedBy: " ")

                if self.pharmacyDictionary[key] == nil {
                    var newPlace = PharmacyPlace(
                        coordinate: CLLocationCoordinate2D(
                            latitude: pharmacy.latitude,
                            longitude: pharmacy.longitude
                        ),
                        name: pharmacy.name,
                        address: pharmacy.address
                    )

                    // 새로운 장소를 딕셔너리에 추가
                    self.pharmacyDictionary[key] = newPlace
                    newPlaces.append(newPlace)
                    
                    DispatchQueue.global().async {
                        let pharmacyManager = PharmacyManager.shared
                        if let pharmacyInfo = pharmacyManager.getPharmacyInfo(q0: string[0], q1: string[1], pageNo: "1", numOfRows: "10", qn: pharmacy.name) {
//                            print("약국 이름: \(pharmacyInfo.name)")
//                            print("주소: \(pharmacyInfo.address)")
//                            print("영업 시간: \(pharmacyInfo.operatingHours)")
//                            print()
                            
                            // 새로운 약국 정보가 있으면 해당 약국 정보 업데이트
                            DispatchQueue.main.async {
                                // 약국 정보를 업데이트하고 UI 갱신
                                newPlace.pharmacyInfo = pharmacyInfo
                                self.pharmacyDictionary[key] = newPlace

                                if let index = self.pharmacies.firstIndex(where: { $0.id == newPlace.id }) {
                                    self.pharmacies[index].pharmacyInfo = pharmacyInfo
                                } else {
                                    self.pharmacies.append(newPlace)
                                }
                                
                                // selectedPlace를 다시 설정해 모달 업데이트
                                if self.pharmacies.contains(where: { $0.id == newPlace.id }) {
                                    self.pharmacies.append(newPlace)
                                }
                            }
                        }
                    }
                }
            }

            // UI 업데이트는 메인 스레드에서 수행
            DispatchQueue.main.async {
                self.pharmacies.append(contentsOf: newPlaces)
                //print("UI 업데이트 완료: \(newPlaces.count)개의 새로운 장소 추가됨.")
            }
        }
    }

    func addNearbyPlaces_legacy(pharmacies: [Pharmacy]) {
        var newPlaces: [PharmacyPlace] = []

        for pharmacy in pharmacies {
            let key = "\(pharmacy.name) \(pharmacy.address)"

            if self.pharmacyDictionary[key] == nil {
                let newPlace = PharmacyPlace(
                    coordinate: CLLocationCoordinate2D(
                        latitude: pharmacy.latitude,
                        longitude: pharmacy.longitude
                    ),
                    name: pharmacy.name,
                    address: pharmacy.address
                )

                // 새로운 장소를 딕셔너리에 추가
                self.pharmacyDictionary[key] = newPlace
                newPlaces.append(newPlace)
            }
        }

        // UI 업데이트는 메인 스레드에서 수행
        DispatchQueue.main.async {
            self.pharmacies.append(contentsOf: newPlaces)
            //print("UI 업데이트 완료: \(newPlaces.count)개의 새로운 장소 추가됨.")
        }
    }
    
}











// HomeView: 지도와 UI 요소를 포함한 뷰
struct HomeView: View {
    @StateObject private var locationManager = LocationManager()  // 사용자 위치를 관리하는 LocationManager 인스턴스
    @State private var searchText: String = ""                    // 검색어 상태 변수
    let categoryArray = ["약국", "응급실"]                          // 카테고리 배열
    @State private var selectedCategory: String?                  // 선택된 카테고리 추적 상태 변수
    @State private var selectedPlace: PharmacyPlace?                         // 사용자가 선택할 장소를 저장하는 상태 변수
    @State private var debounceWorkItem: DispatchWorkItem?  // 여기 추가
    
    var body: some View {
        ZStack {
            // 지도에 마커를 추가 (약국 위치 표시)
            Map(position: $locationManager.position) {
                UserAnnotation()
                
                // 마커에 커스텀 Annotation 사용
                ForEach(locationManager.pharmacies) { pharmacy in
                    Annotation("", coordinate: pharmacy.coordinate) {
                        Button(action: {
                            selectedPlace = pharmacy   // 사용자가 마커를 클릭하면 해당 장소를 선택
                            //loadPharmacyInfo(for: pharmacy)  // 클릭 시 비동기 약국 정보 로드
                        }) {
                            Image(systemName: "pill.circle")
                                .resizable()
                                .foregroundColor(.red)                  // 마커 색상 설정
                                .background(Circle().fill(.white))      // 마커 배경 설정
                                .frame(width: 30, height: 30)           // 마커 크기 설정
                                .shadow(radius: 4)                      // 그림자 추가
                        }
                    }
                }
            }
            .onMapCameraChange { context in
                // 이전에 실행된 디바운스 작업 취소
                debounceWorkItem?.cancel()
                
                // 새로운 디바운스 작업 생성 (0.5초 동안 추가 요청 없으면 실행)
                debounceWorkItem = DispatchWorkItem {
                    
                    Task {
                        // 카메라의 현재 위치에서 중심 좌표 가져오기
                        let center = context.camera.centerCoordinate
                        
                        // API로부터 약국 정보 받아오기
                        let result = await PharmacyService.shared.getNearbyPharmacies(latitude: center.latitude, longitude: center.longitude)
                        
                        switch result {
                        case .success(let fetchedPharmacies):
                            // 새로운 약국 데이터를 기반으로 장소를 추가
                            locationManager.addNearbyPlaces(pharmacies: fetchedPharmacies)
                            //print("성공적으로 호출 완료")
                        case .failure(let error):
                            print("API 오류: \(error)")
                        }
                    }
                }
                // 0.5초 후에 작업 실행
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: debounceWorkItem!)
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
                        .background(Color.fromHex("#5CC87D")!) // Hex 색상 설정
                        .cornerRadius(10)
                }
                .padding(.bottom, 20)
            }
            .zIndex(1.0)
        }
        .onAppear {
            selectedCategory = categoryArray[0]
        }

        .sheet(item: $selectedPlace) { place in
            // 선택된 장소가 있을 경우 모달 뷰를 표시
            HalfModalView(place: place)
                .presentationDetents([.fraction(0.5)])  // 모달 뷰가 화면의 절반만 차지하도록 설정
        }
    }
    
    // 비동기적으로 약국 정보를 로드하는 함수
    /*
    func loadPharmacyInfo(for place: PharmacyPlace) {
        //isLoading = true  // 로딩 시작
        Task {
            if place.pharmacyInfo == nil {  // 약국 정보가 없을 때만 로드
                
                // print("tt\(place.address)")
                let string = place.address.components(separatedBy: " ")
                
                let info = PharmacyManager.shared.getPharmacyInfo(q0: string[0], q1: string[1], pageNo: "1", numOfRows: "1", qn: place.name)
//                print("약국 이름: \(String(describing: info?.name))")
//                print("주소: \(String(describing: info?.address))")
//                print("영업 시간: \(String(describing: info?.operatingHours))")
//                
//                
                // 메인 스레드에서 약국 정보를 업데이트
//                DispatchQueue.main.async {
//                    if let info = info {
//                                    print("약국 정보 로드 성공: \(info.name)")
//                                } else {
//                                    print("약국 정보 로드 실패: nil 반환")
//                                }
//                    
//                    if let index = locationManager.pharmacies.firstIndex(where: { $0.id == place.id }) {
//                        locationManager.pharmacies[index].pharmacyInfo = info
//                        
//                        // `selectedPlace`를 다시 설정해 뷰가 업데이트되도록 만듦
//                        selectedPlace = locationManager.pharmacies[index]
//                    }
//                    
//                    
//                }
            }
        }
    }
     */
}

#Preview {
    HomeView()
}

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

// 이미지를 원형으로 보여주는 뷰
struct CircleImage: View {
    var body: some View {
        Image("Cat")
            .clipShape(Circle())
    }
}

// 선택된 장소를 보여주는 모달 뷰
// 선택된 장소를 보여주는 모달 뷰
struct HalfModalView: View {
    var place: PharmacyPlace
    
    var body: some View {
        VStack {
            if let info = place.pharmacyInfo {
                HStack {
                    // 약국 정보가 있을 때 표시
                    Text(place.name)
                        .fontWeight(.bold) // 볼드 설정
                        .font(.system(size: 24))
                    Spacer()
                }
                
                Spacer()
                    .frame(height: 10)
                
                HStack {
                    // 약국 정보가 있을 때 표시
                    Text(info.address)
                        .font(.system(size: 15))
                    Spacer()
                }
                
                HStack {
                    // 약국 정보가 있을 때 표시
                    Text(info.phoneNumber)
                        .font(.system(size: 15))
                    Spacer()
                }
                
                Spacer()
                    .frame(height: 20)
                
                Text("영업 시간: \(info.operatingHours)")
            } else {
                // 약국 정보가 없을 때
                Text("약국 정보를 불러올 수 없습니다.")
                Text("장소 이름: \(place.name)")
                    .font(.headline)
                Text("위도: \(place.coordinate.latitude)")
                Text("경도: \(place.coordinate.longitude)")
                
            }
            Spacer()
        }
        .padding()
        .background(.white)
        .cornerRadius(20)
    }
}

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

// PharmacyPlace 구조체: 약국 위치를 나타내는 데이터 모델
struct PharmacyPlace: Identifiable {
    let id = UUID()  // 'Identifiable'을 만족하는 고유 식별자
    let coordinate: CLLocationCoordinate2D
    let name: String
    let address: String
    
    var pharmacyInfo: PharmacyInfo?     // 비동기적으로 받아오는 약국 정보(영업시간 등)
    
    // 초기에는 약국 정보가 없으므로 nil로 설정
    init(coordinate: CLLocationCoordinate2D, name: String, address: String,pharmacyInfo: PharmacyInfo? = nil) {
        self.coordinate = coordinate
        self.name = name
        self.address = address
        self.pharmacyInfo = pharmacyInfo
    }
}


