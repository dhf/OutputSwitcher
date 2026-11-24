// Renders the OutputSwitcher app icon (1024 x 1024 PNG): headphones with swap arrows
// on a blue-to-purple tile. Usage: swift Scripts/make_icon.swift <output.png>
import AppKit

let canvas = 1024
guard CommandLine.arguments.count > 1 else {
    FileHandle.standardError.write(Data("usage: make_icon.swift <output.png>\n".utf8))
    exit(1)
}
let outputURL = URL(fileURLWithPath: CommandLine.arguments[1])

guard let rep = NSBitmapImageRep(
    bitmapDataPlanes: nil, pixelsWide: canvas, pixelsHigh: canvas, bitsPerSample: 8,
    samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB,
    bytesPerRow: 0, bitsPerPixel: 0
), let graphics = NSGraphicsContext(bitmapImageRep: rep) else { exit(1) }
NSGraphicsContext.current = graphics

func color(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat = 1) -> NSColor {
    NSColor(srgbRed: r, green: g, blue: b, alpha: a)
}

// MARK: Tile (macOS icon grid: 824 pt rounded square inside a 1024 canvas)

let tile = NSRect(x: 100, y: 100, width: 824, height: 824)
let tilePath = NSBezierPath(roundedRect: tile, xRadius: 185, yRadius: 185)

NSGraphicsContext.saveGraphicsState()
let tileShadow = NSShadow()
tileShadow.shadowColor = color(0, 0, 0, 0.35)
tileShadow.shadowOffset = NSSize(width: 0, height: -14)
tileShadow.shadowBlurRadius = 28
tileShadow.set()
color(0, 0, 0).setFill()
tilePath.fill()
NSGraphicsContext.restoreGraphicsState()

NSGradient(colors: [color(0.43, 0.20, 0.93), color(0.27, 0.62, 1.0)])?.draw(in: tilePath, angle: 70)

// Soft highlight near the top edge.
NSGraphicsContext.saveGraphicsState()
tilePath.addClip()
NSGradient(colors: [color(1, 1, 1, 0.30), color(1, 1, 1, 0)])?.draw(
    fromCenter: NSPoint(x: 512, y: 930), radius: 0, toCenter: NSPoint(x: 512, y: 930), radius: 560, options: []
)
NSGraphicsContext.restoreGraphicsState()

// MARK: Glyph

NSGraphicsContext.saveGraphicsState()
let move = NSAffineTransform()
move.translateX(by: 0, yBy: -30) // centre the glyph vertically on the tile
move.concat()

let glyphShadow = NSShadow()
glyphShadow.shadowColor = color(0.1, 0.0, 0.3, 0.35)
glyphShadow.shadowOffset = NSSize(width: 0, height: -12)
glyphShadow.shadowBlurRadius = 24
glyphShadow.set()

// Headband.
let band = NSBezierPath()
band.appendArc(withCenter: NSPoint(x: 512, y: 500), radius: 228, startAngle: 0, endAngle: 180)
band.lineWidth = 58
band.lineCapStyle = .round
color(1, 1, 1).setStroke()
band.stroke()

// Ear cups with a subtle inner cushion.
for centerX in [CGFloat(284), CGFloat(740)] {
    let cup = NSBezierPath(
        roundedRect: NSRect(x: centerX - 60, y: 330, width: 120, height: 230), xRadius: 56, yRadius: 56
    )
    color(1, 1, 1).setFill()
    cup.fill()
}

NSGraphicsContext.restoreGraphicsState()

NSGraphicsContext.saveGraphicsState()
move.concat()
// Two swap arrows between the cups: the "switch output" motif.
func arrow(from start: NSPoint, to end: NSPoint, headDirection: CGFloat) -> NSBezierPath {
    let path = NSBezierPath()
    path.move(to: start)
    path.line(to: end)
    // Arrowhead: two short strokes folding back from the tip.
    let size: CGFloat = 38
    path.move(to: NSPoint(x: end.x - headDirection * size, y: end.y + size))
    path.line(to: end)
    path.line(to: NSPoint(x: end.x - headDirection * size, y: end.y - size))
    path.lineWidth = 34
    path.lineCapStyle = .round
    path.lineJoinStyle = .round
    return path
}
color(1, 1, 1, 0.95).setStroke()
arrow(from: NSPoint(x: 414, y: 520), to: NSPoint(x: 612, y: 520), headDirection: 1).stroke()
arrow(from: NSPoint(x: 612, y: 380), to: NSPoint(x: 414, y: 380), headDirection: -1).stroke()
NSGraphicsContext.restoreGraphicsState()

// MARK: Write

NSGraphicsContext.current = nil
guard let png = rep.representation(using: .png, properties: [:]) else { exit(1) }
try png.write(to: outputURL)
print("Wrote \(outputURL.path)")
