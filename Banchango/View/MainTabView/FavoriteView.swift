//
//  FavoriteView.swift
//  Banchango
//
//  Created by 김동현 on 9/16/24.
//

import SwiftUI
import MapKit
import CoreLocation

struct FavoriteView: View {
    var body: some View {
        Text("Favorite View")
    }
}

#Preview {
    FavoriteView()
}







//                    HStack(spacing: 20) {
//                        RectViewH(height: 130, color: .white)
//                            .overlay {
//                                Text("123")
//                            }
//
//                        RectViewH(height: 130, color: .white)
//                    }
                    


//import SwiftUI
//
//struct HealthView: View {
//    var body: some View {
//        ZStack {
//            // 배경색 설정 (흰색에 가까운 밝은 회색)
//            Color.gray.opacity(0.05)
//                .edgesIgnoringSafeArea(.all) // 전체 화면에 적용
//
//            VStack {
////                Spacer()
////                    .frame(height: 20)
//                Text("테스트")
//                    //.frame(maxWidth: .infinity) // ScrollView 너비를 최대한으로 확장
//                    //.background(.white)
//
//                //VStack(spacing: 10)
//
//                // MARK: - 칼로리부분
//                ScrollView {
////                    VStack(alignment: .center, spacing: 8) {
////                        Text("칼로리 수")
////                            .font(.headline)
////                        Text("8,900")
////                            .font(.system(size: 48, weight: .bold))
////                        HStack {
////                            Text("먹어봤자 내가 알고있는")
////                            Image(systemName: "coin.fill") // 적절한 이미지를 추가하세요
////                            Text("+10")
////                                .foregroundColor(.pink)
////                        }
////                    }
////                    .padding()
////                    .background(Color(red: 230/255, green: 245/255, blue: 255/255)) // 배경색 설정
////                    .cornerRadius(15)
////
//                    PedometerView()
//                    // 건들지말기
//                    //.padding(.horizontal, 30)
//
//
//                    // 상단에서 20 여백
//                    Spacer()
//                        .frame(height: 20)
//
//                    VStack(spacing: 20) {
//
//                        HStack {
//                            Text("환자")
//                            Spacer()
//                        }
//
//                        // 열 통계
//                        HStack {
//                            VStack() {
//                                Text("전국")
//                                    .font(.system(size: 14))
//                                //.foregroundColor(.gray)
//                                Text("60,035명")
//                                    .font(.system(size: 18))
//                                    .foregroundColor(.red)
//                                Text("감기 환자")
//                                    .font(.system(size: 14))
//                                    .foregroundColor(.black)
//                            }
//
//                            // 구분선
//                            Spacer()
//                            Rectangle()
//                                .fill(Color.gray)
//                                .frame(width: 1, height: 60) // 구분선 두께와 높이 설정
//                                .padding(.horizontal, 10)
//                            Spacer()
//
//                            VStack {
//                                Text("38°C")
//                                    .font(.system(size: 18))
//                                    .foregroundColor(.red)
//                                Text("평균 체온")
//                                    .font(.system(size: 14))
//                                    .foregroundColor(.black)
//                            }
//                            //.background(.gray)
//                        }
//                        .padding(.horizontal)
//                        .padding()
//                        .background(.white)
//                        .cornerRadius(10)
//
//                        Spacer()
//
//                        //
//                        HStack {
//                            Text("오늘의 소식")
//                            Spacer()
//                        }
//
//
//                        VStack(spacing: 10) { // 아이템 간 간격을 위한 VStack
//                            Text("123")
//                            Text("123")
//                            Text("123")
//                            Text("123")
//                            Text("123")
//                            Text("123")
//                            Text("000")
//
//                        }
//                        .frame(maxWidth: .infinity) // ScrollView 너비를 최대한으로 확장
//                        .background(.white)
//                        .padding(.bottom, 10)
//                        .cornerRadius(10)
//
//                    }
//                    // 건들지말기
//                    .padding(.horizontal, 30)
//
//
//
//
//
//                }
//
//
//
////                // 건들지말기
////                .padding(.horizontal, 30)
//            }
//
//
//        }
//    }
//}
//
//#Preview {
//    HealthView()
//}

