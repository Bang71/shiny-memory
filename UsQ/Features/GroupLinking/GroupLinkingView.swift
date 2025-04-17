//
//  GroupLinkingView.swift
//  UsQ
//
//  Created by 신병기 on 4/17/25.
//

import SwiftUI
import ComposableArchitecture

public struct GroupLinkingView: View {
    let store: StoreOf<GroupLinkingReducer>

    public init(store: StoreOf<GroupLinkingReducer>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack(spacing: 16) {
                Text("초대 코드로 그룹에 참여하기")
                    .font(.title2)
                    .padding(.top)

                TextField("초대 코드를 입력하세요", text: viewStore.binding(
                    get: \.code,
                    send: { .codeChanged($0) }
                ))
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)

                Button("참여하기") {
                    viewStore.send(.confirmTapped)
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewStore.code.isEmpty || viewStore.isLoading)

                if viewStore.isLoading {
                    ProgressView()
                        .padding()
                }

                if viewStore.hasJoined {
                    Text("그룹에 성공적으로 참여했어요!")
                        .foregroundColor(.blue)
                        .fontWeight(.semibold)
                }

                if let errorMessage = viewStore.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }

                if let group = viewStore.foundGroup {
                    VStack(spacing: 12) {
                        Text("그룹 이름: \(group.name)")
                        Text("그룹 타입: \(group.type)")

                        Button("이 그룹에 참여하기") {
                            viewStore.send(.completeJoiningTapped(userId: "example-user-id"))
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(10)
                }

                Spacer()
            }
            .padding()
            .navigationDestination(isPresented: .constant(viewStore.hasJoined)) {
                Text("그룹 홈 화면으로 이동") // TODO: Replace with actual destination view
            }
        }
    }
}
