//
//  DiscoveryCarousel.swift
//  Thaqalayn
//
//  Horizontal auto-scrolling carousel featuring discovery features
//

import SwiftUI

struct DiscoveryCarousel: View {
    @State private var currentPage = 0
    @State private var autoScrollTimer: Timer?
    @State private var pauseAutoScroll = false
    @State private var showLifeMoments = false
    @State private var showQuestions = false
    @State private var showPropheticStories = false
    @State private var showAhlulbaytQuran = false

    var body: some View {
        VStack(spacing: 8) {
            // Carousel
            TabView(selection: $currentPage) {
                LifeMomentsCarouselCard(showFullView: $showLifeMoments)
                    .tag(0)

                QuestionsCarouselCard(showFullView: $showQuestions)
                    .tag(1)

                PropheticStoriesCarouselCard(showFullView: $showPropheticStories)
                    .tag(2)

                AhlulbaytQuranCarouselCard(showFullView: $showAhlulbaytQuran)
                    .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 145)
            .gesture(
                DragGesture()
                    .onChanged { _ in
                        pauseAutoScroll = true
                    }
            )

            // Page indicators
            HStack(spacing: 6) {
                ForEach(0..<4, id: \.self) { index in
                    Circle()
                        .fill(currentPage == index ?
                              Color.accentColor : Color.gray.opacity(0.3))
                        .frame(width: 6, height: 6)
                        .animation(.easeInOut, value: currentPage)
                }
            }
        }
        .onAppear {
            startAutoScroll()
        }
        .onDisappear {
            stopAutoScroll()
        }
        .onChange(of: pauseAutoScroll) { _, paused in
            if paused {
                stopAutoScroll()
                // Resume after 10 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                    pauseAutoScroll = false
                    startAutoScroll()
                }
            }
        }
        .fullScreenCover(isPresented: $showLifeMoments) {
            LifeMomentsView()
        }
        .fullScreenCover(isPresented: $showQuestions) {
            QuestionsView()
        }
        .fullScreenCover(isPresented: $showPropheticStories) {
            PropheticStoriesView()
        }
        .fullScreenCover(isPresented: $showAhlulbaytQuran) {
            AhlulbaytQuranView()
        }
    }

    private func startAutoScroll() {
        autoScrollTimer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                currentPage = (currentPage + 1) % 4
            }
        }
    }

    private func stopAutoScroll() {
        autoScrollTimer?.invalidate()
        autoScrollTimer = nil
    }
}

#Preview {
    DiscoveryCarousel()
        .padding()
}
