//
//  GetFollowers.swift
//
//
//  Created by Christopher Jr Riley on 2024-03-08.
//

import Foundation

extension ATProtoKit {

    /// Gets all of the user account's followers.
    /// 
    /// - Note: According to the AT Protocol specifications: "Enumerates accounts which follow
    /// a specified account (actor)."
    ///
    /// - SeeAlso: This is based on the [`app.bsky.graph.getFollowers`][github] lexicon.
    ///
    /// [github]: https://github.com/bluesky-social/atproto/blob/main/lexicons/app/bsky/graph/getFollowers.json
    ///
    /// - Parameters:
    ///   - actorDID: The decentralized identifier (DID) or handle of the user account to search
    ///   their followers.
    ///   - limit: The number of items the list will hold. Optional. Defaults to `50`.
    ///   - cursor: The mark used to indicate the starting point for the next set
    ///   of results. Optional.
    ///   - pdsURL: The URL of the Personal Data Server (PDS). Defaults to `https://api.bsky.app`.
    /// - Returns: An array of user accounts that follow the user account, information about the
    /// user account itself, and an optional cursor to extend the array.
    ///
    /// - Throws: An ``ATProtoError``-conforming error type, depending on the issue. Go to
    /// ``ATAPIError`` and ``ATRequestPrepareError`` for more details.
    public func getFollowers(
        by actorDID: String,
        limit: Int? = 50,
        cursor: String? = nil,
        pdsURL: String = "https://api.bsky.app"
    ) async throws -> AppBskyLexicon.Graph.GetFollowersOutput {
        guard pdsURL != "" else {
            throw ATRequestPrepareError.emptyPDSURL
        }

        guard let requestURL = URL(string: "\(pdsURL)/xrpc/app.bsky.graph.getFollowers") else {
            throw ATRequestPrepareError.invalidRequestURL
        }

        var queryItems = [(String, String)]()

        queryItems.append(("actor", actorDID))

        if let limit {
            let finalLimit = max(1, min(limit, 100))
            queryItems.append(("limit", "\(finalLimit)"))
        }

        if let cursor {
            queryItems.append(("cursor", cursor))
        }

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
                contentTypeValue: nil
            )
            let response = try await APIClientService.shared.sendRequest(
                request,
                decodeTo: AppBskyLexicon.Graph.GetFollowersOutput.self
            )

            return response
        } catch {
            throw error
        }
    }
}
