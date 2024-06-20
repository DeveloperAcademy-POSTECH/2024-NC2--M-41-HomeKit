import SwiftUI
import HomeKit

struct MainView: View {
    @StateObject private var homeKitManager = HomeKitManager()
    private let lightController = LightController()
    private let colorOptions: [String: UIColor] = [
        "빨강": UIColor.red,
        "주황": UIColor.orange,
        "노랑": UIColor.yellow,
        "초록": UIColor.green,
        "파랑": UIColor.blue,
        "남색": UIColor.systemIndigo,
        "보라": UIColor.purple
    ]
    @State private var selectedColor: String = "Red"
    @State private var timerFinished: Bool = false
    @State private var selectedRoom: HMRoom?
    @State private var selectedAccessory: HMAccessory?
    
    var body: some View {
        NavigationStack {
            List {
                // 홈 선택 섹션
                Section(header: Text("내 집").font(.title).foregroundStyle(.black).bold()) {
                    Picker("Home", selection: $homeKitManager.selectedHome) {
                        ForEach(homeKitManager.homes, id: \.self) { home in
                            Text(home.name).tag(home as HMHome?)
                        }
                    }
                }
                // 방 선택 섹션
                if let selectedHome = homeKitManager.selectedHome {
                    Section(header: Text("액세서리 타이머").font(.headline).foregroundStyle(.black)) {
                        ForEach(selectedHome.rooms, id: \.self) { room in
                            NavigationLink(destination: RoomView(room: room, homeKitManager: homeKitManager, lightController: lightController, colorOptions: colorOptions)) {
                                Text(room.name)
                            }
                        }
                    }
                    // 액세서리 선택 섹션
                    Section(header: Text("액세서리").font(.headline).foregroundStyle(.black)) {
                        LazyVGrid(columns: Array(repeating: GridItem(), count: 3), spacing: 16) {
                            ForEach(selectedHome.accessories, id: \.self) { accessory in
                                NavigationLink(destination: AccessoryControlView(
                                    accessory: accessory,
                                    homeKitManager: homeKitManager,
                                    lightController: lightController,
                                    colorOptions: colorOptions,
                                    timerFinished: $timerFinished)) {
                                        VStack(alignment: .leading) {
                                            Image(systemName: "bed.double")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(height: 15)
                                                .padding(.bottom, 40)
                                                .padding(.trailing, 20)
                                            Text(accessory.name)
                                                .bold()
                                                .padding(.trailing, 20)
                                        }
                                        .frame(width: 112, height: 112)
                                        .background(Color.appYellow)
                                        .cornerRadius(8)
                                        .padding(4)
                                    }
                                    .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
        .navigationBarTitle("HomeKit Controller", displayMode: .inline)
    }
}

