//
//  PharmacyService.swift
//  Banchango
//
//  Created by 김동현 on 9/30/24.
//

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
