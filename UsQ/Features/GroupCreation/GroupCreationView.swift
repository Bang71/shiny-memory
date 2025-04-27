//
//  GroupCreationView.swift
//  UsQ
//
//  Created by 신병기 on 4/17/25.
//

import SwiftUI
import ComposableArchitecture

public struct GroupCreationView: View {
    let store: StoreOf<GroupCreationReducer>

    public init(store: StoreOf<GroupCreationReducer>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack {
            WithViewStore(self.store, observe: { $0 }) { viewStore in
                VStack(spacing: 20) {
                    Text("그룹 생성")
                        .font(.title)
                        .bold()

                    TextField("그룹 이름을 입력하세요", text: viewStore.binding(
                        get: \.name,
                        send: GroupCreationReducer.Action.nameChanged
                    ))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                    Picker("그룹 유형", selection: viewStore.binding(
                        get: \.type,
                        send: GroupCreationReducer.Action.typeChanged
                    )) {
                        Text("커플").tag("couple")
                        Text("친구").tag("friend")
                        Text("모임").tag("group")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)

                    Button(action: {
                        viewStore.send(.createTapped)
                    }) {
                        Text("그룹 만들기")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .disabled(viewStore.name.isEmpty || viewStore.isLoading)
                    .padding(.horizontal)

                    if viewStore.isLoading {
                        ProgressView().padding()
                    }

                    if let group = viewStore.createdGroup {
                        Text("초대 코드: \(group.invitationCode)")
                            .font(.headline)
                            .foregroundColor(.green)
                            .padding()
                    }

                    if let error = viewStore.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .padding()
                    }

                    Spacer()
                }
                .padding()
                .navigationDestination(isPresented: .constant(viewStore.didCreateGroup)) {
                    if let group = viewStore.createdGroup {
                        GroupHomeView(
                            store: Store(
                                initialState: GroupHomeReducer.State(group: group),
                                reducer: {
                                    GroupHomeReducer()
                                }
                            )
                        )
                    }
                }
            }
        }
    }
}
