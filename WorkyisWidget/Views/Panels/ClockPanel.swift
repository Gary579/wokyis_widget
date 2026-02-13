import SwiftUI

struct ClockPanel: View {
    private let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }()

    private let secondsFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "ss"
        return f
    }()

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1.0)) { context in
            // 時:分 大字 + :秒 小字
            HStack(alignment: .firstTextBaseline, spacing: 0) {
                Text(timeFormatter.string(from: context.date))
                    .font(.custom("Futura-CondensedExtraBold", size: 360))
                    .foregroundColor(CRTTheme.phosphorGreen)
                    .phosphorGlow(CRTTheme.phosphorGreen, radius: 12)

                Text(":\(secondsFormatter.string(from: context.date))")
                    .font(.custom("Futura-CondensedExtraBold", size: 170))
                    .foregroundColor(CRTTheme.phosphorGreen.opacity(0.6))
                    .phosphorGlow(CRTTheme.phosphorGreen, radius: 5)
            }
        }
    }
}

#Preview {
    ClockPanel()
        .padding()
        .background(CRTTheme.screenBackground)
        .frame(width: 1280, height: 720)
}
