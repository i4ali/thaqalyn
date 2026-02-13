//
//  ProgressRingView.swift
//  Thaqalayn
//
//  Reusable circular progress ring component with Apple Watch styling
//

import SwiftUI

struct ProgressRingView: View {
    let progress: Double // 0.0 to 1.0
    let gradient: LinearGradient
    let lineWidth: CGFloat
    let size: CGFloat
    var shadowColor: Color = .clear

    @State private var animatedProgress: Double = 0

    var body: some View {
        ZStack {
            // Background track circle (dimmed version)
            Circle()
                .stroke(
                    gradient.opacity(0.2),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )

            // Progress arc
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    gradient,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90)) // Start from 12 o'clock
                .shadow(color: shadowColor.opacity(0.4), radius: 4)
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.spring(response: 1.2, dampingFraction: 0.8)) {
                animatedProgress = min(max(progress, 0), 1)
            }
        }
        .onChange(of: progress) { _, newValue in
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                animatedProgress = min(max(newValue, 0), 1)
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        ProgressRingView(
            progress: 0.75,
            gradient: LinearGradient(
                colors: [Color(hex: "FF2D55"), Color(hex: "FF6B6B")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            lineWidth: 20,
            size: 200,
            shadowColor: Color(hex: "FF2D55")
        )

        ProgressRingView(
            progress: 0.45,
            gradient: LinearGradient(
                colors: [Color(hex: "30D158"), Color(hex: "34C759")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            lineWidth: 16,
            size: 150,
            shadowColor: Color(hex: "30D158")
        )
    }
    .padding()
    .background(Color.black)
}
