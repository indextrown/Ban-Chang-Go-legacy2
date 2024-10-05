//
//  BanchangoApp.swift
//  Banchango
//
//  Created by 김동현 on 9/8/24.
//

import SwiftUI

@main
struct BanchangoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    

    var body: some Scene {
        WindowGroup {
            AuthenticatedView(authViewModel: .init())
                .onAppear {
                    /*
                    print("디버깅: ")
                    let pharmacyManager = PharmacyManager.shared
                    if let pharmacyInfo = pharmacyManager.getPharmacyInfo(q0: "부산광역시", q1: "남구", pageNo: "1", numOfRows: "10", qn: "약국") {
                        print("약국 이름: \(pharmacyInfo.name)")
                        print("주소: \(pharmacyInfo.address)")
                        print("영업 시간: \(pharmacyInfo.operatingHours)")
                        print()
                    } else {
                        print("약국 정보를 불러오지 못했습니다.")
                    }
                     */
                }
        }
    }
}
 

 
