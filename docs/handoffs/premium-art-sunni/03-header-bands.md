# 03 - Section header cover bands (Explore-style screens)

One ~1170x1452 (4:5, dark top third) cover per section screen: the hub/overview screen (band height **440**) and each detail screen behind it (band height **280**). On Thaqalayn that was the Explore tab + 7 detail screens; inventory AlBayan's own equivalents in Stage 1.

Flagship theme only - legacy themes keep their plain text headers.

## The treatment - build it ONCE as a shared component

The cover is a fixed-height, full-bleed band placed BEHIND the screen's existing header text stack, top-aligned:

- `.scaledToFill()`, top-aligned frame, `.clipped()`. No corner radius, no parallax, no stretch-on-scroll - it simply scrolls off with the content.
- The band bleeds behind the status bar: `.ignoresSafeArea(edges: .top)` on the band, while the header text keeps its normal safe-area padding. Hide the nav bar background on these screens (`.toolbarBackground(.hidden, for: .navigationBar)`) - gate that on the flagship theme so legacy themes keep their bar.
- Non-interactive and decorative: `.allowsHitTesting(false)`, `.accessibilityHidden(true)`.

### The fade is an ALPHA MASK, not a scrim

The one detail that is easy to get wrong: the art ITSELF fades to transparent at the bottom so it melts into the screen background. There is NO dark overlay on top.

```swift
struct CoverHeaderBand: View {
    let assetName: String
    let height: CGFloat   // 440 overview, 280 detail

    var body: some View {
        GeometryReader { geo in
            Image(assetName)
                .resizable()
                .scaledToFill()
                .frame(width: geo.size.width, height: height, alignment: .top)
                .clipped()
                .mask(
                    LinearGradient(stops: [
                        .init(color: .black.opacity(0.92), location: 0.00),
                        .init(color: .black,               location: 0.18),
                        .init(color: .black,               location: 0.62),
                        .init(color: .clear,               location: 1.00),
                    ], startPoint: .top, endPoint: .bottom)
                )
        }
        .frame(height: height)
        .ignoresSafeArea(edges: .top)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}
```

Usage: place as the background of the header area (`.background(alignment: .top) { CoverHeaderBand(...) }` on the header stack, or a ZStack as the first item of the scroll content), then lay the existing eyebrow/title/subtitle on top.

## Header text over the band (for parity)

- Eyebrow: system 11pt bold, tracking ~3, accent color.
- Title: serif semibold 34-40pt.
- Subtitle: system 13.5pt.
- Padding: horizontal 20, bottom 14.
- No extra text shadow needed - the covers are composed with dark sky exactly where the text sits. If a title is unreadable, the IMAGE failed QC (README section 7); fix the art, not the text.
- RTL: the text stack mirrors; the art does not.

One JPG per screen, used as-is in all appearance modes - no light/dark variants.

This same component + mask is what the journey header band (01-A3) uses. Build once, use everywhere.
