import SwiftUI

struct LegalDocumentView: View {
    @Binding var navigationPath: [NavigationDestination]
    let kind: LegalDocumentKind

    var body: some View {
        ZStack {
            FuturisticBackground()

            VStack(spacing: 0) {
                HStack {
                    IconButton(
                        iconName: "chevron.left",
                        action: { navigationPath.removeLast() }
                    )

                    Spacer()

                    Text(title)
                        .font(.app(size: 16, weight: .semibold))
                        .foregroundColor(DesignSystem.colors.textPrimary)
                        .tracking(0.5)

                    Spacer()

                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal, DesignSystem.spacing.xl)
                .padding(.vertical, DesignSystem.spacing.md)

                ScrollView(.vertical, showsIndicators: false) {
                    Text(bodyText)
                        .font(.app(size: 14, weight: .light))
                        .foregroundColor(DesignSystem.colors.textSecondary)
                        .lineSpacing(6)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(DesignSystem.spacing.lg)
                }
            }
        }
    }

    private var title: String {
        switch kind {
        case .privacyPolicy:
            return "プライバシーポリシー"
        case .termsOfUse:
            return "利用規約"
        }
    }

    private var bodyText: String {
        switch kind {
        case .privacyPolicy:
            return """
            MARUBATUは、プレイ体験の改善とアプリ内機能のために、端末内にゲーム成績、設定、購入状態を保存します。

            現在のアプリ内機能では、アカウント登録、氏名、メールアドレス、連絡先などの入力は求めません。広告表示や購入機能を利用する場合、各サービス提供元が処理する情報は、それぞれのプライバシー方針に従います。

            App Store申請時には、利用している広告SDK、購入機能、分析機能の実態に合わせて、App Store Connectのプライバシー情報と公開URLを最新化してください。
            """
        case .termsOfUse:
            return """
            MARUBATUは、個人で楽しむための戦略ボードゲームです。

            アプリの不正な改変、リバースエンジニアリング、ゲーム進行や購入状態の不正操作は禁止します。アプリ内購入を行う場合、購入処理と返金はApp Storeの規約に従います。

            本アプリは、予告なく機能、表示、価格、提供内容を変更する場合があります。
            """
        }
    }
}

#Preview {
    LegalDocumentView(navigationPath: .constant([]), kind: .privacyPolicy)
}
