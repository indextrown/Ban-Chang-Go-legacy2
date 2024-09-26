//
//  SettingsView.swift
//  Banchango
//
//  Created by 김동현 on 9/13/24.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var authViewModel: AuthenticationViewModel
   
    
    var body: some View {
        VStack {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            // 로그아웃 버튼 추가
            Button(action: {
                authViewModel.logout()
            }, label: {
                Text("로그아웃")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            })
            .padding(.top, 20) // 버튼과 텍스트 사이에 간격 추가
        }
    }
}


/*
 SettingsView에 필요한 매개변수에 맞춰 #Preview 코드를 작성하려면, draw를 @State나 @Binding으로 처리해야 합니다.
 하지만 미리보기에서는 @State나 @Binding 변수를 직접 초기화할 수 없으므로, draw 상태를 간단히 초기화한 값을 사용하는 방식으로 설정할 수 있습니다.
 */
#Preview {
    SettingsView(authViewModel: .init())
}
