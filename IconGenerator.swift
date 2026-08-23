import AppKit
import CoreGraphics
import ImageIO
import Foundation

private let sizes = [16, 32, 128, 256, 512, 1024]

private func color(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat = 1) -> CGColor {
    CGColor(red: red, green: green, blue: blue, alpha: alpha)
}

private func drawIcon(size: Int) -> CGImage? {
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    guard let context = CGContext(
        data: nil,
        width: size,
        height: size,
        bitsPerComponent: 8,
        bytesPerRow: size * 4,
        space: colorSpace,
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    ) else { return nil }

    let canvas = CGRect(x: 0, y: 0, width: size, height: size)
    let scale = CGFloat(size) / 1024
    context.scaleBy(x: scale, y: scale)
    context.setAllowsAntialiasing(true)
    context.setShouldAntialias(true)

    let backgroundPath = CGPath(roundedRect: CGRect(x: 20, y: 20, width: 984, height: 984), cornerWidth: 224, cornerHeight: 224, transform: nil)
    context.addPath(backgroundPath)
    context.clip()
    let backgroundGradient = CGGradient(
        colorsSpace: colorSpace,
        colors: [color(0.035, 0.075, 0.16), color(0.075, 0.16, 0.30)] as CFArray,
        locations: [0, 1]
    )!
    context.drawLinearGradient(
        backgroundGradient,
        start: CGPoint(x: 120, y: 940),
        end: CGPoint(x: 900, y: 120),
        options: []
    )
    context.resetClip()

    // Soft blue halo behind the shield.
    context.saveGState()
    context.setShadow(offset: .zero, blur: 42, color: color(0.10, 0.55, 1.0, 0.45))
    context.setFillColor(color(0.08, 0.40, 0.78, 0.42))
    context.fillEllipse(in: CGRect(x: 190, y: 112, width: 644, height: 740))
    context.restoreGState()

    // Shield body.
    let shield = CGMutablePath()
    shield.move(to: CGPoint(x: 512, y: 142))
    shield.addCurve(to: CGPoint(x: 822, y: 254), control1: CGPoint(x: 648, y: 154), control2: CGPoint(x: 762, y: 172))
    shield.addLine(to: CGPoint(x: 782, y: 586))
    shield.addCurve(to: CGPoint(x: 512, y: 862), control1: CGPoint(x: 768, y: 770), control2: CGPoint(x: 652, y: 836))
    shield.addCurve(to: CGPoint(x: 242, y: 586), control1: CGPoint(x: 372, y: 836), control2: CGPoint(x: 256, y: 770))
    shield.addLine(to: CGPoint(x: 202, y: 254))
    shield.addCurve(to: CGPoint(x: 512, y: 142), control1: CGPoint(x: 262, y: 172), control2: CGPoint(x: 376, y: 154))
    shield.closeSubpath()

    context.saveGState()
    context.setShadow(offset: CGSize(width: 0, height: -16), blur: 24, color: color(0, 0, 0, 0.40))
    context.addPath(shield)
    context.setFillColor(color(0.08, 0.46, 0.90))
    context.fillPath()
    context.restoreGState()

    context.addPath(shield)
    context.setStrokeColor(color(0.56, 0.86, 1.0, 0.80))
    context.setLineWidth(12)
    context.strokePath()

    // Key silhouette: the PIV key is deliberately simple for small Dock sizes.
    context.saveGState()
    context.setShadow(offset: CGSize(width: 0, height: -8), blur: 12, color: color(0, 0, 0, 0.32))
    context.setFillColor(color(0.97, 0.99, 1.0))
    context.fillEllipse(in: CGRect(x: 356, y: 338, width: 312, height: 312))
    context.fill(CGRect(x: 474, y: 520, width: 106, height: 258))
    context.fill(CGRect(x: 550, y: 700, width: 150, height: 58))
    context.fill(CGRect(x: 550, y: 620, width: 105, height: 58))
    context.restoreGState()

    context.setFillColor(color(0.07, 0.25, 0.48))
    context.fillEllipse(in: CGRect(x: 449, y: 431, width: 126, height: 126))

    // Small green readiness indicator.
    context.saveGState()
    context.setShadow(offset: .zero, blur: 18, color: color(0.20, 0.95, 0.55, 0.70))
    context.setFillColor(color(0.25, 0.92, 0.52))
    context.fillEllipse(in: CGRect(x: 804, y: 112, width: 104, height: 104))
    context.restoreGState()

    // A fine inner border gives the icon a finished macOS-app edge.
    context.addPath(backgroundPath)
    context.setStrokeColor(color(0.65, 0.86, 1.0, 0.22))
    context.setLineWidth(4)
    context.strokePath()

    _ = canvas
    return context.makeImage()
}

let outputDirectory = URL(fileURLWithPath: CommandLine.arguments.dropFirst().first ?? "AppIcon.iconset", isDirectory: true)
let fileManager = FileManager.default
try? fileManager.removeItem(at: outputDirectory)
try fileManager.createDirectory(at: outputDirectory, withIntermediateDirectories: true)

for size in sizes {
    guard let image = drawIcon(size: size) else { continue }
    let baseURL = outputDirectory.appendingPathComponent("icon_\(size)x\(size).png")
    let doubleURL = outputDirectory.appendingPathComponent("icon_\(size)x\(size)@2x.png")
    let destination = CGImageDestinationCreateWithURL(baseURL as CFURL, "public.png" as CFString, 1, nil)!
    CGImageDestinationAddImage(destination, image, nil)
    CGImageDestinationFinalize(destination)

    if size <= 512 {
        let destination2 = CGImageDestinationCreateWithURL(doubleURL as CFURL, "public.png" as CFString, 1, nil)!
        guard let image2 = drawIcon(size: size * 2) else { continue }
        CGImageDestinationAddImage(destination2, image2, nil)
        CGImageDestinationFinalize(destination2)
    }
}
