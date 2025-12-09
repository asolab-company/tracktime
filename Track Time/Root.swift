import SwiftUI

let onboardingShownKey = "EventBoarding"

enum AppRoute: Equatable {
    case loading
    case onboarding
    case menu
}

struct Root: View {
    @State private var route: AppRoute = .loading

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(hex: "AF2C27"),
                    Color(hex: "450E0B"),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            currentScreen
        }
    }

    @ViewBuilder
    private var currentScreen: some View {
        switch route {
        case .loading:
            Preloading {
                let needsOnboarding = !UserDefaults.standard.bool(
                    forKey: onboardingShownKey
                )
                route = needsOnboarding ? .onboarding : .menu
            }

        case .onboarding:
            Welcome {
                UserDefaults.standard.set(true, forKey: onboardingShownKey)
                route = .menu
            }

        case .menu:
            Menu()

        }
    }
}

#Preview {
    Root()
}
