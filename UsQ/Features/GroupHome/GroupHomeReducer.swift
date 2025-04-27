//
//  GroupHomeReducer.swift
//  UsQ
//
//  Created by 신병기 on 4/17/25.
//

import Foundation
import ComposableArchitecture

@Reducer
public struct GroupHomeReducer {
    public struct State: Equatable {
        public var group: Group
        public var members: [Membership] = []
        public init(group: Group) {
            self.group = group
        }
    }

    public enum Action: Equatable {
        case onAppear
        case membersResponse(Result<[Membership], GroupMembersError>)
    }
    
    public enum GroupMembersError: Error, Equatable {
        case firebase(String)
    }

    @Dependency(\.membershipFirestoreClient) var membershipClient

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { [groupId = state.group.id] send in
                    do {
                        let members = try await membershipClient.fetchMembers(groupId)
                        await send(.membersResponse(.success(members)))
                    } catch {
                        await send(.membersResponse(.failure(.firebase(error.localizedDescription))))
                    }
                }
            case let .membersResponse(.success(members)):
                state.members = members
                return .none

            case .membersResponse(.failure):
                // Optionally handle error (ignored for now)
                return .none
            }
        }
    }
}
