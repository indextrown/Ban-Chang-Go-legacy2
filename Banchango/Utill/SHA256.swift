//
//  SHA256.swift
//  Banchango
//
//  Created by 김동현 on 9/9/24.
//

import Foundation
import CryptoKit

// String을 암호화
func sha256(_ input: String) -> String {
    let inputData = Data(input.utf8)
    let hashedData = SHA256.hash(data: inputData)
    let hashString = hashedData.compactMap {
        String(format: "%02x", $0)
    }.joined()
    
    return hashString
}
