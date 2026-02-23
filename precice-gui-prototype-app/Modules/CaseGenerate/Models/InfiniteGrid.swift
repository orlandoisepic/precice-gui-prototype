
import SwiftUI
    // A grid pattern that looks like it extends beyond the open window
    // (i.e., if the window is enlarged / the backround is moved, the grid is still there)
struct InfiniteGridPattern: Shape {
    var panOffset: CGPoint
    let spacing: CGFloat = 30
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        
            // Calculate the remainder so that grid loops infinitely
        let offX = panOffset.x.truncatingRemainder(dividingBy: spacing)
        let offY = panOffset.y.truncatingRemainder(dividingBy: spacing)
        
        for x in stride(from: 0, to: width, by: spacing) {
            for y in stride(from: 0, to: height, by: spacing) {
                    // Shift the dot by the remainder
                let point = CGPoint(x: x + offX, y: y + offY)
                let dotRect = CGRect(origin: point, size: CGSize(width: 1, height: 1))
                path.addEllipse(in: dotRect)
            }
        }
        return path
    }
}
