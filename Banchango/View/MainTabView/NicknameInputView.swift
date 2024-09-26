//
//  NicknameView.swift
//  Banchango
//
//  Created by 김동현 on 9/10/24.
//

import SwiftUI

struct NicknameInputView: View {
    @ObservedObject var authViewModel: AuthenticationViewModel
    @State private var nickname: String = ""
    
    var body: some View {
        VStack {
            TextField("닉네임을 입력하세요", text: $nickname)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button(action: {
                saveNickname()
            }) {
                Text("확인")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        
    }
    func saveNickname() {
            guard let userId = authViewModel.userId else { return }
            authViewModel.saveUIDAndNicknameToFirestore(uid: userId, nickname: nickname)
        }
}

#Preview {
    NicknameInputView(authViewModel: .init())
}
