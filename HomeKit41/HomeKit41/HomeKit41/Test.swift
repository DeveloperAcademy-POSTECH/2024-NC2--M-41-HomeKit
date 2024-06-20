//import SwiftUI
//
//enum AccessoryType {
//    case select
//    case aquraHub
//    case PhilpsHue
//    case NanoleafShape
//}
//
//enum ColorType {
//    case select
//    case red
//    case orange
//    case yellow
//    case green
//    case blue
//    case purple
//    case random
//}
//
//struct RoomView: View {
//    @State var accessoryType = AccessoryType.select
//    @State var colorType = ColorType.select
//    @State var addFavorite = false
//    @State var title: String = ""
//    
//    @State private var showingTimePicker = false
//    @State private var selectedTime = Date()
//    @State private var isButtonPressed = false
//    @State private var navigateToEmptyView = false
//    @State private var favoriteSet = false
//    
//    var body: some View {
//        NavigationStack{
//            Form {
//                Section{
//                    Picker("악세서리", selection: $accessoryType){
//                        Text("악세서리 선택...").tag(AccessoryType.select)
//                        Text("aquarHub").tag(AccessoryType.aquraHub)
//                        Text("PhilpsHue").tag(AccessoryType.PhilpsHue)
//                        Text("NanoleafShape").tag(AccessoryType.NanoleafShape)
//                    }
//                }
//                Section {
//                    HStack {
//                        Text("타이머")
//                        Spacer()
//                        Button(action: {
//                            showingTimePicker.toggle()
//                            isButtonPressed.toggle()
//                        }) {
//                            Text(formattedTime)
//                                .padding(.horizontal, 12)
//                                .padding(.vertical, 8)
//                                .background(Color.BGSecondary)
//                                .foregroundColor(isButtonPressed ? Color.DarkYellow : Color.black)
//                                .cornerRadius(8)
//                        }
//                    }
//                    .listRowInsets(EdgeInsets())
//                    .padding(.leading, 16)
//                    .padding(.trailing, 8)
//                    
//                    if showingTimePicker {
//                        DatePicker(
//                            "Select Time",
//                            selection: $selectedTime,
//                            displayedComponents: [.hourAndMinute]
//                        )
//                        .datePickerStyle(WheelDatePickerStyle())
//                    }
//                }
//                Section {
//                    TextField("타이머 제목을 입력하세요", text: $title)
//                    Picker("깜빡일 때 조명 색상 선택", selection: $colorType ){
//                        Text("색상 선택...").tag(ColorType.select)
//                        Text("빨강").tag(ColorType.red)
//                        Text("주황").tag(ColorType.orange)
//                        Text("노랑").tag(ColorType.yellow)
//                        Text("초록").tag(ColorType.green)
//                        Text("파랑").tag(ColorType.blue)
//                        Text("보라").tag(ColorType.purple)
//                        Text("무작위").tag(ColorType.random)
//                    }
//                }
//                //                Section {
//                //                          Toggle(isOn: $favoriteSet) {
//                //                            Text("즐겨찾기에 추가")
//                //                          }
//                //                        }
//                //                .navigationBarTitle("거실")
//                //                .toolbar {
//                //                    ToolbarItem(placement: .navigationBarTrailing) {
//                //                        Button("완료") {
//                //                            navigateToEmptyView = true
//                //                        }
//                //                        .foregroundColor(Color.darkYellow)
//                //
//                //                    }
//                //                }
//            }
//        }
//        var formattedTime: String {
//            let formatter = DateFormatter()
//            formatter.timeStyle = .short
//            return formatter.string(from: selectedTime)
//        }
//    }
//}
//
//
//#Preview{
//    RoomView()
//}
