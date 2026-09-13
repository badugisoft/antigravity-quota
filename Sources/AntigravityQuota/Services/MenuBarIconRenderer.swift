import Cocoa

/// Renders a dynamic Antigravity menu bar icon featuring a geometric logo encircled by a circular quota gauge ring.
public final class MenuBarIconRenderer {
    public static let shared = MenuBarIconRenderer()
    
    private let iconSize = NSSize(width: 18, height: 18)
    
    /// Renders a template NSImage representing the Antigravity logo with an outer circular gauge ring.
    /// - Parameters:
    ///   - remainingFraction: 0.0 to 1.0 (lowest remaining quota fraction)
    ///   - isOnline: Whether Antigravity is active and connected
    /// - Returns: A template NSImage optimized for macOS menu bar appearance.
    public func renderIcon(remainingFraction: Double, isOnline: Bool) -> NSImage {
        let image = NSImage(size: iconSize, flipped: false) { [weak self] bounds in
            guard self != nil else { return false }
            
            let context = NSGraphicsContext.current?.cgContext
            context?.saveGState()
            
            let center = CGPoint(x: bounds.midX, y: bounds.midY)
            let radius: CGFloat = 7.5
            let lineWidth: CGFloat = 1.5
            
            // 1. Draw outer gauge track (subtle background ring)
            let trackColor = NSColor.labelColor.withAlphaComponent(0.22)
            trackColor.setStroke()
            let trackPath = NSBezierPath()
            trackPath.lineWidth = lineWidth
            trackPath.appendArc(withCenter: center, radius: radius, startAngle: 0, endAngle: 360)
            trackPath.stroke()
            
            // 2. Draw outer gauge arc (progress)
            if isOnline {
                let clamped = max(0.0, min(1.0, remainingFraction))
                if clamped > 0.01 {
                    let startAngle: CGFloat = 90.0 // Top (12 o'clock)
                    let endAngle: CGFloat = startAngle - CGFloat(clamped * 360.0)
                    
                    let gaugeColor = NSColor.labelColor.withAlphaComponent(0.95)
                    gaugeColor.setStroke()
                    
                    let gaugePath = NSBezierPath()
                    gaugePath.lineWidth = lineWidth
                    gaugePath.lineCapStyle = .round
                    gaugePath.appendArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
                    gaugePath.stroke()
                }
            } else {
                // Offline / Paused indicator: dashed ring
                let pausedColor = NSColor.labelColor.withAlphaComponent(0.5)
                pausedColor.setStroke()
                
                let dashedPath = NSBezierPath()
                dashedPath.lineWidth = lineWidth
                let pattern: [CGFloat] = [2.0, 2.0]
                dashedPath.setLineDash(pattern, count: 2, phase: 0.0)
                dashedPath.appendArc(withCenter: center, radius: radius, startAngle: 0, endAngle: 360)
                dashedPath.stroke()
            }
            
            // 3. Draw central Antigravity arch logo glyph (smooth upward arch / defying gravity)
            let glyphColor = NSColor.labelColor.withAlphaComponent(isOnline ? 0.95 : 0.6)
            glyphColor.setFill()
            
            let logoPath = NSBezierPath()
            let topApex = CGPoint(x: center.x, y: center.y + 3.8)
            let innerApex = CGPoint(x: center.x, y: center.y - 0.2)
            
            // Start at left foot bottom outer edge
            logoPath.move(to: CGPoint(x: center.x - 4.6, y: center.y - 3.2))
            
            // Outer left curve: flared bottom leg curving up to broad dome
            logoPath.curve(
                to: topApex,
                controlPoint1: CGPoint(x: center.x - 2.8, y: center.y - 1.0),
                controlPoint2: CGPoint(x: center.x - 2.2, y: center.y + 3.8)
            )
            
            // Outer right curve: broad dome down to flared right leg
            logoPath.curve(
                to: CGPoint(x: center.x + 4.6, y: center.y - 3.2),
                controlPoint1: CGPoint(x: center.x + 2.2, y: center.y + 3.8),
                controlPoint2: CGPoint(x: center.x + 2.8, y: center.y - 1.0)
            )
            
            // Right foot bottom rounded cap
            logoPath.curve(
                to: CGPoint(x: center.x + 3.2, y: center.y - 3.5),
                controlPoint1: CGPoint(x: center.x + 4.5, y: center.y - 4.1),
                controlPoint2: CGPoint(x: center.x + 3.6, y: center.y - 4.1)
            )
            
            // Inner right arch: from right foot inner edge to inner apex
            logoPath.curve(
                to: innerApex,
                controlPoint1: CGPoint(x: center.x + 2.3, y: center.y - 1.8),
                controlPoint2: CGPoint(x: center.x + 1.4, y: center.y - 0.2)
            )
            
            // Inner left arch: from inner apex down to left foot inner edge
            logoPath.curve(
                to: CGPoint(x: center.x - 3.2, y: center.y - 3.5),
                controlPoint1: CGPoint(x: center.x - 1.4, y: center.y - 0.2),
                controlPoint2: CGPoint(x: center.x - 2.3, y: center.y - 1.8)
            )
            
            // Left foot bottom rounded cap
            logoPath.curve(
                to: CGPoint(x: center.x - 4.6, y: center.y - 3.2),
                controlPoint1: CGPoint(x: center.x - 3.6, y: center.y - 4.1),
                controlPoint2: CGPoint(x: center.x - 4.5, y: center.y - 4.1)
            )
            
            logoPath.close()
            logoPath.fill()
            
            context?.restoreGState()
            return true
        }
        
        image.isTemplate = true
        return image
    }
}
