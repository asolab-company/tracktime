import SwiftUI
import UIKit
import UserNotifications

private let ideasStoreKey = "Events"

struct IdeaRecord: Identifiable, Codable {
    let id: UUID
    let title: String
    let details: String
    let createdAt: Date
    var startTime: String? = nil
    var endTime: String? = nil
    var useCurrentDateTime: Bool = false
    var isImportantEvent: Bool = false
}

private func loadIdeas() -> [IdeaRecord] {
    guard let data = UserDefaults.standard.data(forKey: ideasStoreKey) else {
        return []
    }
    return (try? JSONDecoder().decode([IdeaRecord].self, from: data)) ?? []
}

@discardableResult
private func persistIdea(
    title: String,
    details: String,
    startTime: String?,
    endTime: String?,
    useCurrentDateTime: Bool,
    isImportantEvent: Bool
) -> IdeaRecord {
    var all = loadIdeas()
    let record = IdeaRecord(
        id: UUID(),
        title: title,
        details: details,
        createdAt: Date(),
        startTime: startTime,
        endTime: endTime,
        useCurrentDateTime: useCurrentDateTime,
        isImportantEvent: isImportantEvent
    )
    all.append(record)
    if let data = try? JSONEncoder().encode(all) {
        UserDefaults.standard.set(data, forKey: ideasStoreKey)
    }
    return record
}

struct AddEvent: View {
    var editRecord: IdeaRecord? = nil
    var onCancel: () -> Void
    var onSaved: (_ saved: IdeaRecord) -> Void = { _ in }

    @State private var isUsingCurrentDateTime = false
    @State private var isImportantEvent = false

    @State private var eventTitle: String = ""
    @State private var eventDate: String = ""
    @State private var eventTime: String = ""
    @State private var eventNotes: String = ""
    @FocusState private var focusTitle: Bool

    var body: some View {
        ZStack {

            VStack(spacing: 0) {

                HStack {
                    Button(action: {
                        resetFields()
                        onCancel()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                    }

                    Spacer()

                    Button(action: {
                        resetFields()

                    }) {
                        Text("Cancel")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color(hex: "E30000"))
                    }
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
                .overlay(alignment: .center) {
                    Text("Add Event")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .allowsHitTesting(false)
                }

                ScrollView {
                    VStack(spacing: 16) {

                        Group {
                            Text("Name of event*")
                                .foregroundColor(.white)
                                .font(.system(size: 16, weight: .regular))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading)
                                .padding(.top, 20)

                            RoundedField(
                                placeholder: "Enter the name of event",
                                text: $eventTitle,
                                focus: $focusTitle
                            )
                        }
                        .padding(.horizontal)

                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Date*")
                                    .foregroundColor(.white)
                                    .font(.system(size: 16, weight: .regular))
                                    .padding(.leading)

                                DateField(
                                    text: $eventDate,
                                    isValid: isStartTimeValid
                                )
                            }

                            VStack(alignment: .leading, spacing: 6) {
                                Text("Time*")
                                    .foregroundColor(.white)
                                    .font(.system(size: 16, weight: .regular))
                                    .padding(.leading)

                                TimeField(
                                    text: $eventTime,
                                    isValid: isEndTimeValid
                                )
                            }
                        }
                        .padding(.horizontal)

                        OptionToggleRow(
                            title: "Current date and time",
                            isOn: $isUsingCurrentDateTime
                        )
                        .padding(.horizontal)
                        OptionToggleRow(
                            title: "Important event",
                            isOn: $isImportantEvent
                        )
                        .padding(.horizontal)

                        Button(action: saveIdea) {
                            ZStack {
                                Text("Save")
                                    .font(.system(size: 20, weight: .semibold))
                                HStack {
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 18, weight: .bold))
                                }
                                .padding(.horizontal, 20)
                            }
                            .padding(.vertical, 14)
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(BtnStyle(height: 50))
                        .disabled(isSaveDisabled)
                        .opacity(isSaveDisabled ? 0.5 : 1.0)
                        .padding(.horizontal)

                        Spacer(minLength: 24)
                    }
                }

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

            }.onTapGesture {
                hideKeyboard()
            }
        )
        .onAppear {
            DispatchQueue.main.async { focusTitle = true }
        }
        .onChange(of: isUsingCurrentDateTime) { newValue in
            if newValue {
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

                eventDate = String(format: "%02d.%02d.%04d", day, month, year)
                eventTime = String(format: "%02d:%02d", hour, minute)
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }

    private var isSaveDisabled: Bool {
        eventTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || eventDate.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || eventTime.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || !isStartTimeValid || !isEndTimeValid
    }

    private var isStartTimeValid: Bool {
        isDateValid(eventDate)
    }

    private var isEndTimeValid: Bool {
        isTimeValid(eventTime)
    }

    private func isDateValid(_ input: String) -> Bool {
        let digits = input.filter { $0.isNumber }
        if digits.isEmpty { return true }

        guard digits.count == 8 else { return false }

        let dayStr = String(digits.prefix(2))
        let monthStr = String(digits.dropFirst(2).prefix(2))
        let yearStr = String(digits.dropFirst(4))

        guard let d = Int(dayStr), let m = Int(monthStr), let y = Int(yearStr)
        else {
            return false
        }

        guard (1...31).contains(d), (1...12).contains(m) else {
            return false
        }

        guard (1900...2100).contains(y) else {
            return false
        }

        return true
    }

    private func isTimeValid(_ input: String) -> Bool {
        let digits = input.filter { $0.isNumber }
        if digits.isEmpty { return true }

        guard digits.count == 4 else { return false }

        let hoursStr = String(digits.prefix(2))
        let minutesStr = String(digits.suffix(2))

        guard let h = Int(hoursStr), let m = Int(minutesStr) else {
            return false
        }
        return (0...23).contains(h) && (0...59).contains(m)
    }

    private func normalizeDate(_ input: String) -> String? {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return nil }

        let digits = trimmed.filter { $0.isNumber }
        guard digits.count == 8 else {
            return trimmed
        }

        let dayStr = String(digits.prefix(2))
        let monthStr = String(digits.dropFirst(2).prefix(2))
        let yearStr = String(digits.dropFirst(4))

        return "\(dayStr).\(monthStr).\(yearStr)"
    }

    private func normalizeTime(_ input: String) -> String? {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return nil }

        let parts = trimmed.split(separator: ":")
        if parts.count == 2,
            let h = Int(parts[0]),
            let m = Int(parts[1]),
            (0...23).contains(h),
            (0...59).contains(m)
        {
            return String(format: "%02d:%02d", h, m)
        }

        return trimmed
    }

    private func resetFields() {
        eventTitle = ""
        eventDate = ""
        eventTime = ""
        eventNotes = ""
        isUsingCurrentDateTime = false
        isImportantEvent = false
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }

    private func saveIdea() {
        let trimmedTitle = eventTitle.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        let trimmedDetails = eventNotes.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        guard !trimmedTitle.isEmpty else { return }

        let normalizedStart = normalizeDate(eventDate)
        let normalizedEnd = normalizeTime(eventTime)

        if let normalizedStart { eventDate = normalizedStart }
        if let normalizedEnd { eventTime = normalizedEnd }

        let saved = persistIdea(
            title: trimmedTitle,
            details: trimmedDetails,
            startTime: normalizedStart,
            endTime: normalizedEnd,
            useCurrentDateTime: isUsingCurrentDateTime,
            isImportantEvent: isImportantEvent
        )

        if isImportantEvent {
            scheduleDailyNotification(for: saved)
        }

        NotificationCenter.default.post(
            name: Notification.Name("Ideax.refreshIdeas"),
            object: nil
        )
        onSaved(saved)
        resetFields()
        onCancel()
    }

    private let motivationalMessages = [
        "You’re doing great — keep it going!",
        "Another day stronger 💥",
        "Look at that streak! You’ve come so far.",
        "Progress, not perfection. Keep moving forward.",
        "Every day counts — and today is another win.",
    ]

    private func parseTime(from string: String) -> (Int, Int)? {
        let parts = string.split(separator: ":")
        guard parts.count == 2,
            let h = Int(parts[0]),
            let m = Int(parts[1]),
            (0...23).contains(h),
            (0...59).contains(m)
        else {
            return nil
        }
        return (h, m)
    }

    private func scheduleDailyNotification(for record: IdeaRecord) {
        let defaults = UserDefaults.standard
        if defaults.object(forKey: "notificationsEnabled") != nil,
            defaults.bool(forKey: "notificationsEnabled") == false
        {
            return
        }

        let center = UNUserNotificationCenter.current()

        center.requestAuthorization(options: [.alert, .sound, .badge]) {
            granted,
            _ in
            guard granted else { return }

            let content = UNMutableNotificationContent()
            content.title = record.title
            content.body =
                motivationalMessages.randomElement()
                ?? "You’re doing great — keep it going!"
            content.sound = .default

            let trigger: UNNotificationTrigger

            if let timeString = record.endTime,
                let (hour, minute) = parseTime(from: timeString)
            {
                var dateComponents = DateComponents()
                dateComponents.hour = hour
                dateComponents.minute = minute
                trigger = UNCalendarNotificationTrigger(
                    dateMatching: dateComponents,
                    repeats: true
                )
            } else {
                trigger = UNTimeIntervalNotificationTrigger(
                    timeInterval: 24 * 60 * 60,
                    repeats: true
                )
            }

            let request = UNNotificationRequest(
                identifier: "important-\(record.id.uuidString)",
                content: content,
                trigger: trigger
            )

            center.add(request, withCompletionHandler: nil)
        }
    }
}

private struct RoundedField: View {
    let placeholder: String
    @Binding var text: String

    var minHeight: CGFloat = 44
    var multilineHeight: CGFloat = 138
    var focus: FocusState<Bool>.Binding? = nil

    var body: some View {
        Group {

            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text(placeholder)
                        .foregroundColor(Color(hex: "4D72B3"))
                        .font(.system(size: 16, weight: .regular))
                        .padding(.horizontal, 10)
                }

                Group {
                    if let focus {
                        TextField("", text: $text)
                            .focused(focus)
                    } else {
                        TextField("", text: $text)
                    }
                }
                .foregroundColor(.white)
                .font(.system(size: 16, weight: .regular))
                .padding(.horizontal, 10)
                .frame(height: minHeight)
            }

        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(hex: "4D72B3").opacity(0.5))
        )
    }
}

private struct OptionToggleRow: View {
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(isOn ? .white : Color(hex: "4D72B3"))

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle(tint: Color(hex: "4D72B3")))
        }
        .frame(height: 30)
    }
}

private struct TimeField: View {
    @Binding var text: String
    var isValid: Bool

    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                Text("HH:MM")
                    .foregroundColor(Color(hex: "4D72B3"))
                    .font(.system(size: 16, weight: .regular))
                    .padding(.horizontal, 10)
            }

            TextField(
                "",
                text: Binding(
                    get: { text },
                    set: { newValue in

                        let digitsOnly = newValue.filter { $0.isNumber }
                        var trimmed = String(digitsOnly.prefix(4))

                        var formatted = ""
                        let count = trimmed.count

                        if count == 0 {
                            formatted = ""
                        } else if count <= 2 {

                            formatted = trimmed
                        } else {

                            let hEnd = trimmed.index(
                                trimmed.startIndex,
                                offsetBy: 2
                            )
                            let hours = trimmed[trimmed.startIndex..<hEnd]
                            let minutes = trimmed[hEnd..<trimmed.endIndex]
                            formatted = "\(hours):\(minutes)"
                        }

                        if formatted != text {
                            text = formatted
                        }
                    }
                )
            )
            .keyboardType(.numberPad)
            .foregroundColor(.white)
            .font(.system(size: 16, weight: .regular))
            .padding(.horizontal, 10)
            .frame(height: 44)
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(hex: "4D72B3").opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(
                            isValid ? Color.clear : Color.red,
                            lineWidth: isValid ? 0 : 2
                        )
                )
        )
    }
}

#Preview {
    AddEvent(onCancel: {}, onSaved: { _ in })
}

private struct DateField: View {
    @Binding var text: String
    var isValid: Bool

    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                Text("DD.MM.YYYY")
                    .foregroundColor(Color(hex: "4D72B3"))
                    .font(.system(size: 16, weight: .regular))
                    .padding(.horizontal, 10)
            }

            TextField(
                "",
                text: Binding(
                    get: { text },
                    set: { newValue in
                        let digitsOnly = newValue.filter { $0.isNumber }
                        var trimmed = String(digitsOnly.prefix(8))

                        var formatted = ""
                        let count = trimmed.count

                        if count == 0 {
                            formatted = ""
                        } else if count <= 2 {

                            formatted = trimmed
                        } else if count <= 4 {

                            let dEnd = trimmed.index(
                                trimmed.startIndex,
                                offsetBy: 2
                            )
                            let day = trimmed[..<dEnd]
                            let month = trimmed[dEnd..<trimmed.endIndex]
                            formatted = "\(day).\(month)"
                        } else {

                            let dEnd = trimmed.index(
                                trimmed.startIndex,
                                offsetBy: 2
                            )
                            let mEnd = trimmed.index(dEnd, offsetBy: 2)
                            let day = trimmed[..<dEnd]
                            let month = trimmed[dEnd..<mEnd]
                            let year = trimmed[mEnd..<trimmed.endIndex]
                            formatted = "\(day).\(month).\(year)"
                        }

                        if formatted != text {
                            text = formatted
                        }
                    }
                )
            )
            .keyboardType(.numberPad)
            .foregroundColor(.white)
            .font(.system(size: 16, weight: .regular))
            .padding(.horizontal, 10)
            .frame(height: 44)
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(hex: "4D72B3").opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(
                            isValid ? Color.clear : Color.red,
                            lineWidth: isValid ? 0 : 2
                        )
                )
        )
    }
}
