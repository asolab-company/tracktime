import SwiftUI

struct BtnStyle: ButtonStyle {
    var height: CGFloat = 50
    var width: CGFloat? = nil

    func makeBody(configuration: Configuration) -> some View {

        let baseGradient = LinearGradient(
            colors: [
                Color(hex: "#9DCA72"),
                Color(hex: "#699641"),
            ],
            startPoint: .top,
            endPoint: .bottom
        )

        return configuration.label
            .foregroundColor(.white)
            .frame(
                maxWidth: width ?? .infinity,
                maxHeight: height
            )
            .frame(width: width)
            .frame(height: height)
            .background(
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .fill(baseGradient)

                    .shadow(
                        color: Color(hex: "#4F7A33"),
                        radius: 0.5,
                        x: 0,
                        y: 6
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .stroke(Color.black.opacity(0), lineWidth: 0)
                    .shadow(
                        color: Color.black.opacity(0.25),
                        radius: 3,
                        x: 0,
                        y: 1
                    )
                    .clipShape(
                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                    )
                    .mask(
                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

#Preview {
    VStack(spacing: 20) {
        Button("Default Button") {}
            .buttonStyle(BtnStyle())

        Button("Fixed Width Button") {}
            .buttonStyle(BtnStyle(height: 50, width: 220))
    }
    .padding()
    .background(Color.gray.opacity(0.2))
}
