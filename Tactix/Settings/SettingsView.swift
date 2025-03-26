//
//  SettingsView.swift
//  Tactix
//
//  Created by Hardik Kothari on 21.03.25.
//

import SwiftUI

struct SettingsView: View {
    @StateObject var player1: Player
    @StateObject var player2: Player
    
    var body: some View {
        List {
            Section(header: Text("PLAYER 1").font(.system(.headline, weight: .semibold))) {
                HStack {
                    Text("Name")
                    Spacer(minLength: 150)
                    TextField("Player name", text: $player1.name)
                        .multilineTextAlignment(.trailing)
                }
            }
            .headerProminence(.increased)
            
            Section(header: Text("Tic-Tac-Toe Settings")) {
                Picker("Marker", selection: $player1.marker) {
                    ForEach(Marker.allCases, id: \.self) { option in
                        Text(option.rawValue)
                    }
                }
                ColorPicker("Marker Color", selection: $player1.markerColor)
            }
            
            Section(header: Text("Connect Four Settings"), footer: Text("")) {
                ColorPicker("Disc Color", selection: $player1.discColor)
            }
            
            Section(header: Text("PLAYER 2").font(.system(.headline, weight: .semibold))) {
                HStack {
                    Text("Name")
                    Spacer(minLength: 150)
                    TextField("Player name", text: $player2.name)
                        .multilineTextAlignment(.trailing)
                }
                Toggle(isOn: $player2.isBot, label: {
                    Text("AI Control")
                })
            }
            .headerProminence(.increased)
            
            Section(header: Text("Tic-Tac-Toe Settings")) {
                Picker("Marker", selection: $player2.marker) {
                    ForEach(Marker.allCases, id: \.self) { option in
                        Text(option.rawValue)
                    }
                }
                ColorPicker("Marker Color", selection: $player2.markerColor)
            }
            
            Section(header: Text("Connect Four Settings")) {
                ColorPicker("Disc Color", selection: $player2.discColor)
            }
        }
        .onChange(of: player1.marker) { oldValue, _ in
            guard oldValue != player1.marker else { return }
            player2.marker = player1.marker == .x ? .o : .x
        }
        .onChange(of: player2.marker) { oldValue, _ in
            guard oldValue != player2.marker else { return }
            player1.marker = player2.marker == .x ? .o : .x
        }
        .listSectionSpacing(.compact)
        .navigationTitle("Settings")
    }
}

#Preview {
    let player1 = Player(id: .one, name: "MasterMind", marker: .x, markerColor: .blue, discColor: .red)
    let player2 = Player(id: .two, name: "TactixAce", marker: .o, markerColor: .red, discColor: .yellow, isBot: true)
    SettingsView(player1: player1, player2: player2)
}
