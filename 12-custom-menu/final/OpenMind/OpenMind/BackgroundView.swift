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

struct BackgroundView: View {
  @EnvironmentObject var cellStore: CellStore
  let size: CGSize

  var body: some View {
    let doubleTapDrag = DragGesture(minimumDistance: 0)
    let doubleTap = TapGesture(count: 2)
      .sequenced(before: doubleTapDrag)
      .onEnded { value in
        switch value {
        case .second(_, let drag):
          if let drag = drag {
            print("add new cell at: ", drag.location)
            newCell(location: drag.location)
          }
        default: break
        }
      }
    
    ZStack {
      Color.teal.opacity(0.7)
        .ignoresSafeArea()
        .onTapGesture { cellStore.selectedCell = nil }
        .simultaneousGesture(doubleTap)

      ForEach(cellStore.cells) { cell in
        CellView(cell: cell)
      }
    }
  }

  func newCell(location: CGPoint) {
    let offset = CGSize(
      width: location.x - size.width / 2,
      height: location.y - size.height / 2
    )
    let cell = cellStore.addCell(offset: offset)
    cellStore.selectedCell = cell
  }
}

struct BackgroundView_Previews: PreviewProvider {
  static var previews: some View {
    BackgroundView(size: CGSize(width: 400, height: 800))
      .environmentObject(CellStore())
  }
}
