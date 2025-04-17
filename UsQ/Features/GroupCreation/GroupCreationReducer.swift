import Foundation
import ComposableArchitecture
import FirebaseFirestore

@Reducer
public struct GroupCreationReducer {
    public struct State: Equatable {
        public var name: String = ""
        public var type: String = "group" // default type
        public var isLoading: Bool = false
        public var createdGroup: Group?
        public var errorMessage: String?
        public var didCreateGroup: Bool = false
    }

    public enum Action: Equatable {
        case nameChanged(String)
        case typeChanged(String)
        case createTapped
        case createResponse(Result<Group, GroupCreationError>)
        case creationCompleted
    }

    public enum GroupCreationError: Error, Equatable {
        case firebase(String)
    }

    @Dependency(\.uuid) var uuid
    @Dependency(\.date) var date
    @Dependency(\.groupFirestoreClient) var groupFirestoreClient

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .nameChanged(name):
                state.name = name
                return .none

            case let .typeChanged(type):
                state.type = type
                return .none

            case .createTapped:
                state.isLoading = true
                let newGroup = Group(
                    id: uuid().uuidString,
                    name: state.name,
                    type: state.type,
                    createdAt: date(),
                    invitationCode: InvitationCodeGenerator.generateCode(),
                    expiresAt: InvitationCodeGenerator.defaultExpiration()
                )
                return .run { send in
                    do {
                        try await groupFirestoreClient.createGroup(newGroup)
                        await send(.createResponse(.success(newGroup)))
                    } catch {
                        await send(.createResponse(.failure(.firebase(error.localizedDescription))))
                    }
                }

            case let .createResponse(.success(group)):
                state.isLoading = false
                state.createdGroup = group
                return .send(.creationCompleted)

            case let .createResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = {
                    switch error {
                    case let .firebase(msg): return msg
                    }
                }()
                return .none

            case .creationCompleted:
                state.didCreateGroup = true
                return .none
            }
        }
    }
}
