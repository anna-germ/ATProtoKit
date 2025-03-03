//
//  ChatGetConvoForMembers.swift
//
//
//  Created by Christopher Jr Riley on 2024-05-31.
//

import Foundation

extension ATProtoBlueskyChat {

    /// Retrieves a conversation based on the list of members.
    /// 
    /// - Note: `members` will only take the first 10 items. Any additional items will be discared.
    ///
    /// - SeeAlso: This is based on the [`chat.bsky.convo.getConvoForMembers`][github] lexicon.
    /// 
    /// [github]: https://github.com/bluesky-social/atproto/blob/main/lexicons/chat/bsky/convo/getConvoForMembers.json
    /// 
    /// - Parameter members: An array of members within the conversation. Maximum amount is
    /// 10 items.
    /// - Returns: A view of the conversation metadata, including an array of members in the
    /// conversation, mute indication, the last message, and the number of unread messages.
    ///
    /// - Throws: An ``ATProtoError``-conforming error type, depending on the issue. Go to
    /// ``ATAPIError`` and ``ATRequestPrepareError`` for more details.
    public func getConversaionForMembers(_ members: [String]) async throws -> ChatBskyLexicon.Conversation.GetConversationForMembersOutput {
        guard session != nil,
              let accessToken = session?.accessToken else {
            throw ATRequestPrepareError.missingActiveSession
        }

        guard let sessionURL = session?.serviceEndpoint,
              let requestURL = URL(string: "\(sessionURL)/xrpc/chat.bsky.convo.getConvoForMembers") else {
            throw ATRequestPrepareError.invalidRequestURL
        }

        var queryItems = [(String, String)]()

        let cappedMembersArray = members.prefix(10)
        queryItems += cappedMembersArray.map { ("members", $0) }

        let queryURL: URL

        do {
            queryURL = try APIClientService.setQueryItems(
                for: requestURL,
                with: queryItems
            )

            let request = APIClientService.createRequest(
                forRequest: queryURL,
                andMethod: .get,
                acceptValue: "application/json",
                contentTypeValue: nil,
                authorizationValue: "Bearer \(accessToken)",
                isRelatedToBskyChat: true
            )
            let response = try await APIClientService.shared.sendRequest(
                request,
                decodeTo: ChatBskyLexicon.Conversation.GetConversationForMembersOutput.self
            )

            return response
        } catch {
            throw error
        }
    }
}
