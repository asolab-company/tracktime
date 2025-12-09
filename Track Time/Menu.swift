import SwiftUI
import UserNotifications

struct Menu: View {

    @State private var events: [IdeaRecord] = []
    @State private var isPresentingAddEvent = false
    @State private var isPresentingSettings = false

    var body: some View {
        ZStack(alignment: .top) {

            VStack(spacing: 0) {
                ZStack(alignment: .topTrailing) {

                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            OutlinedTitle(text: "Track Time Since\nAny Event")

                            Text(
                                "Easily see how much time has passed since important moments in your life — from big milestones to daily habits."
                            )
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .regular))
                            .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.trailing, 24)

                        Spacer()
                    }

                    Button(action: { isPresentingSettings = true }) {
                        Image("app_ic_settings")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom)
                .frame(height: 130, alignment: .bottom)
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

                HStack(alignment: .top, spacing: 12) {

                    Image("app_ic_event")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(
                            "Swipe left on the bar if you want to delete event."
                        )
                        Text(
                            "Swipe right if you want to restart the countdown."
                        )
                    }
                    .font(
                        .system(
                            size: Device.isSmall ? 10 : 12,
                            weight: .regular
                        )
                    )
                    .foregroundColor(.white)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.init(hex: "4D72B3").opacity(0.2))
                )
                .padding(.horizontal)
                .padding(.top)

                Text("Your Events")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 10)

                List {
                    if events.isEmpty {
                        VStack(spacing: 16) {
                            Image("app_ic_empty")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 130, height: 130)

                            Text("There are no events in your list yet.")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(Color.init(hex: "4D72B3"))
                        }
                        .frame(maxWidth: .infinity, minHeight: 260)
                      
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    } else {
                        ForEach(events) { record in
                            EventRow(
                                title: record.title,
                                subtitle: relativeTimeString(for: record)
                            )

                            .swipeActions(edge: .trailing) {
                                Button {
                                    deleteEvent(record)
                                } label: {
                                    Image(systemName: "trash")
                                        .symbolRenderingMode(.hierarchical)
                                        .foregroundColor(.white)
                                }
                                .tint(Color(hex: "AF2C27"))
                            }
                            .swipeActions(edge: .leading) {
                                Button {
                                    restartEvent(record)
                                } label: {
                                    Image(systemName: "gobackward")
                                        .symbolRenderingMode(.hierarchical)
                                        .foregroundColor(.white)
                                }
                                .tint(Color(hex: "4D72B3"))
                            }
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(
                                EdgeInsets(
                                    top: 4,
                                    leading: 18,
                                    bottom: 4,
                                    trailing: 18
                                )
                            )
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)

                VStack {

                    Button(action: { isPresentingAddEvent = true }) {
                        ZStack {
                            Text("Add Event")
                                .font(.system(size: 20, weight: .semibold))
                            HStack {
                                Spacer()
                                Image(systemName: "plus")
                                    .font(
                                        .system(size: 18, weight: .bold)
                                    )
                            }
                            .padding(.horizontal, 20)
                        }
                        .padding(.vertical, 14)
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(BtnStyle(height: 50))

                    .padding(.horizontal)
                    .padding(.vertical)

                    Spacer()
                }
                .frame(height: 100)
                .background(
                    LinearGradient(
                        colors: [
                            Color(hex: "AF2C27"),
                            Color(hex: "450E0B"),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )

                )

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
        .onAppear {
            loadEvents()
        }
        .fullScreenCover(isPresented: $isPresentingAddEvent) {
            AddEvent(
                onCancel: {
                    isPresentingAddEvent = false
                },
                onSaved: { _ in
                    loadEvents()
                    isPresentingAddEvent = false
                }
            )
        }
        .fullScreenCover(isPresented: $isPresentingSettings) {
            Setting(
                onBack: {
                    isPresentingSettings = false
                }
            )
        }

    }

}

extension Menu {
    fileprivate func loadEvents() {
        guard let data = UserDefaults.standard.data(forKey: "Events") else {
            events = []
            return
        }

        let decoded =
            (try? JSONDecoder().decode([IdeaRecord].self, from: data)) ?? []
        events = decoded.sorted { $0.createdAt > $1.createdAt }
    }

    fileprivate func saveEvents() {
        if let data = try? JSONEncoder().encode(events) {
            UserDefaults.standard.set(data, forKey: "Events")
        }
    }

    fileprivate func deleteEvent(_ record: IdeaRecord) {

        events.removeAll { $0.id == record.id }
        saveEvents()

        if record.isImportantEvent {
            let center = UNUserNotificationCenter.current()
            let identifier = "important-\(record.id.uuidString)"
            center.removePendingNotificationRequests(withIdentifiers: [
                identifier
            ])
        }
    }

    fileprivate func restartEvent(_ record: IdeaRecord) {
        guard let index = events.firstIndex(where: { $0.id == record.id })
        else { return }

        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents(
            [.day, .month, .year, .hour, .minute],
            from: now
        )

        let day = components.day ?? 1
        let month = components.month ?? 1
        let year = components.year ?? 2000
        let hour = components.hour ?? 0
        let minute = components.minute ?? 0

        let newDate = String(format: "%02d.%02d.%04d", day, month, year)
        let newTime = String(format: "%02d:%02d", hour, minute)

        var updated = events[index]
        updated.startTime = newDate
        updated.endTime = newTime
        events[index] = updated

        saveEvents()
    }

    fileprivate func parseEventDate(_ dateString: String?, timeString: String?)
        -> Date?
    {
        guard let dateString = dateString else { return nil }

        let digits = dateString.filter { $0.isNumber }
        guard digits.count == 8 else { return nil }

        let dayStr = String(digits.prefix(2))
        let monthStr = String(digits.dropFirst(2).prefix(2))
        let yearStr = String(digits.dropFirst(4))

        guard let day = Int(dayStr),
            let month = Int(monthStr),
            let year = Int(yearStr)
        else {
            return nil
        }

        var hour = 0
        var minute = 0
        if let timeString = timeString {
            let parts = timeString.split(separator: ":")
            if parts.count == 2 {
                hour = Int(parts[0]) ?? 0
                minute = Int(parts[1]) ?? 0
            }
        }

        var components = DateComponents()
        components.day = day
        components.month = month
        components.year = year
        components.hour = hour
        components.minute = minute

        return Calendar.current.date(from: components)
    }

    fileprivate func relativeTimeString(for record: IdeaRecord) -> String {
        let now = Date()
        let calendar = Calendar.current

        let baseDate =
            parseEventDate(record.startTime, timeString: record.endTime)
            ?? record.createdAt

        let components = calendar.dateComponents(
            [.month, .day, .hour, .minute],
            from: baseDate,
            to: now
        )

        let months = components.month ?? 0
        let days = components.day ?? 0
        let hours = components.hour ?? 0
        let minutes = components.minute ?? 0

        func part(_ value: Int, singular: String, plural: String) -> String? {
            guard value > 0 else { return nil }
            return value == 1 ? "\(value) \(singular)" : "\(value) \(plural)"
        }

        var parts: [String] = []

        if let m = part(months, singular: "month", plural: "months") {
            parts.append(m)
        }
        if parts.count < 2, let d = part(days, singular: "day", plural: "days")
        {
            parts.append(d)
        }
        if parts.count < 2,
            let h = part(hours, singular: "hour", plural: "hours")
        {
            parts.append(h)
        }
        if parts.count < 2,
            let min = part(minutes, singular: "minute", plural: "minutes")
        {
            parts.append(min)
        }

        if parts.isEmpty {
            return "Just now"
        } else {
            return parts.joined(separator: ", ") + " ago"
        }
    }
}

private struct EventRow: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            Text(subtitle)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Color.init(hex: "4D72B3"))
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(hex: "111935"))
        )
    }
}

#Preview {
    Menu()
}
