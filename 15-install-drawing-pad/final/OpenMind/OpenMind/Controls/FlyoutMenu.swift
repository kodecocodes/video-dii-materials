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

import Algorithms
import SwiftUI

struct FlyoutMenu: View {
  struct Option {
    var image: Image
    var color: Color
    var action: () -> Void = {}
  }

  let options: [Option]
  let iconDiameter: Double = 44
  let menuDiameter: Double = 150
  @State var isOpen = false

  var body: some View {
    ZStack {
      Circle()
        .foregroundColor(.pink)
        .opacity(0.1)
        .frame(width: isOpen ? menuDiameter + iconDiameter : 0)

      ForEach(options.indexed(), id: \.index) { index, option in
        button(option: option, atIndex: index)
          .scaleEffect(isOpen ? 1 : 0.1)
      }
      .disabled(!isOpen)

      MainView(iconDiameter: iconDiameter, isOpen: $isOpen)
    }
  }

  func button(option: Option, atIndex index: Int) -> some View {
    let angle = .pi / 4 * Double(index) - .pi * (isOpen ? 0.6 : 1)
    let radius = menuDiameter / 2

    return Button(action: option.action) {
      ZStack {
        Circle()
          .foregroundColor(option.color)
          .frame(width: iconDiameter, height: iconDiameter)
        option.image
          .font(.title2)
          .foregroundColor(.white)
      }
    }
    .offset(x: cos(angle) * radius, y: sin(angle) * radius)
  }
}

private extension FlyoutMenu {
  struct MainView: View {
    let iconDiameter: Double
    @Binding var isOpen: Bool

    var body: some View {
      Button {
        withAnimation(.spring()) {
          isOpen.toggle()
        }
      } label: {
        ZStack {
          Circle()
            .foregroundColor(.red)
            .frame(width: iconDiameter, height: iconDiameter)
          Image(systemName: "plus")
            .foregroundColor(.white)
            .font(.title)
            .rotationEffect(isOpen ? .degrees(45) : .degrees(0))
        }
      }
    }
  }
}

struct FlyoutMenu_Previews: PreviewProvider {
  static var options: [FlyoutMenu.Option] = [
    .init(image: .init(systemName: "trash"), color: .blue),
    .init(image: .init(systemName: "pawprint"), color: .orange),
    .init(image: .init(systemName: "book"), color: .teal),
    .init(image: .init(systemName: "flame"), color: .red),
    .init(image: .init(systemName: "link"), color: .purple)
  ]

  static var previews: some View {
    FlyoutMenu(options: options)
  }
}
