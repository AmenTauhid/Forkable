import SwiftUI

struct SettingsSheet: View {
    var body: some View {
        VStack(spacing: 0) {
            Text("Settings")
                .font(.headline)
                .foregroundColor(.fText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()

            ForEach([
                ("Default Unit System", "Metric (g)"),
                ("Auto-calculate Baker's %", "Enabled"),
                ("Theme", "Dark"),
                ("Notifications", "On"),
                ("Export Format", "JSON"),
            ], id: \.0) { setting in
                HStack {
                    Text(setting.0)
                        .font(.subheadline)
                        .foregroundColor(.fText)
                    Spacer()
                    Text(setting.1)
                        .font(.subheadline.monospaced())
                        .foregroundColor(.fMuted)
                }
                .padding(.horizontal)
                .padding(.vertical, 14)

                Divider().background(Color.white.opacity(0.05))
                    .padding(.horizontal)
            }

            Text("Forkable v2.0.1")
                .font(.caption.monospaced())
                .foregroundColor(.fMuted)
                .padding(.top, 16)

            Spacer()
        }
        .background(Color.fSlateLight.ignoresSafeArea())
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}
