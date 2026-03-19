import SwiftUI

// MARK: - Initials Avatar

func initialsAvatar(name: String, size: CGFloat, borderColor: Color = .fAmber) -> some View {
    let initials = name.split(separator: " ").prefix(2).map { String($0.prefix(1)).uppercased() }.joined()
    let display = initials.isEmpty ? "?" : initials

    return Circle()
        .fill(Color.fSlateLighter)
        .frame(width: size, height: size)
        .overlay(
            Text(display)
                .font(.system(size: size * 0.35, weight: .semibold))
                .foregroundColor(.fAmber)
        )
        .overlay(Circle().stroke(borderColor.opacity(0.2), lineWidth: 2))
}

// MARK: - Pressable Button Style

struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(duration: 0.2), value: configuration.isPressed)
    }
}

// MARK: - Section Header

func sectionHeader(_ title: String) -> some View {
    Text(title.uppercased())
        .font(.caption)
        .fontWeight(.medium)
        .foregroundColor(.fMuted)
        .tracking(1)
}
