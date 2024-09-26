//
//  SceleDelegate.swift
//  Banchango
//
//  Created by 김동현 on 9/9/24.
//

import Foundation
import KakaoSDKAuth
import UIKit

// MyappDelegate에서 SceneDelegate 클래스를 사용하도록 confiration 설정 필요
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            if (AuthApi.isKakaoTalkLoginUrl(url)) {
                _ = AuthController.handleOpenUrl(url: url)
            }
        }
    }
}
