//
//  LoginIntroView.swift
//  Banchango
//
//  Created by 김동현 on 9/8/24.
//

import SwiftUI
import _AuthenticationServices_SwiftUI


struct LoginView: View {
    
    @ObservedObject var authViewModel: AuthenticationViewModel
    

    var body: some View {
        NavigationStack {
            VStack(spacing: 10) {
                Spacer()
                
//                Text("환영합니다")
//                    .font(.system(size: 26, weight: .bold))
//                    .foregroundColor(.bkText)
//                
//                Text("언제 어디서나 당신의 건강을 지키는 스마트한 선택, 반창고앱!")
//                    .font(.system(size: 15))
//                    .foregroundColor(.greyDeep)
                
                Spacer()
                
                
                // MARK: - 카카오버튼
                Button {
                    // TODO:
                    authViewModel.kakaoLogin()
                } label: {
                    HStack {
                        Image(systemName: "message.fill")
                            .foregroundColor(.black)
                        Text("카카오 로그인")
                            .foregroundColor(.black)
                            .font(.system(size: 14, weight: .medium, design: .default))
                    }
                }.buttonStyle(SocialLoginButton(buttontype: "Kakao"))
                 
                
                // MARK: - 애플버튼
                SignInWithAppleButton { request in
                    // TODO:
                    //authViewModel.send(action: .appleLogin(request))
                    
                    // 인증이 완료됬을때 불려지는 클로저 - 성공시 파이어베이스 인증 진행
                } onCompletion: { request in
                    // TODO:
                   // authViewModel.send(action: .appleLoginCompletion(request))
                }
                .frame(height: 50)
                .padding(.horizontal, 15)
                .cornerRadius(5)
                
                
                
                // MARK: - 구글버튼
                Button {
                    // TODO:
                    //authViewModel.send(action: .googleLogin)
                } label: {
                    HStack {
                        Image("Google")
                            .resizable() // 아마자 크기 조절 가능하도록 설정
                            .aspectRatio(contentMode: .fit) // 비율 유지하며 크기 조정
                            .frame(width: 24, height: 24) // 크기 설정
                        Text("Google 로그인")
                        
                    }
                }.buttonStyle(SocialLoginButton(buttontype: "Google"))
            }
            /*
            .overlay {
                
                if authViewModel.isLoading {
                    ProgressView()
                 
                }
            }*/
            .padding(.bottom, 100)
            //.background(.green2)
            .background(
                Image("login_img") // "img_login"을 배경으로 설정
                //Image("img_login")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all) // 배경이 화면 전체를 채우도록 설정
            )
        }
        
    }

}



#Preview {
    LoginView(authViewModel: .init())
}
