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
  @EnvironmentObject var cellStore: CellStore

  @State private var text: String = ""
  @State var dashPhase: Double = 0
  @State private var offset: CGSize = .zero
  @State private var currentOffset: CGSize = .zero

  let cell: Cell
  var isSelected: Bool {
    cell == cellStore.selectedCell
  }

  var body: some View {
    let basicStyle = StrokeStyle(lineWidth: 5, lineJoin: .round)
    let selectedStyle = StrokeStyle(
      lineWidth: 7, lineCap: .round, lineJoin: .round,
      dash: [50, 10, 20, 10, 10, 10, 5, 10, 5, 10], dashPhase: dashPhase)

    let drag = DragGesture()
      .onChanged { drag in
        offset = currentOffset + drag.translation
      }
      .onEnded { drag in
        offset = currentOffset + drag.translation
        currentOffset = offset
      }

    ZStack {
      cell.shape.shape
        .foregroundColor(.white)
      
      if isSelected {
        cell.shape.shape
          .stroke(cell.color, style: selectedStyle)

        TimelineView(.periodic(from: .now, by: 0.3)) { context in
          cell.shape.shape
            .stroke(cell.color.opacity(0.7), style: selectedStyle)
            .onChange(of: context.date) { (date: Date) in
              dashPhase += 6
            }
        }
      } else {
        cell.shape.shape
          .stroke(cell.color, style: basicStyle)
      }

      TextField("Enter cell text", text: $text)
        .padding()
        .multilineTextAlignment(.center)
    }
    .frame(width: cell.size.width, height: cell.size.height)
    .offset(cell.offset + offset)
    .onAppear { text = cell.text }
    .onTapGesture { cellStore.selectedCell = cell }
    .simultaneousGesture(drag)
  }
}

struct CellView_Previews: PreviewProvider {
  static var previews: some View {
    CellView(cell: Cell())
      .previewLayout(.sizeThatFits)
      .padding()
      .environmentObject(CellStore())

    HeartExample()
  }
}


//MARK: - Heart Example
struct HeartExample: View {
  @State var dashPhase: Double = 0

  var body: some View {
    let selectedStyle = StrokeStyle(
      lineWidth: 8,
      lineCap: .round,
      lineJoin: .round,
      dash: [50, 20, 20, 20, 10, 15, 5, 15, 5, 15],
      dashPhase: dashPhase)

    TimelineView(.animation) { context in
      VStack {
        Heart().stroke(.teal, style: selectedStyle)
        MirroredHeart().stroke(.red, style: selectedStyle)
      }
      .onChange(of: context.date) { (date: Date) in
        withAnimation {
          dashPhase += 1
        }
      }
    }
    .padding()
  }
}

struct MirroredHeart: Shape {
  func path(in rect: CGRect) -> Path {
    var path = Path()

    let bottom = CGPoint(x: rect.width * 0.5, y: rect.height)
    let leftSide = CGPoint(x: 0, y: rect.height * 0.25)
    let leftTop = CGPoint(x: rect.width * 0.25, y: 0)
    let midTop = CGPoint(x: rect.width * 0.5, y: rect.height * 0.25)

    let sideControl = CGPoint(x: 0, y: rect.height * 0.75)
    let cornerControl = CGPoint.zero
    let midControl = CGPoint(x: rect.width * 0.5, y: 0)

    path.move(to: bottom)
    path.addCurve(to: leftSide, control1: bottom, control2: sideControl)
    path.addCurve(to: leftTop, control1: leftSide, control2: cornerControl)
    path.addCurve(to: midTop, control1: midControl, control2: midTop)

    let flip = CGAffineTransform(translationX: rect.width, y: 0)
      .scaledBy(x: -1, y: 1)
    path.addPath(path, transform: flip)
    return path
  }
}


