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

struct CellView: View {
  let cell: Cell
  @State private var text: String = ""
  @EnvironmentObject var cellStore: CellStore

  var isSelected: Bool {
    cell == cellStore.selectedCell
  }

  var body: some View {
    let basicStyle = StrokeStyle(lineWidth: 5, lineJoin: .round)
    let selectedStyle = StrokeStyle(lineWidth: 7, lineCap: .round, lineJoin: .round,
                                    dash: [50, 15, 30, 15, 15, 15, 5, 10, 5, 15], dashPhase: 0)

    ZStack {
      cell.shape?.shape
        .foregroundColor(.white)
      cell.shape?.shape
        .stroke(cell.color, style: isSelected ? selectedStyle : basicStyle)

      TextField("Enter cell text", text: $text)
        .padding()
        .multilineTextAlignment(.center)
    }
    .frame(width: cell.size.width, height: cell.size.height)
    .offset(cell.offset)
    .onAppear { text = cell.text }
    .onTapGesture { cellStore.selectedCell = cell }
  }
}

struct CellView_Previews: PreviewProvider {
  static var previews: some View {
    CellView(cell: Cell())
      .previewLayout(.sizeThatFits)
      .padding()
      .environmentObject(CellStore())
  }
}
