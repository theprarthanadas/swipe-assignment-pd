//
//  SplashView.swift
//  Productive
//
//  Created by Prarthana Das on 20/08/23.
//
import SwiftUI


struct SplashView: View {
    
    @State var isActive:Bool = false
    
    var body: some View {
        VStack {
            if self.isActive {
               ContentView()
            } else {
                Image("splashscreen")
                    .resizable()
            }
        }

        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation {
                    self.isActive = true
                }
            }
        }
    }
    
}
