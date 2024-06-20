import HomeKit

// HomeKitManager는 HomeKit의 홈과 액세서리 관리를 담당하는 클래스
class HomeKitManager: NSObject, ObservableObject, HMHomeManagerDelegate {
    static let shared = HomeKitManager() // Singleton 인스턴스

    @Published var homes: [HMHome] = [] // 홈 목록 저장 배열, SwiftUI와 연동하기 위해 @Published 사용,
    //값이 변경될 때 뷰를 자동으로 다시 렌더링한다.
    
    @Published var selectedHome: HMHome? // 사용자가 선택한 홈 저장변수
    @Published var selectedRoom: HMRoom? // 사용자 선택 방 저장변수
    @Published var selectedAccessory: HMAccessory? // 사용자 선택 액세서리 저장 변수
    @Published var brightness: Int = 0 // 조명 밝기 저장 변수

    private var homeManager: HMHomeManager! // 홈킷 관리자 인스턴스

    // 외부에서 사용할 수 있도록 public init()으로 변경
    public override init() {
        super.init()
        homeManager = HMHomeManager()
        homeManager.delegate = self
    }

    // 홈 목록이 업데이트될 때 호출됨
    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        self.homes = homeManager.homes // 홈 목록을 업뎃하여 homes 배열에 저장한다.
        if let firstHome = homes.first {
            self.selectedHome = firstHome
            if let firstRoom = firstHome.rooms.first {
                self.selectedRoom = firstRoom
                if let firstAccessory = firstRoom.accessories.first {
                    self.selectedAccessory = firstAccessory
                }
            }
        }
    }

    // 새로운 홈이 추가될 때 호출됨
    func homeManager(_ manager: HMHomeManager, didAdd home: HMHome) {
        self.homes = homeManager.homes // 새 홈이 추가되었을 때 homes 배열을 업데이트
    }

    // 기존 홈이 제거될 때 호출됨
    func homeManager(_ manager: HMHomeManager, didRemove home: HMHome) {
        self.homes = homeManager.homes // 기존 홈이 제거 시 homes 배열 업뎃
    }
}
