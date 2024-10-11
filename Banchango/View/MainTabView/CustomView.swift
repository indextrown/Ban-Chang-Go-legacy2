//
//  PedometerView.swift
//  Banchango
//
//  Created by 김동현 on 10/9/24.
//

import SwiftUI

struct PedometerView: View {
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 10) // 모서리 둥글게
                .fill(.white) // 배경 색상
                .frame(height: 150)
                .shadow(color: .gray.opacity(0.5), radius: 5, x: 0, y: 0) // 테두리에 그림자 추가
                .overlay(
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(.maincolor), lineWidth: 2) // 고정된 테두리 색상
                        
                        Text("Your Text Here") // 텍스트 추가
                            .font(.headline)
                            .foregroundColor(.black) // 텍스트 색상
                        
                    }
                )
        }
        .padding(30)
    }
        
}


//#Preview {
//    PedometerView()
//}

//#Preview {
//    SearchView()
//}











//struct PedometerView: View {
//    var body: some View {
//        VStack {
//            ZStack {
//                // 배경을 위한 RoundedRectangle
//                RoundedRectangle(cornerRadius: 10)
//                    .fill(Color.white) // 배경 색상
//
//                // 테두리를 위한 RoundedRectangle
//                RoundedRectangle(cornerRadius: 10)
//                    .stroke(Color("maincolor"), lineWidth: 2) // 테두리 색상과 두께
//            }
//            .frame(height: 150) // 크기 설정
//        }
//        .padding()
//    }
//}
//
//
//
//
//
//
//



//struct PedometerView: View {
//    var body: some View {
//        VStack {
//
//            RoundedRectangle(cornerRadius: 10) // 모서리 둥글게
//                //.fill(Color.green.opacity(0.1)) // 배경 색상
//                .fill(.white) // 배경 색상
//                .frame(height: 150)
//                .overlay(
//                    RoundedRectangle(cornerRadius: 10)
//                        .stroke(.maincolor, lineWidth: 1) // 테두리 추가
//                )
//            }
//    }
//}

//struct PedometerView: View {
//    var body: some View {
//        VStack(alignment: .center, spacing: 8) {
//            // 배경으로 사용한 Rectangle 추가
//            Rectangle()
//                .fill(Color.blue.opacity(0.1)) // 연한 파란색 배경
//                .frame(height: 150) // 높이 설정
//                .cornerRadius(15) // 모서리 둥글게
//                .overlay( // Rectangle 위에 콘텐츠 오버레이
//                    VStack {
//                        Text("Calories Count")
//                            .font(.headline)
//                        Text("8,900")
//                            .font(.system(size: 48, weight: .bold))
//                    }
//                    .padding()
//                )
//            
//            // 더 많은 콘텐츠...
//        }
//        .padding()
//    }
//}



//            Rectangle()
//                //.fill(Color.green.opacity(0.1)) // 연판 파란색 배경
//                //.fill(Color.green.opacity(0.1)) // 연판 파란색 배경
//                //.fill(Color.fromHex("#5fc567")?.opacity(1) ?? Color.gray)
//
//                //.fill(Color.fromHex("#999999")!.opacity(1))
//
//                .fill(Color.fromHex("#ffffff")!)
//
//                .frame(height: 150)
//                .cornerRadius(10)
//
