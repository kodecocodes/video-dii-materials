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

struct DrawingPadView: View {
  @Environment(\.dismiss) var dismiss
  @EnvironmentObject var cellStore: CellStore

  @State private var drawing: Drawing?
  @State private var pickedColor = ColorPicker.Color.black
  @State private var sliderValue: Double = 0

  var body: some View {
    VStack {
      HStack {
        Button("Cancel") { dismiss() }
        Spacer()
        Button("Save") {
          if let cell = cellStore.selectedCell,
             let drawing = drawing {
            cellStore.updateDrawing(cell: cell, drawing: drawing)
          }
          dismiss()
        }
      }
      .padding()

      Divider()

      DrawingPad(pickedColor: pickedColor.color.opacity(1 - sliderValue), savedDrawing: $drawing)

      Divider()

      ColorSlider(sliderValue: $sliderValue, colors: [pickedColor.color, pickedColor.color.opacity(0)])
        .frame(height: 60)
        .padding(.horizontal)
      ColorPicker(pickedColor: $pickedColor)
        .frame(height: 80)
    }
    .task {
      drawing = cellStore.selectedCell?.drawing
    }
  }
}

struct DrawingPadView_Previews: PreviewProvider {
  static var previews: some View {
    DrawingPadView()
      .environmentObject(CellStore())
  }
}
