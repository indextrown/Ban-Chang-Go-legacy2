//
//  BanchangoApp.swift
//  Banchango
//
//  Created by 김동현 on 9/8/24.
//

import SwiftUI

@main
struct BanchangoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    

    var body: some Scene {
        WindowGroup {
            AuthenticatedView(authViewModel: .init())
                
        }
    }
}
 

 
