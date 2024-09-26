//
//  LoginButtonStyle.swift
//  Banchango
//
//  Created by 김동현 on 9/8/24.
//

import SwiftUI

struct LoginButtonStyle: ButtonStyle {
    
    let textColor: Color
    let borderColor: Color
    
    // 컬러가 동일하면 동일하게
    init(textColor: Color, borderColor: Color? = nil) {
        self.textColor = textColor
        self.borderColor = borderColor ?? textColor
    }
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14))
            .foregroundColor(textColor)
            .frame(maxWidth: .infinity, maxHeight: 50)
            .overlay {
                RoundedRectangle(cornerRadius: 5)
                    .stroke(borderColor, lineWidth: 0.8)
            }
            .padding(.horizontal, 15)
            .opacity(configuration.isPressed ? 0.5 : 1) // 0: 투명 1: 불투명
            .contentShape(RoundedRectangle(cornerRadius: 5)) // 터치 영역을 늘림
    }
}


/*
 
 Button {
     // TODO:
     isPresentedLoginView.toggle()
 } label: {
     Text("로그인")
         .font(.system(size: 14))
         .foregroundColor(.lineAppColor)
         .frame(maxWidth: .infinity, maxHeight: 40)
 }
 // 테두리
 .overlay {
     RoundedRectangle(cornerRadius: 5)
         .stroke(Color.lineAppColor, lineWidth: 0.8)
 }
 .padding(.horizontal, 15)
 
 */
