//
//  KyteService.swift
//  kyte-swift
//
//  Created by Eric Nam on 5/5/22.
//

import Foundation

class KyteManager : ObservableObject {
    static let shared: KyteManager = {
        let instance = KyteManager()
        // setup code
        return instance
    }()
    
    var kyte = Kyte()
    private var kyteSession: KyteSession?
    
    init() {}
    
    func setKyteSession(session: KyteSession){
        kyteSession = session
        print("Session Saved in KyteService")
    }
    
    func resetSession() {
        self.kyteSession = nil
        self.kyte.updateSession(sessionToken: "0", txToken: "0")
    }
    
    func getUserId() -> String {
        return self.kyteSession?.data.uid ?? "0"
    }
}
