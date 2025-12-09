import SwiftUI

struct Welcome: View {
    var onContinue: () -> Void = {}

    var body: some View {
        ZStack(alignment: .top) {

            GeometryReader { geo in
                VStack {
                    Spacer()

                    VStack(spacing: 5) {

                        HStack {

                            Spacer()

                            VStack(spacing: 20) {
                                FeatureCardView(
                                    icon: "🌱",
                                    title: "Build Better\nRoutines",
                                    description:
                                        "Replace old patterns with positive habits and celebrate every milestone."
                                )

                                FeatureCardView(
                                    icon: "💪",
                                    title: "Break Bad\nHabits",
                                    description:
                                        "Stay motivated to quit harmful habits by watching your streaks grow day by day."
                                )

                                FeatureCardView(
                                    icon: "⏰",
                                    title: "Track Any\nMoment",
                                    description:
                                        "Add events like your last workout, vacation, or coffee — and see how long it’s been since."
                                )
                            }
                            .frame(width: 180)

                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 24)

                        VStack {

                            Button(action: { onContinue() }) {
                                ZStack {
                                    Text("Get Started")
                                        .font(
                                            .system(size: 20, weight: .semibold)
                                        )
                                    HStack {
                                        Spacer()
                                        Image(systemName: "chevron.right")
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

                            TermsFooter()
                                .padding(.bottom)
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
                .frame(maxWidth: .infinity, maxHeight: .infinity)
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

                Image("app_bg_welcome")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

            }
        )
    }
}

private struct TermsFooter: View {
    var body: some View {
        HStack(spacing: 4) {

            Text("You Accept Our")
                .foregroundColor(Color(hex: "9C9C9C"))
                .font(.system(size: 14))

            Link("Terms Of Use", destination: Data.terms)
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "D21D0D"))

            Text("&")
                .foregroundColor(Color(hex: "9C9C9C"))
                .font(.system(size: 14))

            Link("Privacy Policy", destination: Data.policy)
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "D21D0D"))
        }
        .frame(maxWidth: .infinity)
        .lineLimit(1)
        .multilineTextAlignment(.center)
    }
}

struct FeatureCardView: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        ZStack {

            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(hex: "111935"))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(Color(hex: "4D72B3"), lineWidth: 3)
                )

            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top, spacing: 8) {
                    Text(icon)
                        .font(.system(size: 20))

                    OutlinedTitle(text: title)
                        .minimumScaleFactor(0.7)
                        .lineLimit(2)
                }

                Text(description)
                    .foregroundColor(.white)
                    .font(.system(size: 15, weight: .regular))
                    .minimumScaleFactor(0.8)

            }
            .padding(10)
        }
    }
}

struct OutlinedTitle: View {
    let text: String

    var body: some View {
        ZStack {

            Text(text)
                .font(.system(size: 20, weight: .heavy))
                .foregroundColor(Color(hex: "111935"))
                .offset(x: 1.2, y: 1.2)
                .blur(radius: 0.5)

            Text(text)
                .font(.system(size: 20, weight: .heavy))
                .foregroundColor(.clear)
                .overlay(
                    LinearGradient(
                        colors: [
                            Color(hex: "F93826"),
                            Color(hex: "D21D0D"),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .mask(
                        Text(text)
                            .font(.system(size: 20, weight: .heavy))
                    )
                )
        }
        .compositingGroup()
        .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 2)
    }
}

#Preview {
    Welcome {
        print("Finished")
    }
}
