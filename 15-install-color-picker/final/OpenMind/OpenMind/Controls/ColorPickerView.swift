//
/// Copyright (c) 2019 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import SwiftUI

struct ColorPickerView: View {
  @State var pickedColor: ColorPicker.Color = .red
  var body: some View {
    VStack {
      Circle()
        .foregroundColor(pickedColor.color)
        .frame(width: 250)
      ColorPicker(pickedColor: $pickedColor)
    }
  }
}

struct ColorPicker: View {
  @Binding var pickedColor: ColorPicker.Color
  
  let diameter: CGFloat = 40
  
  var body: some View {
    HStack {
      ForEach(Color.allCases, id: \.self) { pickedColor in
        ZStack {
          Circle()
            .foregroundColor(pickedColor.color)
            .frame(width: diameter,
                   height: diameter)
            .onTapGesture {
              self.pickedColor = pickedColor
          }
          Circle()
            .foregroundColor(.white)
            .frame(width: self.pickedColor == pickedColor ? self.diameter * 0.25 : 0)
        }
      }
    }
    .frame(height: diameter * 3)
  }
}

extension ColorPicker {
  enum Color: CaseIterable {
    case black, blue, green, orange, red, yellow

    var color: SwiftUI.Color {
      return SwiftUI.Color(uiColor)
    }

    var uiColor: UIColor {
      switch self {
      case .black:
        return UIColor(named: "Black")!
      case .blue:
        return UIColor(named: "Blue")!
      case .green:
        return UIColor(named: "Green")!
      case .orange:
        return UIColor(named: "Orange")!
      case .red:
        return UIColor(named: "Red")!
      case .yellow:
        return UIColor(named: "Yellow")!
      }
    }
  }
}

struct ColorPickerView_Previews: PreviewProvider {
  static var previews: some View {
    ColorPickerView()
  }
}
