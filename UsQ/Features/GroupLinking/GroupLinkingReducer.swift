//
//  GroupLinkingReducer.swift
//  UsQ
//
//  Created by 신병기 on 4/17/25.
//

import Foundation
import ComposableArchitecture
import FirebaseFirestore

@Reducer
public struct GroupLinkingReducer {
    public struct State: Equatable {
        public var code: String = ""
        public var isLoading: Bool = false
        public var errorMessage: String?
        public var foundGroup: Group?
        public var hasJoined: Bool = false

        public init() {}
    }

    public enum Action: Equatable {
        case codeChanged(String)
        case confirmTapped
        case groupResponse(Result<Group, GroupLinkingError>)
        case completeJoiningTapped(userId: String)
        case joinedSuccessfully
    }
    
    public enum GroupLinkingError: Error, Equatable {
        case notFound
        case expired
        case firebase(String)
    }

    @Dependency(\.groupFirestoreClient) var groupFirestoreClient
    @Dependency(\.membershipFirestoreClient) var membershipFirestoreClient

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .codeChanged(code):
                state.code = code
                state.errorMessage = nil
                return .none

            case .confirmTapped:
                state.isLoading = true
                return .run { [code = state.code] send in
                    do {
                        guard let group = try await groupFirestoreClient.fetchGroupByCode(code) else {
                            await send(.groupResponse(.failure(.notFound)))
                            return
                        }

                        let refreshed = try await groupFirestoreClient.refreshCodeIfNeeded(group)
                        guard let expiresAt = refreshed.expiresAt, Date() <= expiresAt else {
                            await send(.groupResponse(.failure(.expired)))
                            return
                        }

                        await send(.groupResponse(.success(refreshed)))
                    } catch {
                        await send(.groupResponse(.failure(.firebase(error.localizedDescription))))
                    }
                }

            case let .groupResponse(.success(group)):
                state.isLoading = false
                state.foundGroup = group
                return .none

            case let .groupResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = {
                    switch error {
                    case .notFound: return "코드를 찾을 수 없어요."
                    case .expired: return "코드가 만료되었어요."
                    case let .firebase(msg): return "에러: \(msg)"
                    }
                }()
                return .none

            case let .completeJoiningTapped(userId):
                guard let group = state.foundGroup else {
                    state.errorMessage = "유효한 그룹 정보가 없어요."
                    return .none
                }
                return .run { send in
                    do {
                        let alreadyJoined = try await membershipFirestoreClient.isAlreadyJoined(userId, group.id)
                        if !alreadyJoined {
                            try await membershipFirestoreClient.joinGroup(userId, group.id)
                        }
                        await send(.joinedSuccessfully)
                    } catch {
                        print("Membership join failed: \(error)")
                        // 오류 처리 액션이 필요하다면 여기에 추가
                    }
                }

            case .joinedSuccessfully:
                state.hasJoined = true
                return .none
            }
        }
    }
}
