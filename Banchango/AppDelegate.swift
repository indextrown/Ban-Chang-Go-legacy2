//
//  AppDelegate.swift
//  Banchango
//
//  Created by 김동현 on 9/8/24.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser
import KakaoMapsSDK



class AppDelegate: NSObject, UIApplicationDelegate {
    
    
    //var authenticationViewModel: AuthenticationViewModel?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        let kakaoAppKey = Bundle.main.infoDictionary?["KAKAO_NATIVE_APP_KEY"] ?? ""
        print("App key: \(kakaoAppKey)")
        
        if let kakaoAppKey = kakaoAppKey as? String {
            // Kakao SDK 초기화
            KakaoSDK.initSDK(appKey: kakaoAppKey)
            
            // Kakao Map 초기화'
            SDKInitializer.InitSDK(appKey: kakaoAppKey)
        } else {
            print("Kakao App Key is missing or invalid")
        }


        // firebase 초기화
        FirebaseApp.configure()
        
        // gRPC 관련 환경 변수 설정 (GRPC_TRACE 제거)
        setenv("GRPC_VERBOSITY", "ERROR", 1)
        unsetenv("GRPC_TRACE") // GRPC_TRACE 환경 변수 제거
        
        // 탭 바의 색상 및 스타일 설정
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.backgroundColor = .white // 탭 바 배경색을 흰색으로 설정
        tabBarAppearance.stackedLayoutAppearance.normal.iconColor = .black // 탭 바 아이콘 색상 설정
        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = .blue // 선택된 탭 아이콘 색상 설정
        
        let tabBar = UITabBar.appearance()
        tabBar.standardAppearance = tabBarAppearance
        tabBar.scrollEdgeAppearance = tabBarAppearance
        
        return true
    }
    
    // kakao url을 타는 부분
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        // Kakao 로그인 URL 처리
        if (AuthApi.isKakaoTalkLoginUrl(url)) {
            return AuthController.handleOpenUrl(url: url)
        }
        
        // Google Sign-In URL 처리
        if GIDSignIn.sharedInstance.handle(url) {
            return true
        }
 
        return false
    }
    
    // MyappDelegate에서 SceneDelegate 클래스를 사용하도록 confiration 설정 필요
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let sceneConfiguration =  UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        
        // 내가 만든 MyAppDelegate SceneDelegate을 쓰겠다
        sceneConfiguration.delegateClass = SceneDelegate.self
        return sceneConfiguration
    }
}

