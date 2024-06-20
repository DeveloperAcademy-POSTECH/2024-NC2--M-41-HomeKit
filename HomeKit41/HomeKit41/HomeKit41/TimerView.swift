import SwiftUI
import Combine
import HomeKit

struct TimerView: View {
    @ObservedObject var homeKitManager: HomeKitManager
    @StateObject private var timerViewModel = TimerViewModel()
    @Binding var timerFinished: Bool
    @Binding var selectedTime: String
    @Binding var showPickerSection: Bool
    let timerTitle: String
    private let lightController: LightController
    let accessory: HMAccessory
    
    // 이닛 부분
    init(accessory: HMAccessory, homeKitManager: HomeKitManager, lightController: LightController, timerFinished: Binding<Bool>, selectedTime: Binding<String>, showPickerSection: Binding<Bool>, timerTitle: String) {
        self.accessory = accessory
        self.homeKitManager = homeKitManager
        self.lightController = lightController
        self._timerFinished = timerFinished
        self._selectedTime = selectedTime
        self._showPickerSection = showPickerSection
        self.timerTitle = timerTitle
    }
    
    var body: some View {
        VStack {
            // 타이머 제목 (Ex. 빨래 후 건조)
            HStack{
                Text(timerTitle)
                    .font(.title)
                    .padding(.leading)
                    .bold()
                    .foregroundStyle(Color.white)
                Spacer()
            }
            .padding(.vertical, 20)
            
            // 타이머 돌아가는 숫자 부분
            ZStack{
                // 타이머 숫자
                Text(timerViewModel.timeString)
                    .font(.system(size: 40))
                    .padding()
                    .foregroundStyle(Color.white)
                // 원형 프로그레스뷰
                RadialProgressView(progress: timerViewModel.progress)
                    .frame(width: 250, height: 250)
                // 시계
            }
            .padding(.bottom, 20)
            
            // 취소, 일시정지/시작 버튼
            HStack {
                // 취소버튼
                Button(action: timerViewModel.reset) {
                    Text("취소")
                        .foregroundColor(.white)
                        .frame(width: 92, height: 92)
                        .background(Color.gray.opacity(0.3))
                        .clipShape(Circle())
                }
                Spacer()
                // 일시정지/시작 버튼
                Button(action: timerViewModel.toggleTimer) {
                    Text(timerViewModel.isRunning ? "일시정지" : "시작")
                        .foregroundColor(timerViewModel.isRunning ? Color.yellow : Color.green)
                        .frame(width: 92, height: 92)
                        .background(timerViewModel.isRunning ? Color.yellow.opacity(0.3) : Color.green.opacity(0.3))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal)
            Spacer()
        }
        .background(Color.bgPrimaryDarkBase)
        // 화면이 나타났을때
        .onAppear {
            let timeComponents = selectedTime.split(separator: ":").map { String($0) }
            if timeComponents.count == 3 {
                if let hours = Int(timeComponents[0]), let minutes = Int(timeComponents[1]), let seconds = Int(timeComponents[2]) {
                    timerViewModel.selectedHours = hours
                    timerViewModel.selectedMinutes = minutes
                    timerViewModel.selectedSeconds = seconds
                    timerViewModel.reset()
                }
            }
        }
        // 타이머가 종료되었을 때
        .onChange(of: timerViewModel.timerFinished, initial: false) { oldValue, newValue in
            if newValue {
                lightController.startBlinkingBulb(for: accessory)
            }
            else {
                lightController.stopBlinkingBulb()
            }
        }
        //툴 바 종료버튼
        .toolbar {
            Button("종료"){
                lightController.stopBlinkingBulb()
            }
            .foregroundStyle(Color.appYellow)
        }
    }
}

// 타이머 설정하는 부분
struct PickerSection: View {
    @Binding var selectedTime: String
    @Binding var showPickerSection: Bool
    @ObservedObject var timerViewModel: TimerViewModel
    
    var body: some View {
        VStack{
            // 시간, 분, 초 설정
            HStack {
                // 시간 설정
                Picker("Hours", selection: $timerViewModel.selectedHours) {
                    ForEach(0..<24) { hour in
                        Text("\(hour) h").tag(hour)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(width: 90)
                .clipped()
                
                // 분 설정
                Picker("Minutes", selection: $timerViewModel.selectedMinutes) {
                    ForEach(0..<60) { minute in
                        Text("\(minute) m").tag(minute)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(width: 90)
                .clipped()
                
                // 초 설정
                Picker("Seconds", selection: $timerViewModel.selectedSeconds) {
                    ForEach(0..<60) { second in
                        Text("\(second) s").tag(second)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(width: 90)
                .clipped()
            }
            .padding()
            // 셋팅 완료 후 버튼을 누르면 위의 숫자가 변경된다
            Button("set time") {
                selectedTime = String(format: "%02d:%02d:%02d", timerViewModel.selectedHours, timerViewModel.selectedMinutes, timerViewModel.selectedSeconds)
                showPickerSection = false
            }
        }
    }
}

// 원형 프로그레스뷰
struct RadialProgressView: View {
    var progress: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 20.0)
                .opacity(0.3)
                .foregroundColor(Color.appYellow)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 20.0, lineCap: .round, lineJoin: .round))
                .foregroundColor(Color.appYellow)
                .rotationEffect(Angle(degrees: 270.0))
                .opacity(0.8)
                .animation(.linear, value: progress)
        }
    }
}

// 타이머 모델.. 굉장히 복잡..
class TimerViewModel: ObservableObject {
    @Published var timeString: String = "00:00:00"
    @Published var progress: Double = 1.0
    @Published var selectedHours: Int = 0
    @Published var selectedMinutes: Int = 0
    @Published var selectedSeconds: Int = 0
    @Published var savedTimes: [String] = []
    @Published var isRunning: Bool = false
    @Published var timerFinished: Bool = false
    
    private var cancellable: AnyCancellable?
    private var totalTime: TimeInterval = 0
    private var remainingTime: TimeInterval = 0
    
    // 타이머 on/off
    func toggleTimer() {
        if isRunning {
            stop()
        } else {
            start()
        }
    }
    
    // 타이머가 시작된다
    func start() {
        stop()
        totalTime = TimeInterval(selectedHours * 3600 + selectedMinutes * 60 + selectedSeconds)
        remainingTime = totalTime
        
        isRunning = true
        timerFinished = false
        
        cancellable = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                self.updateTime()
            }
    }
    
    // 타이머 정지
    func stop() {
        cancellable?.cancel()
        cancellable = nil
        isRunning = false
    }
    
    // 타이머 리셋
    func reset() {
        stop()
        remainingTime = totalTime
        progress = 1.0
        timeString = formatTime(time: remainingTime)
        timerFinished = false
    }
    
    // 시간 저장인데 CRUD 실패로 사용하지 못한 아이..
    func saveTime() {
        let savedTime = String(format: "%02d:%02d:%02d", selectedHours, selectedMinutes, selectedSeconds)
        savedTimes.append(savedTime)
    }
    
    // 시간 업뎃
    private func updateTime() {
        if remainingTime > 0 {
            remainingTime -= 1
        }
        timeString = formatTime(time: remainingTime)
        progress = totalTime > 0 ? remainingTime / totalTime : 1.0
        if remainingTime == 0 {
            stop()
            timerFinished = true
        }
    }
    // 시간을 문자열로 포맷팅
    private func formatTime(time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = (Int(time) % 3600) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
