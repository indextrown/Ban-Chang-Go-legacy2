//
//  SearchView.swift
//  Banchango
//
//  Created by 김동현 on 9/16/24.
//

//https://holyswift.app/containerrelativeshape-swiftui-tutorial/
//https://speakerdeck.com/kakao/darineun-geoleul-bbun-dot-manbogi-seobiseu-gaebalgi?slide=11
//https://eeyatho.tistory.com/252
//https://www.swiftyplace.com/blog/swiftcharts-create-charts-and-graphs-in-swiftui

import SwiftUI
import Charts
import CoreMotion

struct HealthView: View {
    var body: some View {
        VStack {
            ContentView()
        }
    }
}

struct ContentView: View {
    @StateObject private var viewModel = PedometerViewModel()
    
    var body: some View {
        VStack {
            //Text("테스트")
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {

                    RectViewH(height: 130, color: .white)
                        .overlay {
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("오늘의 걸음수 👟")
                                        .font(.system(size: 20))
                                        .fontWeight(.bold)
                                        .foregroundColor(.black)
                                    
                                    Spacer()
                                        .frame(height: 20)
                                    
                                    HStack {
                                        //Text("5,950")
                                        Text("\(viewModel.stepCount)")
                                            .font(.system(size: 30))
                                            .fontWeight(.bold)
                                            .foregroundColor(.mainorange)
                                    }
                                }
                                .padding(.leading, 10)
                                .frame(maxWidth: .infinity, alignment: .leading) // 왼쪽 정렬

                                Rectangle()
                                    .fill(Color.gray)
                                    .frame(width: 1, height: 80) // 구분선 두께와 높이 설정
                                    .padding(.horizontal, 10) // 구분선 양쪽 여백 설정

                                VStack(alignment: .leading) {
                                    Text("칼로리🔥")
                                        .font(.system(size: 20))
                                        .fontWeight(.bold)
                                        .foregroundColor(.black)
                                      
                                    Spacer()
                                        .frame(height: 20)
                                    
                                    HStack {
                                        Text("\(viewModel.caloriesBurned)")
                                            .font(.system(size: 30))
                                            .fontWeight(.bold)
                                            .foregroundColor(.mainorange)
                                        
                                        Text("kcal")
                                            .fontWeight(.bold)
                                            .foregroundColor(.black)
                                    }
                                }
                                .padding(.leading, 10)
                                .frame(maxWidth: .infinity, alignment: .leading) // 왼쪽 정렬
                            }
                            .padding(.horizontal, 20) // HStack 전체에 좌우 여백 설정
                        }
                        .padding(.top, 30)
                    

            
                    RectViewH(height: 300, color: .white)
                        .overlay {
                            Text("이번주 평균 걸음 수는?")
                                .font(.system(size: 20))
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                                .padding()
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading) // 좌측 상단 정렬
                            
                            GradientAreaChartExampleView()
                                .padding(20)
                        }
                    
                    RectViewH(height: 600, color: .white)
                        .overlay {
                            Text("나의 건강 그래프")
                                .font(.system(size: 20))
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                                .padding()
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading) // 좌측 상단 정렬
                        
                        }
                }
            }
        }
        .padding(.horizontal, 20)
        .background(Color.gray1) // 배경색 설정
        .background(.maincolor) // 배경색 설정//.edgesIgnoringSafeArea(.all) // 안전 영역을 무시하고 전체 화면에 배경색 적용
        .onAppear {
            viewModel.startPedometerUpdates()
        }
    }
}

struct StepData: Identifiable {
    let id = UUID()
    let date: Date
    let steps: Int
}

struct GradientAreaChartExampleView: View {
    // 일주일 간의 데이터 예시
    let stepData = [
        StepData(date: Calendar.current.date(byAdding: .day, value: -7, to: Date())!, steps: 7000),
        StepData(date: Calendar.current.date(byAdding: .day, value: -6, to: Date())!, steps: 5000),
        StepData(date: Calendar.current.date(byAdding: .day, value: -5, to: Date())!, steps: 6500),
        StepData(date: Calendar.current.date(byAdding: .day, value: -4, to: Date())!, steps: 7000),
        StepData(date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!, steps: 8000),
        StepData(date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!, steps: 9000),
        StepData(date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, steps: 10000),
        StepData(date: Date(), steps: 11000)
    ]
    
    let linearGradient = LinearGradient(
        gradient: Gradient(
            colors: [
                //                Color.accentColor.opacity(0.4),
                //                Color.accentColor.opacity(0)
                Color.maincolor.opacity(0.4),
                Color.maincolor.opacity(0)
            ]
        ),
        startPoint: .top,
        endPoint: .bottom)
    
    var body: some View {
        Chart {
            
            // MARK: - line
            ForEach(stepData) { data in
                LineMark(x: .value("Date", data.date),
                         y: .value("Steps", data.steps))
                .foregroundStyle(.mainorange)
            }
            .interpolationMethod(.cardinal)
        
            
            // MARK: - gradient
            ForEach(stepData) { data in
                AreaMark(x: .value("Date", data.date),
                         y: .value("Steps", data.steps))
              
            }
            .interpolationMethod(.cardinal)
            .foregroundStyle(linearGradient)
            
            // MARK: - dot
            ForEach(stepData) { data in
                PointMark(x: .value("Date", data.date),
                          y: .value("Steps", data.steps)) // 점 표시
                    .foregroundStyle(.mainred) // 점의 색상 설정
                    .symbolSize(40) // 점 크기 설정
            }
        }
        
        .chartXAxis {
            AxisMarks(values: stepData.map { $0.date }) { value in
                //AxisGridLine()
                //AxisTick()
                if let date = value.as(Date.self) {
                    AxisValueLabel(getKoreanWeekday(from: date), centered: true)
                }
            }
        }
        .chartYAxis(.hidden)
        .chartYScale(domain: 0...12000) // 걸음 수 최대 범위 설정
        //.aspectRatio(1, contentMode: .fit)
        //.frame(width: 350, height: 250) // 원하는 높이 설정
    }
    
    // 한글 요일 표시를 위한 함수
    func getKoreanWeekday(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "E" // 요일을 한글로 출력하기 위한 포맷 (월, 화, 수...)
        return dateFormatter.string(from: date)
    }
    
}

final class PedometerViewModel: ObservableObject {
    private var pedometer = CMPedometer()
    @Published var stepCount: Int = 0 {
        didSet {
            calculateCalories() // 걸음 수가 변경되면 칼로리 계산
        }
    }
    @Published var caloriesBurned: Int = 0
    
    init() {
        // 앱이 시작될 때 CMPedometer에서 걸음 수 가져오기
        startPedometerUpdates()
    }

    func startPedometerUpdates() {
        // 오늘 자정부터 현재까지의 걸음 수 가져오기
        let startOfToday = Calendar.current.startOfDay(for: Date())
        if CMPedometer.isStepCountingAvailable() {
            // 앱이 실행되었을 때 오늘 자정부터 걸음 수 불러오기
            pedometer.queryPedometerData(from: startOfToday, to: Date()) { data, error in
                if let data = data, error == nil {
                    DispatchQueue.main.async {
                        self.stepCount = data.numberOfSteps.intValue
                    }
                }
            }

            // 실시간 걸음 수 업데이트 시작
            pedometer.startUpdates(from: startOfToday) { data, error in
                if let data = data, error == nil {
                    DispatchQueue.main.async {
                        self.stepCount = data.numberOfSteps.intValue
                    }
                }
            }
        }
    }
    
    // 칼로리 계산 함수
    func calculateCalories() {
        let caloriesPerStep = 0.04 // 1걸음당 약 0.04kcal 소모
        self.caloriesBurned = Int(Double(stepCount) * caloriesPerStep)
    }
}




#Preview {
    HealthView()
}











/*
final class PedometerViewModel: ObservableObject {
    private var pedometer = CMPedometer()
    @Published var stepCount: Int = 0 {
        didSet {
            // 걸음 수가 변경될 때마다 UserDefaults에 저장
            UserDefaults.standard.set(stepCount, forKey: "stepCount")
        }
    }
    private var timer: Timer?
    
    init() {
        // 앱 시작시 저장된 걸음 수 불러오기
        self.stepCount = UserDefaults.standard.integer(forKey: "stepCount")
        startPedometerUpdates()
        startMidnightTimer()
    }
    
    func startPedometerUpdates() {
        // 권한 상태 확인
        if CMPedometer.authorizationStatus() == .denied {
            print("Motion & Fitness 권한이 거부되었습니다.")
            return
        }
        
        if CMPedometer.isStepCountingAvailable() {
            pedometer.startUpdates(from: Date()) { data, error in
                if let data = data, error == nil {
                    DispatchQueue.main.async {
                        self.stepCount = data.numberOfSteps.intValue
                    }
                }
            }
        }
    }
    
    // 자정에 초기화하는 타이머 설정
    func startMidnightTimer() {
        let now = Date()
        let nextMidnight = Calendar.current.nextDate(after: now, matching: DateComponents(hour: 0), matchingPolicy: .nextTime)!
        
        timer = Timer(fireAt: nextMidnight, interval: 86400, target: self, selector: #selector(resetSteps), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: .common)
    }
    
    // 자정에 걸음 수 초기화
    @objc func resetSteps() {
        stepCount = 0
        pedometer.stopUpdates()
        startPedometerUpdates()
    }
    
    deinit {
        timer?.invalidate()
    }
}*/




















/*
RectViewH(height: 130, color: .white)
    .overlay {
        
        VStack(alignment: .leading) {
            Text("오늘의 걸음 수는?")
                .font(.system(size: 20))
                .fontWeight(.bold)
                .foregroundColor(.black)
            
            Spacer()
                .frame(height: 20)
            
            HStack {
                Text("5,950")
                    .font(.system(size: 30))
                    .fontWeight(.bold)
                    .foregroundColor(.mainorange)
                x
                Text("걸음")
                    .fontWeight(.bold)
                    .foregroundColor(.black)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading) // 좌측 상단 정렬
    }
    .padding(.top, 30)
 */


/*
RectViewH(height: 130, color: .white)
    .overlay {
        HStack {
            VStack(alignment: .leading) {
                Text("오늘의 걸음수 👟")
                    .font(.system(size: 20))
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                Spacer()
                    .frame(height: 20)
                
                HStack {
                    Text("5,950")
                        .font(.system(size: 30))
                        .fontWeight(.bold)
                        .foregroundColor(.mainorange)
                    
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .topLeading)
            
            
            //Spacer()
            Rectangle()
                .fill(Color.gray)
                .frame(width: 1, height: 80) // 구분선 두께와 높이 설정
                .padding(.horizontal, 10)
            //Spacer()
            
            
            VStack(alignment: .leading) {
                Text("칼로리🔥")
                    .font(.system(size: 20))
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                  
                Spacer()
                    .frame(height: 20)
                
                HStack {
                    Text("240")
                        .font(.system(size: 30))
                        .fontWeight(.bold)
                        .foregroundColor(.mainorange)
                    
                    Text("kcal")
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                }
                
                   
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        
    }
    .padding(.top, 30)
*/




/*
MARK: - 삭제금지
RectViewH(height: 130, color: .white)
    .overlay {
        VStack {
            Text("10월 11일 (금)")
            HStack {
                VStack(alignment: .leading) {
                    Text("오늘의 걸음수 👟")
                        .font(.system(size: 20))
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    
                    Spacer()
                        .frame(height: 20)
                    
                    HStack {
                        Text("5,950")
                            .font(.system(size: 30))
                            .fontWeight(.bold)
                            .foregroundColor(.mainorange)
                    }
                }
                .padding(.leading, 10)
                .frame(maxWidth: .infinity, alignment: .leading) // 왼쪽 정렬
                
                Rectangle()
                    .fill(Color.gray)
                    .frame(width: 1, height: 80) // 구분선 두께와 높이 설정
                    .padding(.horizontal, 10) // 구분선 양쪽 여백 설정
                
                VStack(alignment: .leading) {
                    Text("칼로리🔥")
                        .font(.system(size: 20))
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    
                    Spacer()
                        .frame(height: 20)
                    
                    HStack {
                        Text("240")
                            .font(.system(size: 30))
                            .fontWeight(.bold)
                            .foregroundColor(.mainorange)
                        
                        Text("kcal")
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                    }
                }
                .padding(.leading, 10)
                .frame(maxWidth: .infinity, alignment: .leading) // 왼쪽 정렬
            }
            .padding(.horizontal, 20) // HStack 전체에 좌우 여백 설정
        }
    }
    .padding(.top, 30)
*/




/*
RectViewH(height: 130, color: .white)
    .overlay {
        VStack(spacing: 15) {
            Text("2024년 10월 11일 (금)")
            HStack {
                VStack(alignment: .leading) {
                    Text("오늘의 걸음수 👟")
                        .font(.system(size: 20))
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    
                    Spacer()
                        .frame(height: 20)
                    
                    HStack {
                        Text("5,950")
                            .font(.system(size: 30))
                            .fontWeight(.bold)
                            .foregroundColor(.mainorange)
                    }
                }
                .padding(.leading, 10)
                .frame(maxWidth: .infinity, alignment: .leading) // 왼쪽 정렬
                
                Rectangle()
                    .fill(Color.gray)
                    .frame(width: 1, height: 80) // 구분선 두께와 높이 설정
                    .padding(.horizontal, 10) // 구분선 양쪽 여백 설정
                
                VStack(alignment: .leading) {
                    Text("칼로리🔥")
                        .font(.system(size: 20))
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    
                    Spacer()
                        .frame(height: 20)
                    
                    HStack {
                        Text("240")
                            .font(.system(size: 30))
                            .fontWeight(.bold)
                            .foregroundColor(.mainorange)
                        
                        Text("kcal")
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                    }
                }
                .padding(.leading, 10)
                .frame(maxWidth: .infinity, alignment: .leading) // 왼쪽 정렬
            }
            .padding(.horizontal, 20) // HStack 전체에 좌우 여백 설정
        }
    }
    .padding(.top, 30)
*/
