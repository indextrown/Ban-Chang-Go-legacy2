//
//  PharmacyService.swift
//  Banchango
//
//  Created by 김동현 on 9/30/24.
//

// MARK: - 주변 반경 약국 찾기
import Foundation
import CoreLocation

// JSON 응답 구조에 맞는 Codable 구조체 정의
struct PharmacyResponse: Codable {
    let documents: [Pharmacy]
}

struct Pharmacy: Codable {
    let name: String
    let latitude: Double
    let longitude: Double
    let address: String
    let city: [String] // 시, 군 정보를 배열로 변경합니다.
    
    enum CodingKeys: String, CodingKey {
        case name = "place_name"
        case latitude = "y"
        case longitude = "x"
        case address = "address_name"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        
        let latitudeString = try container.decode(String.self, forKey: .latitude)
        if let latitudeValue = Double(latitudeString) {
            latitude = latitudeValue
        } else {
            throw DecodingError.dataCorruptedError(forKey: .latitude, in: container, debugDescription: "Invalid latitude value")
        }
        
        let longitudeString = try container.decode(String.self, forKey: .longitude)
        if let longitudeValue = Double(longitudeString) {
            longitude = longitudeValue
        } else {
            throw DecodingError.dataCorruptedError(forKey: .longitude, in: container, debugDescription: "Invalid longitude value")
        }
        
        address = try container.decode(String.self, forKey: .address)
        
        // 주소에서 시, 군 정보를 추출하여 배열에 저장합니다.
        let addressComponents = address.split(separator: " ")
        if addressComponents.count > 1 {
            city = addressComponents.prefix(2).map { String($0) } // 첫 두 요소를 시, 군으로 가정합니다.
        } else {
            city = ["정보 없음"] // 시, 군 정보가 없을 경우
        }
    }
}

enum APIError: Error {
    case invalidURL
    case requestFailed
    case noData
    case decodingError
}

// 싱글톤 패턴을 적용한 서비스 클래스
class PharmacyService {
    // 싱글톤 인스턴스
    static let shared = PharmacyService()
    
    // private 생성자
    private init() {}
    
    // 약국 정보 요청 함수
    func getNearbyPharmacies(latitude: Double, longitude: Double) async -> Result<[Pharmacy], APIError> {
        let apiKey = "f755f389dc23ec846d0a0d6c5f294536" // 발급받은 API 키
        let radius = 1000 // 검색 반경 (미터 단위)
        let urlString = "https://dapi.kakao.com/v2/local/search/category.json?category_group_code=PM9&x=\(longitude)&y=\(latitude)&radius=\(radius)"
        
        guard let url = URL(string: urlString) else {
            return .failure(.invalidURL)
        }
        
        var request = URLRequest(url: url)
        request.setValue("KakaoAK \(apiKey)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let pharmacyResponse = try JSONDecoder().decode(PharmacyResponse.self, from: data)
            return .success(pharmacyResponse.documents)
        } catch {
            if let urlError = error as? URLError {
                switch urlError.code {
                case .notConnectedToInternet, .networkConnectionLost:
                    return .failure(.requestFailed)
                default:
                    break
                }
            }
            return .failure(.decodingError)
        }
    }
    
    // 거리 계산 함수
    func distance(from location1: CLLocation, to location2: CLLocation) -> CLLocationDistance {
        return location1.distance(from: location2)
    }
}


//
//
//
//// 사용 예시
//func test() {
//   
//    Task {
//        // 현재위치로 가정(추후에 위치변경되면 동적으로 위치지정)
//        let currentLatitude = 35.13753139104897      // 위도
//        let currentLongitude = 129.10161339412642    // 경도
//        let currentLocation = CLLocation(latitude: currentLatitude, longitude: currentLongitude)
//        
//        let result = await PharmacyService.shared.getNearbyPharmacies(latitude: currentLatitude, longitude: currentLongitude)
//        switch result {
//        case .success(let pharmacies):
//            
//            // 거리 정보를 포함한 튜플 배열을 생성합니다.
//            let pharmaciesWithDistances = pharmacies.map { pharmacy in
//                let pharmacyLocation = CLLocation(latitude: pharmacy.latitude, longitude: pharmacy.longitude)
//                let distance = PharmacyService.shared.distance(from: currentLocation, to: pharmacyLocation)
//                return (pharmacy: pharmacy, distance: distance)
//            }
//            
//            // 거리를 기준으로 오름차순 정렬합니다.
//            let sortedPharmacies = pharmaciesWithDistances.sorted { $0.distance < $1.distance }
//            
//            // 정렬된 약국을 출력합니다.
//            for item in sortedPharmacies {
//                let pharmacy = item.pharmacy
//                let infoArray = getPharmacyInfo(
//                    city: pharmacy.city[0],
//                    district: pharmacy.city[1],
//                    name: pharmacy.name,
//                    latitude: pharmacy.latitude,        // 위도
//                    longitude: pharmacy.longitude)      // 경도
//                
//                for info in infoArray {
//                    print(info)
//                }
//                
//                //print(infoArray)
//                print()
//            }
//            
//        case .failure(let error):
//            switch error {
//            case .invalidURL:
//                print("Invalid URL")
//            case .requestFailed:
//                print("Request failed")
//            case .noData:
//                print("No data received")
//            case .decodingError:
//                print("Failed to decode JSON")
//            }
//        }
//    }
//}




//
//
//// 이름으로 운영정보 찾기
//func getPharmacyInfo(city: String, district: String, name: String, latitude: Double, longitude: Double) -> [String] {
//    let pharmacyInfoList = PharmacyManager.shared.getPharmacyInfo(
//        q0: city,
//        q1: district,
//        pageNo: "1",
//        numOfRows: "1",
//        qn: name)
//    
//    // 결과를 저장할 배열
//    var results: [String] = []
//
//    // 결과 배열에 추가
//    if !pharmacyInfoList.isEmpty {
//        results.append("이름: \(pharmacyInfoList[0].name)")
//        results.append("주소: \(pharmacyInfoList[0].address)")
//        results.append("위도: \(latitude)")
//        results.append("경도: \(longitude)")
//        
//        for day in dayOrder {
//            if let startTime = pharmacyInfoList[0].operatingHours["\(day)_s"], let endTime = pharmacyInfoList[0].operatingHours["\(day)_e"] {
//                results.append("\(day) 시작: \(startTime) 종료: \(endTime)")
//            }
//        }
//    }
//    return results
//}
