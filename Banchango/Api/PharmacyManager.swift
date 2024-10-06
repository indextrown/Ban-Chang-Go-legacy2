//
//  Request.swift
//  Banchango
//
//  Created by 김동현 on 9/29/24.
//

import Foundation

// MARK: - 특정 약국 영업시간 확인

// 약국 정보 구조체 정의
struct PharmacyInfo {
    var name: String
    var address: String
    var phoneNumber: String // 전화번호 필드 추가
    var operatingHours: [String: String]
}

// XML 파싱을 위한 델리게이트 클래스
class PharmacyXMLParser: NSObject, XMLParserDelegate {
    private var currentElement = ""
    private var currentPharmacy = PharmacyInfo(name: "", address: "", phoneNumber: "", operatingHours: [:])
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
        switch currentElement {
        case "dutyName":
            currentPharmacy.name += trimmedString
        case "dutyAddr":
            currentPharmacy.address += trimmedString
        case "dutyTel1": // 전화번호 태그 처리
            currentPharmacy.phoneNumber += trimmedString
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
            currentPharmacy = PharmacyInfo(name: "", address: "", phoneNumber: "", operatingHours: [:])
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
    
    func getPharmacyInfo_async(q0: String, q1: String, pageNo: String, numOfRows: String, qn: String) async -> PharmacyInfo? {
            let baseURL = "https://apis.data.go.kr/B552657/ErmctInsttInfoInqireService/getParmacyListInfoInqire"
            let serviceKey = "vYvbOXShpiN13vBxmVUlC0kkxVrD%2B9V3EF7O41ExML40kZenS8KX1KYHEJcXpXhmtUm3WVdxnUWsGmDMjMQRBw%3D%3D"
            let qt = "1"
            let ord = "NAME"

            guard let encodedQn = qn.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                  let encodedQ0 = q0.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                  let encodedQ1 = q1.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                print("Failed to encode URL parameters.")
                return nil
            }

            let urlString = "\(baseURL)?serviceKey=\(serviceKey)&QT=\(qt)&QN=\(encodedQn)&ORD=\(ord)&pageNo=\(pageNo)&numOfRows=\(numOfRows)&Q0=\(encodedQ0)&Q1=\(encodedQ1)"

            guard let url = URL(string: urlString) else {
                print("Invalid URL")
                return nil
            }

            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let parser = XMLParser(data: data)
                let xmlParserDelegate = PharmacyXMLParser()
                parser.delegate = xmlParserDelegate

                if parser.parse(), let parsedPharmacy = xmlParserDelegate.getParsedPharmacies().first {
                    return parsedPharmacy
                } else {
                    print("Failed to parse XML.")
                    return nil
                }
            } catch {
                print("Error: \(error.localizedDescription)")
                return nil
            }
        }
    
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
