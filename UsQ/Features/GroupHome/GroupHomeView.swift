//
//  GroupHomeView.swift
//  UsQ
//
//  Created by 신병기 on 4/17/25.
//

import SwiftUI
import ComposableArchitecture

public struct GroupHomeView: View {
    let store: StoreOf<GroupHomeReducer>

    public init(store: StoreOf<GroupHomeReducer>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack(spacing: 16) {
                Text("그룹 홈")
                    .font(.largeTitle)
                    .bold()

                Text("그룹 이름: \(viewStore.group.name)")
                Text("그룹 타입: \(viewStore.group.type)")
                Text("초대 코드: \(viewStore.group.invitationCode)")

                if !viewStore.members.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("참여 멤버:")
                            .font(.headline)

                        ForEach(viewStore.members, id: \.id) { member in
                            Text("• \(member.userId)")
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                Spacer()
            }
            .padding()
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
}
