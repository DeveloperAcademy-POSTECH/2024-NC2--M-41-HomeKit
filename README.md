# 2024-NC2-M41-AugmentedReality
## 🎥 Youtube Link
(추후 만들어진 유튜브 링크 추가)

## 💡 About Augmented Reality
(해당 기술에 대한 조사 내용 정리)
> 홈킷을 바탕으로 휴대폰을 이용해 집에 있는 전구를 조작할 수 있다

## 🎯 What we focus on?
> 홈 앱에 추가된 기기를 불러와서 앱 내에서 타이머를 설정하면 타이머 종료시간에 맞추어 기기(전구)의 점멸을 통해 사용자에게 알립니다.
> 청각장애인을 주요 앱 사용자로 설정했습니다. 소리를 인지할 수 없는 대상을 위해 소리 대신 전구의 점멸로 어떠한 상황을 알리자는 목표를 세웠고, 그 중에서도 시간을 재고 종료 시점을 확실히 인지해야 하는 일에 초점을 두었습니다.

## 💼 Use Case
>- 세탁기를 작동한 후에 종료 시점에 맞추어 타이머를 설정하고 사용한다.
>- 밥솥으로 밥을 짓고 타이머를 설정한다.
>- 수육을 삶는데에 시간이 오래 걸리는데 계속해서 보고있을 수 없기 때문에 타이머를 설정한다.

## 🖼️ Prototype
https://github.com/DeveloperAcademy-POSTECH/2024-NC2--M-41-HomeKit/assets/167425685/bff8b5bb-4130-4d9f-aca5-3817100ed49d
>- 집에서 방으로 접근해 타이머와 조명을 설정하고, 타이머를 작동시킬 수 있습니다.
>- 악세서리에서 악세서리 각각에 대한 상태를 정의할 수 있습니다.
>- 최근 사용한 타이머에서 가장 최근에 사용한 타이머를 볼 수 있습니다. 자주 사용하는 기능이라면 최근 사용한 타이머에서 계속 볼 수 있어 사용자화에 도움이 됩니다.


## 🛠️ About Code
타이머를 설정한 뒤 종료되면 전구가 점멸한다
```swift
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

```

