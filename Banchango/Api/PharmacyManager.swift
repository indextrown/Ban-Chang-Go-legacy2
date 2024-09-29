//
//  Request.swift
//  Banchango
//
//  Created by 김동현 on 9/29/24.
//

//import Foundation

//import SwiftUI

/*
func getmethod() {
    
    // URL 구조체 만들기
    guard let url = URL(string: "http://apis.data.go.kr/B552657/ErmctInsttInfoInqireService/getParmacyListInfoInqire?serviceKey=vYvbOXShpiN13vBxmVUlC0kkxVrD%2B9V3EF7O41ExML40kZenS8KX1KYHEJcXpXhmtUm3WVdxnUWsGmDMjMQRBw%3D%3D&QT=1&QN=일층약국&ORD=NAME&pageNo=1&numOfRows=1&Q0=부산&Q1=남구") else {
        print("Error: cannot create URL")
        return
    }
    
    // URL 요청 생성
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    
    URLSession.shared.dataTask(with: request) { data, response, error in
        // 에러가 없어야 넘어감
        guard error == nil else {
            print("Error: calling GET")
            return
        }
        
        // 옵셔널 바인딩
        guard let safeData = data else {
            print("Error: Did not receive data")
            return
        }
        
        // Http 200번대 정상코드인 경우만 다음 코드로 넘어감
        guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
            print("Error: Http request failed")
            return
        }
        
        // 원하는 모델이 있다면, JsonDecoder로 decode 코드로 구현
        print(String(decoding: safeData, as: UTF8.self))
    }.resume()
}
*/



import Foundation

// 약국 정보 구조체 정의
struct PharmacyInfo {
    var name: String
    var address: String
    var operatingHours: [String: String]
}

// XML 파싱을 위한 델리게이트 클래스
class PharmacyXMLParser: NSObject, XMLParserDelegate {
    private var currentElement = ""
    private var currentPharmacy = PharmacyInfo(name: "", address: "", operatingHours: [:])
    private var pharmacies: [PharmacyInfo] = []
    
    // XML 시작 태그를 만났을 때 호출되는 메서드
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        currentElement = elementName
    }
    
    
            
    
    // XML 태그 내의 값을 발견했을 때 호출되는 메서드
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let trimmedString = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedString.isEmpty else { return }
        
        // 디버깅: 현재 요소와 값을 출력
//        print("Element: \(currentElement), Value: \(trimmedString)")
//        switch currentElement {
//        case "dutyName":
//            currentPharmacy.name += trimmedString
//            print("dutyName matched, name: \(currentPharmacy.name)")
//        case "dutyAddr":
//            currentPharmacy.address += trimmedString
//            print("dutyAddr matched, address: \(currentPharmacy.address)")
//        case "dutyTime1s":
//            currentPharmacy.operatingHours["mon_s"] = trimmedString
//            print("dutyTime1s matched, mon_s: \(currentPharmacy.operatingHours["mon_s"] ?? "")")
//        case "dutyTime1c":
//            currentPharmacy.operatingHours["mon_e"] = trimmedString
//            print("dutyTime1c matched, mon_e: \(currentPharmacy.operatingHours["mon_e"] ?? "")")
//        case "dutyTime2s":
//            currentPharmacy.operatingHours["tue_s"] = trimmedString
//            print("dutyTime2s matched, tue_s: \(currentPharmacy.operatingHours["tue_s"] ?? "")")
//        case "dutyTime2c":
//            currentPharmacy.operatingHours["tue_e"] = trimmedString
//            print("dutyTime2c matched, tue_e: \(currentPharmacy.operatingHours["tue_e"] ?? "")")
//        case "dutyTime3s":
//            currentPharmacy.operatingHours["wed_s"] = trimmedString
//            print("dutyTime3s matched, wed_s: \(currentPharmacy.operatingHours["wed_s"] ?? "")")
//        case "dutyTime3c":
//            currentPharmacy.operatingHours["wed_e"] = trimmedString
//            print("dutyTime3c matched, wed_e: \(currentPharmacy.operatingHours["wed_e"] ?? "")")
//        case "dutyTime4s":
//            currentPharmacy.operatingHours["thu_s"] = trimmedString
//            print("dutyTime4s matched, thu_s: \(currentPharmacy.operatingHours["thu_s"] ?? "")")
//        case "dutyTime4c":
//            currentPharmacy.operatingHours["thu_e"] = trimmedString
//            print("dutyTime4c matched, thu_e: \(currentPharmacy.operatingHours["thu_e"] ?? "")")
//        case "dutyTime5s":
//            currentPharmacy.operatingHours["fri_s"] = trimmedString
//            print("dutyTime5s matched, fri_s: \(currentPharmacy.operatingHours["fri_s"] ?? "")")
//        case "dutyTime5c":
//            currentPharmacy.operatingHours["fri_e"] = trimmedString
//            print("dutyTime5c matched, fri_e: \(currentPharmacy.operatingHours["fri_e"] ?? "")")
//        case "dutyTime6s":
//            currentPharmacy.operatingHours["sat_s"] = trimmedString
//            print("dutyTime6s matched, sat_s: \(currentPharmacy.operatingHours["sat_s"] ?? "")")
//        case "dutyTime6c":
//            currentPharmacy.operatingHours["sat_e"] = trimmedString
//            print("dutyTime6c matched, sat_e: \(currentPharmacy.operatingHours["sat_e"] ?? "")")
//        default:
//            print("No match found for element: \(currentElement)")
//        }

        
        switch currentElement {
        case "dutyName":
            currentPharmacy.name += trimmedString
        case "dutyAddr":
            currentPharmacy.address += trimmedString
        case "dutyTime1s":
            currentPharmacy.operatingHours["mon_s"] = trimmedString
        case "dutyTime1c":
            currentPharmacy.operatingHours["mon_e"] = trimmedString
        case "dutyTime2s":
            currentPharmacy.operatingHours["tue_s"] = trimmedString
        case "dutyTime2c":
            currentPharmacy.operatingHours["tue_e"] = trimmedString
        case "dutyTime3s":
            currentPharmacy.operatingHours["wed_s"] = trimmedString
        case "dutyTime3c":
            currentPharmacy.operatingHours["wed_e"] = trimmedString
        case "dutyTime4s":
            currentPharmacy.operatingHours["thu_s"] = trimmedString
        case "dutyTime4c":
            currentPharmacy.operatingHours["thu_e"] = trimmedString
        case "dutyTime5s":
            currentPharmacy.operatingHours["fri_s"] = trimmedString
        case "dutyTime5c":
            currentPharmacy.operatingHours["fri_e"] = trimmedString
        case "dutyTime6s":
            currentPharmacy.operatingHours["sat_s"] = trimmedString
        case "dutyTime6c":
            currentPharmacy.operatingHours["sat_e"] = trimmedString
        case "dutyTime7s":
            currentPharmacy.operatingHours["sun_s"] = trimmedString
        case "dutyTime7c":
            currentPharmacy.operatingHours["sun_e"] = trimmedString
        default:
            break
        }
        
    }
    
    // XML 종료 태그를 만났을 때 호출되는 메서드
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            pharmacies.append(currentPharmacy)
            currentPharmacy = PharmacyInfo(name: "", address: "", operatingHours: [:])
        }
    }
    
    // 파싱된 약국 정보를 반환하는 메서드
    func getParsedPharmacies() -> [PharmacyInfo] {
        return pharmacies
    }
}

// 싱글톤 패턴을 적용한 약국 정보 관리 서비스

class PharmacyManager {
    // 싱글톤 인스턴스
    static let shared = PharmacyManager()
    
    // private 생성자
    private init() {}
    
    // 약국 정보 요청 함수
    /*
     MARK: - 입력
     url
     key
     qt(진료요일)
     ord(순서)
     qn(기관명)
     q0(주소시도)
     q1(주소시군구)
     
     MARK: - 출력
     주소
     진료시간/요이
     
     */
    func getPharmacyInfo(q0: String, q1: String, pageNo: String, numOfRows: String, qn: String) -> PharmacyInfo? {
        let baseURL = "https://apis.data.go.kr/B552657/ErmctInsttInfoInqireService/getParmacyListInfoInqire"
        let serviceKey = "vYvbOXShpiN13vBxmVUlC0kkxVrD%2B9V3EF7O41ExML40kZenS8KX1KYHEJcXpXhmtUm3WVdxnUWsGmDMjMQRBw%3D%3D"
        let qt = "1"          // 진료요일
        let ord = "NAME"      // 순서
        
        guard let encodedQn = qn.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),         // 기관명
              let encodedQ0 = q0.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),         // 주소(시도)
              let encodedQ1 = q1.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {   // 주소(시군구)
            print("Failed to encode URL parameters.")
            return nil
        }
        
        let urlString = "\(baseURL)?serviceKey=\(serviceKey)&QT=\(qt)&QN=\(encodedQn)&ORD=\(ord)&pageNo=\(pageNo)&numOfRows=\(numOfRows)&Q0=\(encodedQ0)&Q1=\(encodedQ1)"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return nil
        }
        
        let request = URLRequest(url: url)
        var pharmacyInfo: PharmacyInfo?
        let group = DispatchGroup()
        
        group.enter()
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                group.leave()
                return
            }
            
            guard let data = data else {
                print("No data received.")
                group.leave()
                return
            }
            
            let parser = XMLParser(data: data)
            let xmlParserDelegate = PharmacyXMLParser()
            parser.delegate = xmlParserDelegate
            
            if parser.parse(), let parsedPharmacy = xmlParserDelegate.getParsedPharmacies().first {
                pharmacyInfo = parsedPharmacy
            } else {
                print("Failed to parse XML.")
            }
            group.leave()
        }.resume()
        
        group.wait() // 비동기 작업이 완료될 때까지 대기
        return pharmacyInfo
    }
}



//
//class PharmacyManager2 {
//    static let shared = PharmacyManager()
//    private init() {}
//
//    func getPharmacyInfo(q0: String, q1: String, pageNo: String, numOfRows: String, qn: String, completion: @escaping (PharmacyInfo?) -> Void) {
//        let baseURL = "https://apis.data.go.kr/B552657/ErmctInsttInfoInqireService/getParmacyListInfoInqire"
//        let serviceKey = "vYvbOXShpiN13vBxmVUlC0kkxVrD%2B9V3EF7O41ExML40kZenS8KX1KYHEJcXpXhmtUm3WVdxnUWsGmDMjMQRBw%3D%3D"
//        let qt = "1"
//        let ord = "NAME"
//        
//        guard let encodedQn = qn.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
//              let encodedQ0 = q0.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
//              let encodedQ1 = q1.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
//            print("Failed to encode URL parameters.")
//            completion(nil)
//            return
//        }
//        
//        let urlString = "\(baseURL)?serviceKey=\(serviceKey)&QT=\(qt)&QN=\(encodedQn)&ORD=\(ord)&pageNo=\(pageNo)&numOfRows=\(numOfRows)&Q0=\(encodedQ0)&Q1=\(encodedQ1)"
//        
//        guard let url = URL(string: urlString) else {
//            print("Invalid URL")
//            completion(nil)
//            return
//        }
//        
//        let request = URLRequest(url: url)
//        
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                print("Error: \(error.localizedDescription)")
//                completion(nil)
//                return
//            }
//            
//            guard let data = data else {
//                print("No data received.")
//                completion(nil)
//                return
//            }
//            
//            let parser = XMLParser(data: data)
//            let xmlParserDelegate = PharmacyXMLParser()
//            parser.delegate = xmlParserDelegate
//            
//            if parser.parse(), let parsedPharmacy = xmlParserDelegate.getParsedPharmacies().first {
//                completion(parsedPharmacy)
//            } else {
//                print("Failed to parse XML.")
//                completion(nil)
//            }
//        }.resume()
//    }
//}
//
