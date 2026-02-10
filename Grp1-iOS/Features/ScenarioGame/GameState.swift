//
//  GameState.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 27/01/26.
//

enum DecisionNode {
    case act1

    // Loyalist branch
    case loyalist_followup
    case loyalist_doubleDown
    case loyalist_timeWillTell
    case loyalist_exit
    case loyalist_doubleDown_loss

    // Pragmatist branch
    case pragmatist_followup
    case pragmatist_exit
    case pragmatist_stay
    case pragmatic_loss
    
    
    case ev_pivot
    case ev_pivot_loss
    case ev_pivot_profit
    case ev_profit_book
}

enum CognitiveBias: String {
    case lossAversion = "Loss Aversion"
    case sunkCost = "Sunk Cost Fallacy"
    case overconfidence = "Overconfidence"
    case statusQuo = "Status Quo Bias"
    case anchoring = "Anchoring"
    case adaptability = "Adaptability"
}




enum EndingType {
    case success
    case partialFailure
    case failure
    case criticalFailure
}


