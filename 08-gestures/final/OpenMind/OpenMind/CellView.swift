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
  let cell: Cell
  @State private var text: String = ""
  @FocusState var textFieldIsFocused: Bool
  @State private var offset: CGSize = .zero
  @State private var currentOffset: CGSize = .zero

  var isSelected: Bool {
    cell == cellStore.selectedCell
  }

  var body: some View {
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
        .foregroundColor(Color(uiColor: .systemBackground))
      TimelineView(.animation(minimumInterval: 0.2)) { context in
        StrokeView(cell: cell, isSelected: isSelected, date: context.date)
      }

      TextField("Enter cell text", text: $text)
        .padding()
        .multilineTextAlignment(.center)
        .focused($textFieldIsFocused)
    }
    .onAppear { text = cell.text }
    .onChange(of: isSelected) { isSelected in
      if !isSelected { textFieldIsFocused = false }
    }
    .frame(width: cell.size.width, height: cell.size.height)
    .offset(cell.offset + offset)
    .onTapGesture { cellStore.selectedCell = cell }
    .simultaneousGesture(drag)
  }
}

extension CellView {
  struct StrokeView: View {
    let cell: Cell
    let isSelected: Bool
    let date: Date
    @State var dashPhase: Double = 0

    var body: some View {
      let basicStyle = StrokeStyle(lineWidth: 5, lineJoin: .round)
      let selectedStyle = StrokeStyle(
        lineWidth: 7, lineCap: .round, lineJoin: .round,
        dash: [50, 10, 20, 10, 20, 10, 5, 10, 5, 10], dashPhase: dashPhase)

      cell.shape.shape
        .stroke(
          cell.color.opacity(isSelected ? 0.8 : 1),
          style: isSelected ? selectedStyle : basicStyle)
        .onChange(of: date) { _ in
          dashPhase += 8
        }
    }
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

// MARK: - Heart Example
struct HeartExample: View {
  @State var dashPhase: Double = 0

  var body: some View {
    let style = StrokeStyle(
      lineWidth: 8,
      lineCap: .round,
      lineJoin: .round,
      dash: [50, 20, 20, 20, 10, 15, 5, 15, 5, 15],
      dashPhase: dashPhase)

    TimelineView(.animation) { context in
      VStack {
        Heart().stroke(.teal, style: style)
        MirroredHeart().stroke(.red, style: style)
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
