import HomeKit

class LightController {
    private var blinkTimer: Timer?
    private var isBlinking: Bool = false
    
    func toggleLight(on: Bool, for accessory: HMAccessory) {
        for service in accessory.services {
            if service.serviceType == HMServiceTypeLightbulb {
                for characteristic in service.characteristics {
                    if characteristic.characteristicType == HMCharacteristicTypePowerState {
                        characteristic.writeValue(on) { error in
                            if let error = error {
                                print("Error setting power state: \(error)")
                            }
                        }
                    }
                }
            }
        }
    }

    func changeBrightness(by value: Int, for accessory: HMAccessory, completion: @escaping (Int) -> Void) {
        for service in accessory.services {
            if service.serviceType == HMServiceTypeLightbulb {
                for characteristic in service.characteristics {
                    if characteristic.characteristicType == HMCharacteristicTypeBrightness {
                        characteristic.readValue { error in
                            if let error = error {
                                print("Error reading brightness: \(error)")
                                return
                            }
                            if let currentBrightness = characteristic.value as? Int {
                                var newBrightness = currentBrightness + value
                                newBrightness = min(max(newBrightness, 0), 100)
                                characteristic.writeValue(newBrightness) { error in
                                    if let error = error {
                                        print("Error setting brightness: \(error)")
                                    } else {
                                        print("Successfully set brightness to \(newBrightness)%")
                                        DispatchQueue.main.async {
                                            completion(newBrightness)
                                        }
//                                        completion(newBrightness)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    func changeLightColor(to color: UIColor, for accessory: HMAccessory) {
        for service in accessory.services {
            if service.serviceType == HMServiceTypeLightbulb {
                for characteristic in service.characteristics {
                    if characteristic.characteristicType == HMCharacteristicTypeHue {
                        let hue = color.hueComponent * 360
                        characteristic.writeValue(hue) { error in
                            if let error = error {
                                print("Error setting hue: \(error)")
                            } else {
                                print("Successfully set hue to \(hue)")
                            }
                        }
                    } else if characteristic.characteristicType == HMCharacteristicTypeSaturation {
                        let saturation = color.saturationComponent * 100
                        characteristic.writeValue(saturation) { error in
                            if let error = error {
                                print("Error setting saturation: \(error)")
                            } else {
                                print("Successfully set saturation to \(saturation)%")
                            }
                        }
                    }
                }
            }
        }
    }
    
    func startBlinkingBulb(for accessory: HMAccessory) {
            stopBlinkingBulb() // 이미 실행 중인 타이머가 있으면 중지
            
            var isOn = false
            let blinkInterval = 0.5
            
            blinkTimer = Timer.scheduledTimer(withTimeInterval: blinkInterval, repeats: true) { timer in
                self.toggleLight(on: isOn, for: accessory)
                isOn.toggle()
            }
        }
        
        func stopBlinkingBulb() {
            blinkTimer?.invalidate()
            blinkTimer = nil
        }
    }


extension UIColor {
    var hueComponent: CGFloat {
        var hue: CGFloat = 0
        getHue(&hue, saturation: nil, brightness: nil, alpha: nil)
        return hue
    }

    var saturationComponent: CGFloat {
        var saturation: CGFloat = 0
        getHue(nil, saturation: &saturation, brightness: nil, alpha: nil)
        return saturation
    }
}
