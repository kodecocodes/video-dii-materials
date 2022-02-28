/// Copyright (c) 2022 Razeware LLC
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
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import SwiftUI

struct ColorSlider: View {
  @Binding var sliderValue: Double
  var range: ClosedRange<Double> = 0...1
  var color: Color = .blue

  var body: some View {
    let gradient = LinearGradient(
      colors: [.black, color, .white],
      startPoint: .leading,
      endPoint: .trailing)

    GeometryReader { geometry in
      ZStack(alignment: .leading) {
        gradient
          .cornerRadius(5)
          .frame(height: 10)
        SliderCircleView(
          value: $sliderValue,
          range: range,
          sliderWidth: geometry.size.width)
      }
      .frame(
        width: geometry.size.width,
        height: geometry.size.height,
        alignment: .center)
    }
  }
}

extension ColorSlider {
  struct SliderCircleView: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    let sliderWidth: Double
    let diameter: Double = 30
    @State private var offset: CGSize = .zero

    var sliderValue: Double {
      let percent = Double(offset.width / (sliderWidth - diameter))
      let value = (range.upperBound - range.lowerBound) * percent + range.lowerBound
      return value
    }

    var body: some View {
      let drag = DragGesture()
        .onChanged {
          offset.width = clampWidth(translation: $0.translation.width)
          value = sliderValue
        }

      Circle()
        .foregroundColor(.white)
        .shadow(color: .gray, radius: 1)
        .frame(width: diameter, height: diameter)
        .gesture(drag)
        .offset(offset)
    }

    func clampWidth(translation: Double) -> Double {
      min(sliderWidth - diameter, max(0, offset.width + translation))
    }
  }
}

struct ColorSlider_Previews: PreviewProvider {
  @State static var sliderValue: Double = 0

  static var previews: some View {
    ColorSlider(sliderValue: $sliderValue)
      .padding()
      .background(.secondary)
  }
}
