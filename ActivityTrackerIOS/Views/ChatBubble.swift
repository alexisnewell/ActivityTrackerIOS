struct ChatBubble: View {

    let message: ChatMessage

    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
            }

            Text(message.text)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    message.isUser
                    ? Color.accentColor
                    : Color.secondary.opacity(0.15)
                )
                .foregroundStyle(
                    message.isUser
                    ? .white
                    : .primary
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))

            if !message.isUser {
                Spacer()
            }
        }
    }
}