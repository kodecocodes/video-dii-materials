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

struct DrawingView: View {
  let drawing: Drawing

  var body: some View {
    let scale = drawing.canvasSize.scale(toFit: minCellSize)
    let style = StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round)
    ZStack {
      ForEach(drawing.paths) { path in
        let scaledPath = path.path.applying(scale)
        scaledPath.stroke(style: style)
          .foregroundColor(path.color)
      }
    }
    .aspectRatio(drawing.canvasSize, contentMode: .fit)
  }
}

struct CellView: View {
  @EnvironmentObject var cellStore: CellStore
  @EnvironmentObject var modalViews: ContentView.ModalViews

  let cell: Cell
  @State private var text: String = ""
  @State var dashPhase: Double = 0
  @State private var offset: CGSize = .zero
  @State private var currentOffset: CGSize = .zero
  @FocusState var textFieldIsFocused: Bool

  var isSelected: Bool { cell == cellStore.selectedCell }

  var body: some View {
    let basicStyle = StrokeStyle(lineWidth: 5, lineJoin: .round)
    let selectedStyle = StrokeStyle(
      lineWidth: 7, lineCap: .round, lineJoin: .round,
      dash: [50, 10, 20, 10, 10, 10, 5, 10, 5, 10], dashPhase: dashPhase)

    let flyoutMenu = FlyoutMenu(options: setupOptions())

    let drag = DragGesture()
      .onChanged { drag in
        offset = currentOffset + drag.translation
      }
      .onEnded { drag in
        offset = currentOffset + drag.translation
        currentOffset = offset
      }

    return ZStack {
      // MARK: Shape
      cell.shape.shape
        .foregroundColor(.white)

      // MARK: Outline
      if isSelected {
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

      // MARK: Drawing or Text
      if let drawing = cell.drawing {
        DrawingView(drawing: drawing)
      } else {
        TextField("Enter cell text", text: $text)
          .focused($textFieldIsFocused)
          .multilineTextAlignment(.center)
          .padding()
      }

      // MARK: Flyout Menu
      if isSelected {
        flyoutMenu
          .offset(x: cell.size.width / 2,
                  y: -cell.size.height / 2)
      }
    }
    .frame(width: cell.size.width, height: cell.size.height)
    .offset(cell.offset + offset)
    .onAppear { text = cell.text }
    .onChange(of: isSelected) { isSelected in
      if !isSelected { textFieldIsFocused = false }
    }
    .onTapGesture { cellStore.selectedCell = cell }
    .simultaneousGesture(drag)
  }
}

// MARK: - CellView Flyout Menu
extension CellView {
  static var crayonImage: Image {
    let config =
    UIImage.SymbolConfiguration(pointSize: 20,
                                weight: .medium,
                                scale: .medium)
    return Image(uiImage: UIImage(named: "crayon")!
      .withConfiguration(config))
      .renderingMode(.template)
  }

  func setupOptions() -> [FlyoutMenu.Option] {
    let flyoutMenuOptions: [FlyoutMenu.Option] = [
      FlyoutMenu.Option(image: Image(systemName: "trash"), color: .blue) {
        cellStore.delete(cell: cell)
      },
      FlyoutMenu.Option(image: Image(systemName: "square.on.circle"), color: .green) {
        modalViews.showShapes = true
      },
      FlyoutMenu.Option(image: Image(systemName: "link"), color: .purple) {
        print("link!")
      },
      FlyoutMenu.Option(image: Self.crayonImage, color: .orange) {
        modalViews.showDrawingPad = true
      }
    ]
    return flyoutMenuOptions
  }
}

// MARK: - Previews
struct CellView_Previews: PreviewProvider {
  static var previews: some View {
      CellView(cell: Cell())
        .previewLayout(.sizeThatFits)
        .padding()
        .environmentObject(CellStore())
  }
}
