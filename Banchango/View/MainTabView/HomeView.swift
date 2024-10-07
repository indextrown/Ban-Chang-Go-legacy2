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
    
    // 약국 영업 상태를 캐시하는 딕셔너리
    private var openStatusCache: [UUID: Bool] = [:]

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

    // MARK: - 비동기
    /*
    func addNearbyPlaces_비동기함수(pharmacies: [Pharmacy]) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

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
                    
                    // 비동기적으로 영업 상태 가져오기
                    DispatchQueue.global().async {
                        let pharmacyManager = PharmacyManager.shared
                        let string = pharmacy.address.components(separatedBy: " ")
                        if let pharmacyInfo = pharmacyManager.getPharmacyInfo(q0: string[0], q1: string[1], pageNo: "1", numOfRows: "10", qn: pharmacy.name) {
                            DispatchQueue.main.async {
                                
//                                newPlace.pharmacyInfo = pharmacyInfo
//                                let today = getDay(from: Date())
//                                let hours = operatingHours(for: today, operatingHours: pharmacyInfo.operatingHours)
//                                newPlace.isOpen = isOpenNow(startTime: hours.start, endTime: hours.end)
                                
                                // UI 갱신
                                self.pharmacyDictionary[key] = newPlace
                                if let index = self.pharmacies.firstIndex(where: { $0.id == newPlace.id }) {
                                    self.pharmacies[index] = newPlace
                                } else {
                                    self.pharmacies.append(newPlace)
                                }
                            }
                        }
                    }
                }
            }
            
            // UI 업데이트를 배치로 처리
            self.batchUpdateUI(with: newPlaces, batchSize: 10)
        }
    }
     */
     
    // 배치로 UI 업데이트를 수행하는 함수
    func batchUpdateUI(with places: [PharmacyPlace], batchSize: Int) {
        var index = 0
        
        func updateBatch() {
            let end = min(index + batchSize, places.count)
            let batch = places[index..<end]
            
            DispatchQueue.main.async {
                self.pharmacies.append(contentsOf: batch)
            }
            
            index += batchSize
            
            if index < places.count {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    updateBatch()
                }
            }
        }
        
        updateBatch()
    }

    // MARK: - 비동기끛
    func addNearbyPlaces(pharmacies: [Pharmacy]) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return } // self의 메모리 문제 방지

            var newPlaces: [PharmacyPlace] = []

            for pharmacy in pharmacies {
                
                // 주소의 첫 번째 부분을 확인하여 "경남", "경북"을 변환
                var modifiedAddress = pharmacy.address
                let addressComponents = pharmacy.address.components(separatedBy: " ")
                
                if let firstComponent = addressComponents.first {
                    switch firstComponent {
                    case "경남":
                        modifiedAddress = pharmacy.address.replacingOccurrences(of: "경남", with: "경상남도")
                    case "경북":
                        modifiedAddress = pharmacy.address.replacingOccurrences(of: "경북", with: "경상북도")
                    default:
                        break
                    }
                }
                
                
                let key = "\(pharmacy.name) \(pharmacy.address)"
                let string = modifiedAddress.components(separatedBy: " ")
                //let string = pharmacy.address.components(separatedBy: " ")
                //print("string변수 디버깅: \(string)")

                if self.pharmacyDictionary[key] == nil {
                    var newPlace = PharmacyPlace(
                        coordinate: CLLocationCoordinate2D(
                            latitude: pharmacy.latitude,
                            longitude: pharmacy.longitude
                        ),
                        name: pharmacy.name,
                        address: pharmacy.address,
                        roadAddress: pharmacy.roadAddress,
                        phone: pharmacy.phone
                        
                    )
                    
                    //print("디버깅: \(newPlace.name) \(String(describing: newPlace.isOpen))")

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
                                
                                // MARK: -

                                //print("프린트: \(newPlace.isOpen)")

                                if let index = self.pharmacies.firstIndex(where: { $0.id == newPlace.id }) {
                                    self.pharmacies[index].pharmacyInfo = pharmacyInfo
                                
                                    let today = getDay(from: Date())
                                    let hours = operatingHours(for: today, operatingHours: pharmacyInfo.operatingHours)
                                    print("시간확인: \(hours)")
                                    self.pharmacies[index].isOpen = isOpenNow(startTime: hours.start, endTime: hours.end)
                                    
                                    print("디버깅완료: \(newPlace.name) \(self.pharmacies[index].isOpen)")
                                    
                                    
                                    //self.pharmacies[index].isOpen = isOpenNow(startTime: hours.start, endTime: hours.end)
                                } else {
                                    self.pharmacies.append(newPlace)
                                }
                                
                                
                                // 상태가 변경되었으므로 뷰가 리렌더링되도록 상태를 명시적으로 업데이트
                                self.objectWillChange.send()
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

    // 약국이 영업 중인지 확인하는 함수
    func checkIfOpenAsync(pharmacy: PharmacyPlace, completion: @escaping (Bool) -> Void) {
        
        // 캐시된 값이 있으면 해당 값 반환
        if let cachedStatus = openStatusCache[pharmacy.id] {
            completion(cachedStatus)
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            guard let pharmacyInfo = pharmacy.pharmacyInfo else {
                DispatchQueue.main.async {
                    completion(false)  // 기본적으로 닫혀있는 상태
                }
                return
            }
            
            let today = getDay(from: Date())
            let hours = operatingHours(for: today, operatingHours: pharmacyInfo.operatingHours)
            let isOpen = isOpenNow(startTime: hours.start, endTime: hours.end)
            
            DispatchQueue.main.async {
                completion(isOpen)  // 계산된 영업 상태를 전달
            }
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
                    //let isOpen = pharmacy.isOpen ?? false // 캐싱된 값을 사용
                    
                    Annotation("", coordinate: pharmacy.coordinate) {
                        Button(action: {
                            selectedPlace = pharmacy   // 사용자가 마커를 클릭하면 해당 장소를 선택
                            //loadPharmacyInfo(for: pharmacy)  // 클릭 시 비동기 약국 정보 로드
                        }) {
                            Image(systemName: "pill.circle")
                                .resizable()
                                .foregroundColor(pharmacy.isOpen == true ? .red : .gray)  // 영업 상태에 따라 마커 색상 변경
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
                .presentationDetents([.fraction(0.2)])  // 모달 뷰가 화면의 절반만 차지하도록 설정
        }
    }
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
struct HalfModalView: View {
    var place: PharmacyPlace

    var body: some View {
        VStack {
            if let info = place.pharmacyInfo {
                HStack {
                    // 약국 이름
                    Text(place.name)
                        .fontWeight(.bold) // 볼드 설정
                        .font(.system(size: 24))
                    Spacer()
                                        
                    // 영업시간을 현재시간과 비교
                    if place.isOpen == true {
                        Text("운영중")
                            .foregroundColor(.red)
                    } else {
                        Text("영업 종료")
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                    .frame(height: 10)
                               
                HStack {
                    let today = getDay(from: Date())
                    let hours = operatingHours(for: today, operatingHours: info.operatingHours)
                    
                    // 약국 정보가 있을 때 표시
                    Text("\(hours.start) ~ \(hours.end)")
                        .font(.system(size: 15))
                    Spacer()
                }
                
                Spacer()
                    .frame(height: 5)
                
                HStack {
                    // 약국 정보가 있을 때 표시
                    Text(info.address)
                        .font(.system(size: 15))
                    Spacer()
                }
                
                Spacer()
                    .frame(height: 5)
                
                HStack {
                    // 약국 정보가 있을 때 표시
                    Text(info.phoneNumber)
                        .font(.system(size: 15))
                    Spacer()
                }
                
                
            } else {
                // 약국 정보가 없을 때
                HStack {
                    Text(place.name)
                        .fontWeight(.bold) // 볼드 설정
                        .font(.system(size: 24))
                    Spacer()
                    
                    Text("정보 미제공")
                        .foregroundColor(.red)
                }
                
                Spacer()
                    .frame(height: 10)
                
                HStack {
                    // 약국 정보가 있을 때 표시
                    Text(place.address)
                        .font(.system(size: 15))
                    Spacer()
                }
                
                Spacer()
                    .frame(height: 5)
                
                HStack {
                    // 약국 정보가 있을 때 표시
                    Text(String(describing: place.phone))
                        .font(.system(size: 15))
                    Spacer()
                }
                
                
                /*
                Text("위도: \(place.coordinate.latitude)")
                Text("경도: \(place.coordinate.longitude)")
                 */
            }
            Spacer()
        }
        .onAppear {
           
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
    var pharmacyInfo: PharmacyInfo?      // 비동기적으로 받아오는 약국 정보(영업시간 등)
    var isOpen: Bool = false             // 영업 상태를 캐시하는 변수 추가
    let roadAddress: String             // 도로명 주소 추가
    let phone: String
    
    // 초기에는 약국 정보가 없으므로 nil로 설정
    init(coordinate: CLLocationCoordinate2D, name: String, address: String,pharmacyInfo: PharmacyInfo? = nil, roadAddress: String, phone: String) {
        self.coordinate = coordinate
        self.name = name
        self.address = address
        self.pharmacyInfo = pharmacyInfo
        self.roadAddress = roadAddress
        self.phone = phone
    }
}

// 요일 확인
func getDay(from date: Date) -> String {
    let dateFormatter = DateFormatter()
    
    dateFormatter.locale = Locale(identifier: "ko_KR") // 한국어로 요일
    dateFormatter.dateFormat = "EEEE" // 요일을 '월요일', '화요일' 등의 형태로 표시
    let day = dateFormatter.string(from: date)
    return day
}

// 시간을 "1100" -> "11:00" 형식으로 변환
func formatTime(_ time: String) -> String {
    guard time.count == 4 else { return time }
    let hour = time.prefix(2)
    let minute = time.suffix(2)
    return "\(hour):\(minute)"
}

// 요일에 따른 영업시간 매칭
func operatingHours(for day: String, operatingHours: [String: String]) -> (start: String, end: String) {
        switch day {
        case "월요일":
            return (formatTime(operatingHours["mon_s"] ?? "정보 없음"), formatTime(operatingHours["mon_e"] ?? "정보 없음"))
        case "화요일":
            return (formatTime(operatingHours["tue_s"] ?? "정보 없음"), formatTime(operatingHours["tue_e"] ?? "정보 없음"))
        case "수요일":
            return (formatTime(operatingHours["wed_s"] ?? "정보 없음"), formatTime(operatingHours["wed_e"] ?? "정보 없음"))
        case "목요일":
            return (formatTime(operatingHours["thu_s"] ?? "정보 없음"), formatTime(operatingHours["thu_e"] ?? "정보 없음"))
        case "금요일":
            return (formatTime(operatingHours["fri_s"] ?? "정보 없음"), formatTime(operatingHours["fri_e"] ?? "정보 없음"))
        case "토요일":
            return (formatTime(operatingHours["sat_s"] ?? "정보 없음"), formatTime(operatingHours["sat_e"] ?? "정보 없음"))
        case "일요일":
            return (formatTime(operatingHours["sun_s"] ?? "정보 없음"), formatTime(operatingHours["sun_e"] ?? "정보 없음"))
        default:
            return ("정보 없음", "정보 없음")
        }
    }


// String을 Date 객체로 변환하는 함수
//func timeStringToDate(_ timeString: String) -> Date? {
//    let dateFormatter = DateFormatter()
//    dateFormatter.dateFormat = "HH:mm"
//    return dateFormatter.date(from: timeString)
//}
//func timeStringToDate(_ timeString: String) -> Date? {
//    // 시간 문자열이 4자리여야 함 ("0900", "1900" 등)
//    guard timeString.count == 5 else {
//        print("잘못된 시간 형식: \(timeString)")
//        return nil
//    }
//    
//    // 현재 날짜를 가져옴
//    let today = Date()
//    let dateFormatter = DateFormatter()
//    dateFormatter.dateFormat = "yyyy-MM-dd" // 현재 날짜의 포맷
//    let dateString = dateFormatter.string(from: today)
//    
//    // 현재 날짜와 시간을 결합한 문자열을 만듦
//    let dateTimeString = "\(dateString) \(timeString)"
//    
//    // 최종적으로 "yyyy-MM-dd HH:mm" 형식으로 변환
//    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
//    
//    let date = dateFormatter.date(from: dateTimeString)
//    //print("변환된 시간: \(dateTimeString) -> \(String(describing: date))") // 디버깅용
//    return date
//}

func timeStringToDate(_ timeString: String) -> Date? {
    let timeComponents = timeString.components(separatedBy: ":")
    guard timeComponents.count == 2,
          let hour = Int(timeComponents[0]),
          let minute = Int(timeComponents[1]) else {
        print("잘못된 시간 형식: \(timeString)")
        return nil
    }
    
    // 만약 시간이 24시를 넘는다면, 이를 다음날 시간으로 변환
    var adjustedHour = hour
    if hour >= 24 {
        adjustedHour = hour - 24
    }

    // 현재 날짜를 가져옴
    let today = Date()
    let calendar = Calendar.current

    // 날짜 컴포넌트를 설정하고, 시간이 24시를 넘는 경우 하루를 더해줌
    var dateComponents = calendar.dateComponents([.year, .month, .day], from: today)
    if hour >= 24 {
        dateComponents.day! += 1
    }
    dateComponents.hour = adjustedHour
    dateComponents.minute = minute

    let date = calendar.date(from: dateComponents)
    //print("변환된 시간: \(timeString) -> \(String(describing: date))") // 디버깅용
    return date
}



// 현재 시간과 영업 시간을 비교하는 함수
func isOpenNow(startTime: String, endTime: String) -> Bool {
    let currentTime = Date() // 현재 시간
    guard let startDate = timeStringToDate(startTime),
          let endDate = timeStringToDate(endTime) else {
        return false
    }
    
    //print("현재 시간: \(currentTime), 시작 시간: \(startDate), 종료 시간: \(endDate)")
    
    // 영업 종료 시간이 자정을 넘어가는 경우 처리
    if endDate < startDate {
        // 현재 시간이 영업 시작보다 이후이거나, 자정을 넘은 시간을 처리
        return currentTime >= startDate || currentTime <= endDate
    } else {
        // 일반적인 경우, 시작 시간과 종료 시간 사이에 있는지 확인
        return currentTime >= startDate && currentTime <= endDate
    }
}


