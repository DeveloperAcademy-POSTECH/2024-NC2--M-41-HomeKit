import HomeKit
import SwiftUI

struct AccessoryControlView: View {
    @ObservedObject var homeKitManager: HomeKitManager
    private let lightController: LightController
    private let colorOptions: [String: UIColor]
    @State private var selectedColor: String = "Red"
    @Binding var timerFinished: Bool
    let accessory: HMAccessory
    @State private var isLightOn: Bool = false
    var selectedRoomName: String
    
    init(accessory: HMAccessory, homeKitManager: HomeKitManager, lightController: LightController, colorOptions: [String: UIColor], timerFinished: Binding<Bool>) {
        self.accessory = accessory
        self.homeKitManager = homeKitManager // <- 변경된 부분
        self.lightController = lightController
        self.colorOptions = colorOptions
        self._timerFinished = timerFinished
        if let selectedHome = homeKitManager.selectedHome,
           let room = selectedHome.rooms.first(where: { $0.accessories.contains(accessory) }) {
            self.selectedRoomName = room.name
        } else {
            self.selectedRoomName = "Unknown Room"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading){
            Text("\(selectedRoomName)")
                .font(.system(size: 40))
                .fontWeight(.bold)
                .padding(.leading, 16)
                .padding(.top, 20)
            Form {
                if let selectedAccessory = homeKitManager.selectedAccessory {
                    Section {
                        Toggle(isOn: $isLightOn) {
                            Text(isLightOn ?  "조명 켜짐": "조명 꺼짐")
                        }
                        .onChange(of: isLightOn) { old, new in
                            lightController.toggleLight(on: new, for: selectedAccessory)
                        }
                    }
                    
                    Picker("조명 색상", selection: $selectedColor) {
                        ForEach(["빨강", "주황", "노랑", "초록", "파랑", "남색", "보라"], id: \.self) { colorName in
                            if colorOptions.keys.contains(colorName) {
                                Text(colorName).tag(colorName)
                            }
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .onChange(of: selectedColor) { oldColor, newColor in
                        if let color = colorOptions[newColor] {
                            lightController.changeLightColor(to: color, for: selectedAccessory)
                        }
                    }
                    
                    Stepper("조명 밝기: \(homeKitManager.brightness)%", onIncrement: {
                        lightController.changeBrightness(by: 5, for: selectedAccessory) { newBrightness in
                            DispatchQueue.main.async {
                                homeKitManager.brightness = newBrightness
                            }
                        }
                    }, onDecrement: {
                        lightController.changeBrightness(by: -5, for: selectedAccessory) { newBrightness in
                            homeKitManager.brightness = newBrightness
                        }})
                }
            }
        }
    }
}
