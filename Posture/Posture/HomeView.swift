//
//  HomeView.swift
//  Posture
//
//  Created by Natan Camargo Rodrigues on 12/1/2025.
//

import SwiftUI

struct HomeView: View {
    @StateObject var coreMotionManager = CoreMotionManager()
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        Button("Go to Settings") {
//            coreMotionManager.startUpdates()
        }
    }
}

#Preview {
    HomeView()
}
