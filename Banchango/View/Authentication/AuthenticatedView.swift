//
//  ContentView.swift
//  Banchango
//
//  Created by 김동현 on 9/8/24.
//

import SwiftUI

/*
 
 @ObservedObject
 SwiftUI에서 다른 클래스의 데이터를 관찰하는 뷰(View)에서 사용
 상태 변화를 관찰하고, 클래스 내부의 데이터가 변경되면 뷰를 자동으로 업데이트
 뷰에서 관찰하는 객체로 사용하여, 해당 객체의 데이터가 변경될 때마다 뷰를 자동으로 업데이트
 
 @Published
 ObservableObject 프로토콜을 따르는 클래스에서 사용
 속성(property)이 변경되면 자동으로 알림을 보내 관찰하고 있는 뷰들을 업데이트
 클래스 내부의 속성이 변경되면 해당 객체를 관찰하는 모든 뷰에 자동으로 알림
 
 @AppStorage
 SwiftUI에서 UserDefaults와 직접 연결하여 데이터를 저장하고 관리하는 데 사용
 사용자의 기기에 데이터를 영구적으로 저장할 때 사용하며, 자동으로 UserDefaults에 데이터를 저장하고 로드
 
 */


struct AuthenticatedView: View {
    @ObservedObject var authViewModel: AuthenticationViewModel
    
    // 지도 그리기 상태 관리 변수
    // @State private var draw: Bool = true
    
    var body: some View {
        
        Group {
           if authViewModel.isLoading {
               LoadingView() // 로딩 화면 표시
           } else if authViewModel.isLoggedIn{
               TabView {
                   HomeView() // draw 변수를 Binding으로 전달
                       .onDisappear {
                           // print("hello")
                       }
                       .frame(maxWidth: .infinity, maxHeight: .infinity)
                       //.frame(maxWidth: 20, maxHeight: 20)
                       .tabItem {
                           Label("홈", systemImage: "house")
                       }
                   
                   SearchView()
                       .tabItem {
                           Label("검색", systemImage: "magnifyingglass")
                       }
                   
                   FavoriteView()
                       .tabItem {
                           Label("즐겨찾기", systemImage: "heart.fill")
                       }
                   
                   SettingsView(authViewModel: authViewModel)
                       .tabItem {
                           Label("설정", systemImage: "gearshape")
                       }
               }
           } else if authViewModel.isNicknameRequired {
               NicknameInputView(authViewModel: authViewModel) // 닉네임 입력 화면
           } else {
               LoginView(authViewModel: authViewModel) // 로그인 화면
           }
       }
    }
}

#Preview {
    AuthenticatedView(authViewModel: .init())
}


struct LoadingView: View {
    var body: some View {
        VStack {
            Text("Loading...")
                .font(.headline)
                .padding()
            ProgressView() // 로딩 인디케이터
        }
    }
}

//HomeView(user: user)
//HomeView(authViewModel: authViewModel, user: user)
