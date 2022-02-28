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

struct DrawingPath: Identifiable, Equatable {
  var id: UUID = UUID()
  var path = Path()
  var points: [CGPoint] = []
  var color: Color = .black
  
  mutating func addLine(to point: CGPoint,
                        color: Color) {
    if path.isEmpty {
      path.move(to: point)
      self.color = color
    } else {
      path.addLine(to: point)
    }
    points.append(point)
  }
  
  mutating func smoothLine() {
    var newPath = path
    newPath.interpolatePointsWithHermite(interpolationPoints: points)
    path = newPath
  }
}

struct DrawingPadSwiftUI: View {
  @Environment(\.dismiss) var dismiss
  @EnvironmentObject var cellData: CellStore

  @State private var paths: [DrawingPath] = []
  @State private var livePath = DrawingPath()
  @State private var pickedColor: ColorPicker.Color = .black
  @State private var lineWidth = 5.0

  @State var canvasSize = CGSize.zero

  var body: some View {
    let drag = DragGesture(minimumDistance: 0)
      .onChanged { stroke in
        livePath.addLine(to: stroke.location,
                         color: pickedColor.color)
      }
      .onEnded { stroke in
        livePath.smoothLine()
        if !livePath.path.isEmpty { paths.append(livePath) }
        livePath = DrawingPath()
      }

    let canvas =
    Canvas { context, size in
      let style = StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round)

      for path in paths {
        context.stroke(path.path, with: .color(path.color), style: style)
      }
      canvasSize = size
    }

    NavigationView {
      VStack {
        ZStack {
          Color.white
            .ignoresSafeArea()

          ZStack {
            Color.accentColor.opacity(0.2)
            canvas
              .gesture(drag)
          }

          livePath.path.stroke(livePath.color, lineWidth: lineWidth)
        }
        Divider()
        ColorPicker(pickedColor: $pickedColor)
          .frame(height: 80)
      }
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") { dismiss() }
        }

        ToolbarItem(placement: .primaryAction) {
          Button("Done") {
            dismiss()
            if let cell = cellData.selectedCell,
               !paths.isEmpty {
              cellData.updateDrawing(cell: cell, paths: paths, canvasSize: canvasSize)
            }
          }
        }
      }
    }
  }
}

struct DrawingPadSwiftUI_Previews: PreviewProvider {
  static var previews: some View {
    DrawingPadSwiftUI()
  }
}
