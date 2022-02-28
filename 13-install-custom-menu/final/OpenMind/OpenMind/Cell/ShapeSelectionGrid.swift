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

struct AnyShape: Shape {
  private let path: (CGRect) -> Path

  init<T: Shape> (_ shape: T) {
    path = { rect in
      return shape.path(in: rect)
    }
  }

  func path(in rect: CGRect) -> Path {
    path(rect)
  }
}

extension Shape {
  func anyShape() -> AnyShape {
    AnyShape(self)
  }
}

enum CellShape: CaseIterable {
  case rectangle
  case ellipse
  case diamond
  case chevron
  case heart
  case roundedRect

  var shape: some Shape {
    switch self {
    case .rectangle: return Rectangle().anyShape()
    case .ellipse: return Ellipse().anyShape()
    case .chevron: return Chevron().anyShape()
    case .diamond: return Diamond().anyShape()
    case .heart: return Heart().anyShape()
    case .roundedRect: return RoundedRectangle(cornerRadius: 30).anyShape()
    }
  }
}

struct ShapeSelectionGrid: View {
  @Environment(\.dismiss) var dismiss
  @Binding var selectedCellShape: CellShape

  var body: some View {
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)

    LazyVGrid(columns: columns, alignment: .center, spacing: 10) {
      ForEach(CellShape.allCases, id: \.self) { cellShape in
        cellShape.shape
          .foregroundColor(.accentColor.opacity(0.3))
          .overlay {
            cellShape.shape
              .stroke(style: StrokeStyle(lineWidth: 5, lineJoin: .round))
              .foregroundColor(.accentColor)
          }
          .onTapGesture {
            selectedCellShape = cellShape
            dismiss()
          }
      }
      .aspectRatio(2, contentMode: .fit)
      .padding()
    }
  }
}

struct Chevron: Shape {
  func path(in rect: CGRect) -> Path {
    Path { path in
      path.addLines([
        .zero,
        CGPoint(x: rect.width * 0.75, y: 0),
        CGPoint(x: rect.width, y: rect.height * 0.5),
        CGPoint(x: rect.width * 0.75, y: rect.height),
        CGPoint(x: 0, y: rect.height),
        CGPoint(x: rect.width * 0.25, y: rect.height * 0.5)
      ])
      path.closeSubpath()
    }
  }
}

struct Diamond: Shape {
  func path(in rect: CGRect) -> Path {
    Path { path in
      let width = rect.width
      let height = rect.height

      path.addLines( [
        CGPoint(x: width / 2, y: 0),
        CGPoint(x: width, y: height / 2),
        CGPoint(x: width / 2, y: height),
        CGPoint(x: 0, y: height / 2)
      ])
      path.closeSubpath()
    }
  }
}

struct Heart: Shape {
  func path(in rect: CGRect) -> Path {
    var path = Path()

    let flip = CGAffineTransform(translationX: rect.width, y: 0)
      .scaledBy(x: -1, y: 1)

    let bottom = CGPoint(x: rect.width * 0.5, y: rect.height)
    let leftSide = CGPoint(x: 0, y: rect.height * 0.25)
    let leftTop = CGPoint(x: rect.width * 0.25, y: 0)
    let midTop = CGPoint(x: rect.width * 0.5, y: rect.height * 0.25)

    let rightSide = leftSide.applying(flip)
    let rightTop = leftTop.applying(flip)

    let sideControl = CGPoint(x: 0, y: rect.height * 0.75)
    let cornerControl = CGPoint.zero
    let midControl = CGPoint(x: rect.width * 0.5, y: 0)

    path.move(to: bottom)
    path.addCurve(to: leftSide, control1: bottom, control2: sideControl)
    path.addCurve(to: leftTop, control1: leftSide, control2: cornerControl)
    path.addCurve(to: midTop, control1: midControl, control2: midTop)
    path.addCurve(to: rightTop, control1: midTop, control2: midControl)
    path.addCurve(to: rightSide, control1: cornerControl.applying(flip), control2: rightSide)
    path.addCurve(to: bottom, control1: sideControl.applying(flip), control2: bottom)

    path.closeSubpath()
    return path
  }
}

struct Shapes_Previews: PreviewProvider {
  static var previews: some View {
    ShapeSelectionGrid(selectedCellShape: .constant(.heart))
  }
}
