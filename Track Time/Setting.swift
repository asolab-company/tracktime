import SwiftUI
import UserNotifications

struct Setting: View {
    var onBack: () -> Void
    @Environment(\.openURL) private var openURL
    @State private var showShare = false
    @State private var notificationsEnabled = true

    var body: some View {
        ZStack(alignment: .top) {

            VStack(spacing: 0) {
                HStack {
                    Button(action: { onBack() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Text("Settings")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    Image(systemName: "chevron.left")
                        .opacity(0)
                }
                .padding(.horizontal, 30)
                .padding(.bottom)
                .frame(height: 50, alignment: .bottom)
                .background(
                    LinearGradient(
                        colors: [
                            Color(hex: "597EBB"),
                            Color(hex: "2B519C"),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()
                )

                SettingsRow(
                    icon: "app_ic_share",
                    title: "Share app",
                    action: { showShare = true }
                ).padding(.top, 20)

                SettingsRow(
                    icon: "app_ic_terms",
                    title: "Terms and Conditions",
                    action: { openURL(Data.terms) }
                )

                SettingsRow(
                    icon: "app_ic_privacy",
                    title: "Privacy",
                    action: { openURL(Data.policy) }
                )

                NotificationRow(
                    icon: "app_ic_not",
                    title: "Notifications",
                    isOn: $notificationsEnabled
                )

                Spacer()

            }

        }
        .background(
            ZStack {
                LinearGradient(
                    colors: [
                        Color(hex: "284182"),
                        Color(hex: "112242"),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            }
        )
        .sheet(isPresented: $showShare) {
            ShareSheet(items: Data.shareItems)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .onAppear {
            let defaults = UserDefaults.standard
            if defaults.object(forKey: "notificationsEnabled") != nil {
                notificationsEnabled = defaults.bool(
                    forKey: "notificationsEnabled"
                )
            } else {
                notificationsEnabled = true
            }
        }
        .onChange(of: notificationsEnabled) { newValue in
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: "notificationsEnabled")

            if newValue == false {
                let center = UNUserNotificationCenter.current()
                center.getPendingNotificationRequests { requests in
                    let ids =
                        requests
                        .map { $0.identifier }
                        .filter { $0.hasPrefix("important-") }
                    if !ids.isEmpty {
                        center.removePendingNotificationRequests(
                            withIdentifiers: ids
                        )
                    }
                }
            }
        }

    }

}

private struct SettingsRow: View {
    let icon: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)

                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: "4D72B3"))
            }
            .padding(.horizontal, 20)
            .frame(height: 60)
            .frame(maxWidth: .infinity)
            .background(Color(hex: "111935"))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.horizontal)
        .padding(.vertical, 6)
    }
}

private struct NotificationRow: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 16) {
            Image(icon)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)

            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle(tint: Color(hex: "4D72B3")))
        }
        .padding(.horizontal, 20)
        .frame(height: 60)
        .frame(maxWidth: .infinity)
        .background(Color(hex: "111935"))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .contentShape(Rectangle())
        .padding(.horizontal)
        .padding(.vertical, 6)
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
    }
    func updateUIViewController(
        _ vc: UIActivityViewController,
        context: Context
    ) {}
}

#Preview {
    Setting {}
}
