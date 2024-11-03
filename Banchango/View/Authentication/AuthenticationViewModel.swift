//
//  AuthenricationViewModel.swift
//  Banchango
//
//  Created by 김동현 on 9/8/24.
//
//


//import SwiftUI
//import Combine
//import Firebase
//import KakaoSDKAuth
//import KakaoSDKUser
//
//class AuthenticationViewModel: ObservableObject {
//    @Published var isNicknameRequired = false
//    @Published var user: User?                  // 사용자 정보 저장
//    @Published var isLoggedIn = false           // 로그인 상태 변화 감지
//    @Published var hasProfile: Bool = false
//    @Published var isLoading = false            // 로딩 상태 초기값 false로 설정
//    
//    @AppStorage("userId") var userId: String? {
//        didSet {
//            DispatchQueue.main.async {
//                // userId가 변경될 때 isLoggedIn 값을 업데이트
//                self.isLoggedIn = (self.userId != nil)
//            }
//        }
//    }
//    
//    @AppStorage("loginType") var loginType: String?
//    
//    init() {
//        checkLoginStatus()
//    }
//    
//    func checkLoginStatus() {
//        isLoading = true
//        if let userId = userId {
//            checkIfUIDExistsInFirestore(uid: userId) { exists in
//                DispatchQueue.main.async {
//                    if exists {
//                        self.checkIfNicknameExists(uid: userId) { nicknameExists in
//                            DispatchQueue.main.async {
//                                if nicknameExists {
//                                    self.isNicknameRequired = false
//                                    self.isLoggedIn = true
//                                } else {
//                                    self.isNicknameRequired = true
//                                }
//                                self.isLoading = false
//                            }
//                        }
//                    } else {
//                        self.isLoggedIn = false
//                        self.isNicknameRequired = true
//                        self.isLoading = false
//                    }
//                }
//            }
//        } else {
//            self.isLoggedIn = false
//            self.isNicknameRequired = false
//            self.isLoading = false
//        }
//    }
//    
//    func checkIfUIDExistsInFirestore(uid: String, completion: @escaping (Bool) -> Void) {
//        DispatchQueue.global(qos: .background).async { // 백그라운드 스레드에서 Firestore 요청 실행
//            let db = Firestore.firestore()
//            let docRef = db.collection("users").document(uid)
//
//            docRef.getDocument { document, error in
//                DispatchQueue.main.async {
//                    if let error = error {
//                        print("UID 확인 중 오류 발생: \(error.localizedDescription)")
//                        completion(false)
//                        return
//                    }
//                    if let document = document, document.exists {
//                        print("UID가 존재합니다.")
//                        completion(true)
//                    } else {
//                        print("UID가 존재하지 않습니다.")
//                        completion(false)
//                    }
//                }
//            }
//        }
//    }
//
//    func checkIfUIDExistsInFirestore2(uid: String, completion: @escaping (Bool) -> Void) {
//        let db = Firestore.firestore()
//        let docRef = db.collection("users").document(uid)
//        
//        docRef.getDocument { document, error in
//            if let error = error {
//                DispatchQueue.main.async {
//                    print("UID 확인 중 오류 발생: \(error.localizedDescription)")
//                    completion(false)
//                }
//                return
//            }
//            
//            if let document = document, document.exists {
//                DispatchQueue.main.async {
//                    print("UID가 존재합니다.")
//                    completion(true)
//                }
//            } else {
//                DispatchQueue.main.async {
//                    print("UID가 존재하지 않습니다.")
//                    completion(false)
//                }
//            }
//        }
//    }
//    
//    func checkIfNicknameExists(uid: String, completion: @escaping (Bool) -> Void) {
//        let db = Firestore.firestore()
//        let docRef = db.collection("users").document(uid)
//        
//        docRef.getDocument { document, error in
//            if let error = error {
//                DispatchQueue.main.async {
//                    print("닉네임 확인 중 오류 발생: \(error.localizedDescription)")
//                    completion(false)
//                }
//                return
//            }
//            
//            guard let document = document, document.exists,
//                  let data = document.data(),
//                  let nickname = data["nickname"] as? String, !nickname.isEmpty else {
//                DispatchQueue.main.async {
//                    print("닉네임이 존재하지 않음.")
//                    completion(false)
//                }
//                return
//            }
//            
//            DispatchQueue.main.async {
//                print("닉네임이 존재합니다: \(nickname)")
//                completion(true)
//            }
//        }
//    }
//    
//    func saveUIDAndNicknameToFirestore(uid: String, nickname: String) {
//        let db = Firestore.firestore()
//        let user = User(id: uid, nickname: nickname)
//        
//        db.collection("users").document(uid).setData([
//            "uid": user.id,
//            "nickname": user.nickname
//        ]) { error in
//            DispatchQueue.main.async {
//                if let error = error {
//                    print("유저 데이터 저장 실패: \(error.localizedDescription)")
//                } else {
//                    print("유저 데이터 저장 성공!")
//                    self.user = user    // 사용자 정보 업데이트
//                    self.userId = uid   // 로그인 상태를 유지하기 위해 userId 저장
//                    self.isNicknameRequired = false
//                }
//            }
//        }
//    }
//    
//    // MARK: - 카카오로그인
//    func kakaoLogin() {
//        // 카카오톡으로 로그인 시도
//        if UserApi.isKakaoTalkLoginAvailable() {
//            UserApi.shared.loginWithKakaoTalk { [weak self] (oauthToken, error) in
//                if let error = error {
//                    print("카카오톡 로그인 실패: \(error.localizedDescription)")
//                    return
//                }
//                self?.loginType = "Kakao"
//                self?.fetchUserInfo()
//            }
//        } else {
//            // 카카오 계정으로 로그인 시도
//            UserApi.shared.loginWithKakaoAccount { [weak self] (oauthToken, error) in
//                if let error = error {
//                    print("카카오 계정 로그인 실패: \(error.localizedDescription)")
//                    return
//                }
//                self?.loginType = "Kakao"
//                self?.fetchUserInfo()
//            }
//        }
//    }
//
//    private func fetchUserInfo() {
//        UserApi.shared.me { [weak self] (user, error) in
//            if let error = error {
//                print("사용자 정보 요청 실패: \(error.localizedDescription)")
//                return
//            }
//            guard let user = user else {
//                print("사용자 정보가 없습니다.")
//                return
//            }
//            // 사용자 정보 추출
//            guard let id = user.id else {
//                print("사용자 ID가 없습니다.")
//                return
//            }
//            
//            let uid = "\(id)"
//            let nickname = user.kakaoAccount?.profile?.nickname ?? "Unknown"
//            
//            DispatchQueue.main.async {
//                self?.user = User(id: uid, nickname: nickname)
//                self?.userId = uid // UID를 @AppStorage에 저장
//                self?.checkIfUIDExistsInFirestore(uid: uid) { _ in }
//            }
//        }
//    }
//    
//    func logout() {
//        if loginType == "Kakao" {
//            UserApi.shared.logout { [weak self] (error) in
//                DispatchQueue.main.async {
//                    if let error = error {
//                        print("카카오 로그아웃 실패: \(error.localizedDescription)")
//                    } else {
//                        print("카카오 로그아웃 성공")
//                        self?.clearUserData()
//                    }
//                }
//            }
//        } else {
//            clearUserData()
//        }
//    }
//    
//    private func clearUserData() {
//        DispatchQueue.main.async {
//            self.user = nil
//            self.userId = nil
//            self.isLoggedIn = false
//            self.isNicknameRequired = false
//            self.loginType = nil
//        }
//    }
//}
//
//// MARK: - 애플 로그인

import SwiftUI
import Combine
import Firebase
import KakaoSDKAuth
import KakaoSDKUser

class AuthenticationViewModel: ObservableObject {
    @Published var isNicknameRequired = false   // 닉네임이 필요한지 여부
    @Published var user: User?                  // 사용자 정보 저장
    @Published var isLoggedIn = false           // 로그인 상태 변화 감지
    @Published var isLoading = false            // 로딩 상태 초기값 false로 설정
    
    @AppStorage("userId") var userId: String? {
        didSet {
            DispatchQueue.main.async {
                // userId가 변경될 때 isLoggedIn 값을 업데이트
                self.isLoggedIn = (self.userId != nil)
            }
        }
    }
    
    @AppStorage("loginType") var loginType: String?
    
    init() {
        checkLoginStatus()
    }
    
    // 로그인 상태 확인 함수
    func checkLoginStatus() {
        isLoading = true  // 로딩 상태 시작
        
        // 첫 번째 조건: userId가 존재하는지 확인
        if let userId = userId {
            // userId가 존재하는 경우 Firestore에서 UID가 있는지 확인
            checkIfUIDExistsInFirestore(uid: userId) { exists in
                DispatchQueue.main.async {
                    if exists {
                        // Firestore에 UID가 존재하는 경우: 닉네임이 설정되어 있는지 확인
                        self.checkIfNicknameExists(uid: userId) { nicknameExists in
                            DispatchQueue.main.async {
                                if nicknameExists {
                                    // 닉네임이 존재하는 경우
                                    // 닉네임이 설정되어 있으므로, 닉네임 입력이 필요하지 않음을 나타내고 로그인 상태를 true로 설정
                                    self.isNicknameRequired = false
                                    self.isLoggedIn = true
                                } else {
                                    // 닉네임이 존재하지 않는 경우
                                    // 닉네임이 필요하므로, 닉네임 입력이 필요함을 나타내고 로그인 상태는 false로 설정
                                    self.isNicknameRequired = true
                                    self.isLoggedIn = false
                                }
                                // Firestore 조회가 끝났으므로 로딩 상태를 false로 설정
                                self.isLoading = false
                            }
                        }
                    } else {
                        // Firestore에서 UID가 존재하지 않는 경우
                        // 사용자가 Firestore에 존재하지 않으므로 로그인되지 않은 상태로 설정하고 닉네임 입력이 필요함을 나타냄
                        self.isLoggedIn = false
                        self.isNicknameRequired = true
                        self.isLoading = false
                    }
                }
            }
        } else {
            // userId가 nil인 경우 (즉, 사용자가 로그인하지 않은 경우)
            // 로그인이 되어 있지 않으므로 로그인 상태와 닉네임 입력 필요 상태 모두 false로 설정
            self.isLoggedIn = false
            self.isNicknameRequired = false
            self.isLoading = false
        }
    }

    
    // Firestore에서 UID가 존재하는지 확인하는 함수
    func checkIfUIDExistsInFirestore(uid: String, completion: @escaping (Bool) -> Void) {
        DispatchQueue.global(qos: .background).async {
            let db = Firestore.firestore()
            let docRef = db.collection("users").document(uid)

            docRef.getDocument { document, error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("UID 확인 중 오류 발생: \(error.localizedDescription)")
                        completion(false)
                        return
                    }
                    if let document = document, document.exists {
                        completion(true)
                    } else {
                        completion(false)
                    }
                }
            }
        }
    }

    // Firestore에서 닉네임이 존재하는지 확인하는 함수
    func checkIfNicknameExists(uid: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        let docRef = db.collection("users").document(uid)
        
        docRef.getDocument { document, error in
            if let error = error {
                DispatchQueue.main.async {
                    print("닉네임 확인 중 오류 발생: \(error.localizedDescription)")
                    completion(false)
                }
                return
            }
            
            guard let document = document, document.exists,
                  let data = document.data(),
                  let nickname = data["nickname"] as? String, !nickname.isEmpty else {
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(true)
            }
        }
    }
    
    // Firestore에 UID와 닉네임을 저장하는 함수
    func saveUIDAndNicknameToFirestore(uid: String, nickname: String) {
        let db = Firestore.firestore()
        let user = User(id: uid, nickname: nickname)
        
        db.collection("users").document(uid).setData([
            "uid": user.id,
            "nickname": user.nickname
        ]) { error in
            DispatchQueue.main.async {
                if let error = error {
                    print("유저 데이터 저장 실패: \(error.localizedDescription)")
                } else {
                    print("유저 데이터 저장 성공!")
                    self.user = user    // 사용자 정보 업데이트
                    self.userId = uid   // 로그인 상태를 유지하기 위해 userId 저장
                    self.isNicknameRequired = false
                }
            }
        }
    }
    
    // 카카오 로그인 함수
    func kakaoLogin() {
        if UserApi.isKakaoTalkLoginAvailable() {
            UserApi.shared.loginWithKakaoTalk { [weak self] (oauthToken, error) in
                if let error = error {
                    print("카카오톡 로그인 실패: \(error.localizedDescription)")
                    return
                }
                self?.loginType = "Kakao"
                self?.fetchUserInfo()
            }
        } else {
            UserApi.shared.loginWithKakaoAccount { [weak self] (oauthToken, error) in
                if let error = error {
                    print("카카오 계정 로그인 실패: \(error.localizedDescription)")
                    return
                }
                self?.loginType = "Kakao"
                self?.fetchUserInfo()
            }
        }
    }

    // 카카오 사용자 정보 요청 함수
    private func fetchUserInfo() {
        UserApi.shared.me { [weak self] (user, error) in
            if let error = error {
                print("사용자 정보 요청 실패: \(error.localizedDescription)")
                return
            }
            guard let user = user else {
                print("사용자 정보가 없습니다.")
                return
            }
            guard let id = user.id else {
                print("사용자 ID가 없습니다.")
                return
            }
            
            let uid = "\(id)"
            let nickname = user.kakaoAccount?.profile?.nickname ?? "Unknown"
            
            DispatchQueue.main.async {
                self?.user = User(id: uid, nickname: nickname)
                self?.userId = uid // UID를 @AppStorage에 저장
                self?.checkIfUIDExistsInFirestore(uid: uid) { _ in }
            }
        }
    }
    
    // 로그아웃 함수
    func logout() {
        if loginType == "Kakao" {
            UserApi.shared.logout { [weak self] (error) in
                if let error = error {
                    print("카카오 로그아웃 실패: \(error.localizedDescription)")
                } else {
                    self?.clearUserData()
                }
            }
        } else {
            clearUserData()
        }
    }
    
    // 사용자 데이터 초기화 함수
    private func clearUserData() {
        DispatchQueue.main.async {
            self.user = nil
            self.userId = nil
            self.isLoggedIn = false
            self.isNicknameRequired = false
            self.loginType = nil
        }
    }
}
