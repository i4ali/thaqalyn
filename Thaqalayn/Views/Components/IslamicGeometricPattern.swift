//
//  IslamicGeometricPattern.swift
//  Thaqalayn
//
//  Islamic geometric pattern component for spiritual UI elements
//

import SwiftUI

/// Arabic ornament/mandala Islamic pattern
struct IslamicGeometricPattern: View {
    var size: CGFloat = 40
    var color: Color = .white
    var opacity: Double = 1.0

    var body: some View {
        ZStack {
            // Outer arabesque petals
            ForEach(0..<8) { index in
                ArabesquePetal(rotation: Double(index) * 45)
                    .fill(color.opacity(opacity * 0.85))
            }

            // Decorative dots between petals
            ForEach(0..<8) { index in
                Circle()
                    .fill(color.opacity(opacity * 0.7))
                    .frame(width: size * 0.08, height: size * 0.08)
                    .offset(y: -size * 0.32)
                    .rotationEffect(.degrees(Double(index) * 45 + 22.5))
            }

            // Middle decorative ring
            Circle()
                .stroke(color.opacity(opacity * 0.75), lineWidth: size * 0.03)
                .frame(width: size * 0.5, height: size * 0.5)

            // Inner ornate circle
            Circle()
                .fill(color.opacity(opacity * 0.8))
                .frame(width: size * 0.35, height: size * 0.35)

            // Small inner petals
            ForEach(0..<4) { index in
                SmallPetal(rotation: Double(index) * 90)
                    .fill(color.opacity(opacity * 0.9))
                    .frame(width: size * 0.25, height: size * 0.25)
            }

            // Center dot
            Circle()
                .fill(color.opacity(opacity))
                .frame(width: size * 0.1, height: size * 0.1)
        }
        .frame(width: size, height: size)
    }
}

/// Curved arabesque petal shape
struct ArabesquePetal: Shape {
    var rotation: Double = 0

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2

        // Create curved, organic petal shape
        let angle = Angle(degrees: rotation)
        let innerRadius = radius * 0.25
        let midRadius = radius * 0.6
        let outerRadius = radius * 0.88

        let baseLeft = polarToCartesian(center: center, radius: innerRadius, angle: angle.degrees - 12)
        let controlOut1 = polarToCartesian(center: center, radius: midRadius, angle: angle.degrees - 8)
        let tip = polarToCartesian(center: center, radius: outerRadius, angle: angle.degrees)
        let controlOut2 = polarToCartesian(center: center, radius: midRadius, angle: angle.degrees + 8)
        let baseRight = polarToCartesian(center: center, radius: innerRadius, angle: angle.degrees + 12)

        path.move(to: baseLeft)
        path.addQuadCurve(to: tip, control: controlOut1)
        path.addQuadCurve(to: baseRight, control: controlOut2)
        path.addLine(to: center)
        path.closeSubpath()

        return path
    }

    private func polarToCartesian(center: CGPoint, radius: CGFloat, angle: Double) -> CGPoint {
        let radian = angle * .pi / 180
        return CGPoint(
            x: center.x + radius * CGFloat(cos(radian)),
            y: center.y + radius * CGFloat(sin(radian))
        )
    }
}

/// Small inner petal for center decoration
struct SmallPetal: Shape {
    var rotation: Double = 0

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let size = min(rect.width, rect.height)

        let angle = Angle(degrees: rotation)
        let startPoint = polarToCartesian(center: center, radius: size * 0.15, angle: angle.degrees)
        let controlPoint = polarToCartesian(center: center, radius: size * 0.35, angle: angle.degrees)
        let endPoint = polarToCartesian(center: center, radius: size * 0.15, angle: angle.degrees + 90)

        path.move(to: center)
        path.addLine(to: startPoint)
        path.addQuadCurve(to: endPoint, control: controlPoint)
        path.closeSubpath()

        return path
    }

    private func polarToCartesian(center: CGPoint, radius: CGFloat, angle: Double) -> CGPoint {
        let radian = angle * .pi / 180
        return CGPoint(
            x: center.x + radius * CGFloat(cos(radian)),
            y: center.y + radius * CGFloat(sin(radian))
        )
    }
}

/// Regular polygon helper
struct RegularPolygon: Shape {
    var sides: Int

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2

        let angleStep = 360.0 / Double(sides)
        let startAngle = -90.0 // Start from top

        for i in 0..<sides {
            let angle = startAngle + angleStep * Double(i)
            let radian = angle * .pi / 180
            let point = CGPoint(
                x: center.x + radius * CGFloat(cos(radian)),
                y: center.y + radius * CGFloat(sin(radian))
            )

            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }

        path.closeSubpath()
        return path
    }
}

/// Subtle geometric pattern background overlay
struct GeometricPatternOverlay: View {
    var opacity: Double = 0.08
    var color: Color = .white

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Create a tiled pattern
                ForEach(0..<3) { row in
                    ForEach(0..<2) { col in
                        IslamicGeometricPattern(
                            size: 80,
                            color: color,
                            opacity: opacity
                        )
                        .offset(
                            x: CGFloat(col) * 120 - 40,
                            y: CGFloat(row) * 120 - 80
                        )
                        .rotationEffect(.degrees(Double(col + row) * 15))
                    }
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

// MARK: - Preview
struct IslamicGeometricPattern_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 30) {
            // Icon size
            IslamicGeometricPattern(size: 40, color: .purple)

            // Larger version
            IslamicGeometricPattern(size: 100, color: .teal)

            // Pattern overlay example
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.purple.gradient)
                    .frame(width: 300, height: 150)

                GeometricPatternOverlay(opacity: 0.1, color: .white)
                    .frame(width: 300, height: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 20))

                VStack {
                    Text("Life Moments")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text("Arabic Ornament Pattern")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
        .padding()
        .background(Color.black)
    }
}
