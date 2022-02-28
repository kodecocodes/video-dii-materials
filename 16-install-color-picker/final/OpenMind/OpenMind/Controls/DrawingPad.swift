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

struct DrawingPath: Identifiable, Equatable {
  var id = UUID()
  var path = Path()
  var points: [CGPoint] = []
  var color: Color = .black

  mutating func addLine(to point: CGPoint, color: Color) {
    if path.isEmpty {
      path.move(to: point)
      self.color = color
    } else {
      path.addLine(to: point)
    }
    points.append(point)
  }

  mutating func smoothLine() {
    path.interpolatePointsWithHermite(interpolationPoints: points)
  }
}

struct DrawingPad: View {
  @State private var livePath = DrawingPath()
  @State private var paths: [DrawingPath] = []
  let lineWidth: Double = 10
  var pickedColor: Color = .black

  @Binding var savedDrawing: Drawing?

  var body: some View {
    var drawingSize: CGSize = .zero
    let drag = DragGesture(minimumDistance: 0)
      .onChanged { stroke in
        livePath.addLine(to: stroke.location, color: pickedColor)
        livePath.smoothLine()
      }
      .onEnded { stroke in
        livePath.smoothLine()
        if !livePath.path.isEmpty {
          paths.append(livePath)
          savedDrawing?.paths.append(livePath)
          savedDrawing?.size = drawingSize
        }
        livePath = DrawingPath()
      }

    let canvas = Canvas { context, size in
      let style = StrokeStyle(
        lineWidth: lineWidth,
        lineCap: .round,
        lineJoin: .round)

      for drawingPath in paths {
        context.stroke(
          drawingPath.path,
          with: .color(drawingPath.color),
          style: style)
      }

      drawingSize = size
    }

    ZStack {
      Color(uiColor: .systemBackground)
        .ignoresSafeArea()

      canvas
        .gesture(drag)

      livePath.path.stroke(livePath.color, lineWidth: lineWidth)
    }
    .task {
      if let savedPaths = savedDrawing?.paths {
        paths.append(contentsOf: savedPaths)
      } else {
        savedDrawing = Drawing(paths: [])
      }
    }
  }
}

struct DrawingPad_Previews: PreviewProvider {
  static var previews: some View {
    DrawingPad(savedDrawing: .constant(nil))
  }
}
