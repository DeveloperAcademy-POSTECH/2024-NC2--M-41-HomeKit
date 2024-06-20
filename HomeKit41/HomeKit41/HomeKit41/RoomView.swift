import SwiftUI
import HomeKit

struct RoomView: View {
    let room: HMRoom
    @ObservedObject var homeKitManager: HomeKitManager
    let lightController: LightController
    let colorOptions: [String: UIColor]
    @State private var selectedColor: String = "Red"
    @State private var timerFinished: Bool = false
    @State private var showPickerSection: Bool = false
    @State private var selectedTime: String = "00:00:00"
    @State private var textFieldInput: String = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(room.name)")
                .font(.system(size: 40))
                .fontWeight(.bold)
                .padding(.leading, 16)
                .padding(.top, 20)
            Form {
                // 액세서리 선택 섹션
                Section {
                    Picker("액세서리", selection: $homeKitManager.selectedAccessory) {
                        ForEach(room.accessories, id: \.self) { accessory in
                            Text(accessory.name).tag(accessory as HMAccessory?)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                // 제목 입력
                Section {
                    TextField("타이머 제목을 입력하세요", text: $textFieldInput)
                        .textFieldStyle(PlainTextFieldStyle())
                }
                // 타이머
                Section {
                    HStack {
                        Text("타이머")
                        Spacer()
                        Button {
                            showPickerSection.toggle()
                        } label: {
                            Text(selectedTime)
                        }
                    }
                }
                // 타이머 버튼 누르면 나오는 휠
                if showPickerSection {
                    PickerSection(selectedTime: $selectedTime, showPickerSection: $showPickerSection, timerViewModel: TimerViewModel())
                        .frame(height: 200)
                }
            } // 여기까지가 폼
        }
        .toolbar {
            NavigationLink(destination: TimerView(
                accessory: homeKitManager.selectedAccessory!,
                homeKitManager: homeKitManager,
                lightController: lightController,
                timerFinished: $timerFinished,
                selectedTime: $selectedTime,
                showPickerSection: $showPickerSection,
                timerTitle: textFieldInput)) {
                    Text("완료")
                }
            //            .disabled(textFieldInput.isEmpty)
                .disabled(textFieldInput.isEmpty || homeKitManager.selectedAccessory == nil)
        }
    }
}
