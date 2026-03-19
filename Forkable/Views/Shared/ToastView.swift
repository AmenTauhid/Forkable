import SwiftUI

@Observable
class ToastManager {
    var currentToast: Toast?

    struct Toast: Equatable {
        let message: String
        let type: ToastType

        enum ToastType {
            case success, error
        }
    }

    func show(_ message: String, type: Toast.ToastType = .success) {
        withAnimation(.spring(duration: 0.3)) {
            currentToast = Toast(message: message, type: type)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
            guard let self, self.currentToast?.message == message else { return }
            withAnimation(.easeOut(duration: 0.3)) {
                self.currentToast = nil
            }
        }
    }
}

struct ToastOverlay: ViewModifier {
    let toast: ToastManager.Toast?

    func body(content: Content) -> some View {
        content.overlay(alignment: .top) {
            if let toast {
                HStack(spacing: 10) {
                    Image(systemName: toast.type == .success
                          ? "checkmark.circle.fill"
                          : "xmark.circle.fill")
                        .foregroundColor(toast.type == .success ? .fGreen : .fRed)

                    Text(toast.message)
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.fText)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .fill(Color.fSlateLight)
                        .shadow(color: .black.opacity(0.3), radius: 12, y: 4)
                )
                .overlay(
                    Capsule()
                        .stroke(
                            toast.type == .success
                                ? Color.fGreen.opacity(0.3)
                                : Color.fRed.opacity(0.3),
                            lineWidth: 1
                        )
                )
                .padding(.top, 8)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }
}

extension View {
    func toastOverlay(_ toast: ToastManager.Toast?) -> some View {
        modifier(ToastOverlay(toast: toast))
    }
}
