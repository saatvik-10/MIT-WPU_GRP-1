//
//  OnboardingPage.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 11/12/25.
//
import Foundation

struct OnboardingPage {
    let title: String
    let options: [(title: String, subtitle: String)]
}



struct OnboardingInterestModel {
    let icon : String?
    let title : String
    let subtitle : String
}
var preferences : [OnboardingInterestModel] = [
    OnboardingInterestModel(icon: "indianrupeesign.gauge.chart.lefthalf.righthalf", title: "Indian Economy", subtitle: "Consumption,inflation , growth"),
    OnboardingInterestModel(icon: "figure.wave", title:"Personal Finance", subtitle: "Exports, Imports and Trade Balance"),
    OnboardingInterestModel(icon: "newspaper", title:"Government and Policy", subtitle: "Public Spending and Reforms"),
    OnboardingInterestModel(icon: "chart.line.uptrend.xyaxis", title:"Stock Markets", subtitle: "Shares ,Indices and Market Cycles"),
    OnboardingInterestModel(icon: "building.2", title:"Real Estate Economics", subtitle: "Housing Interest rates, demand"),
    OnboardingInterestModel(icon: "globe.central.south.asia.fill", title:"Global Economy", subtitle: "Exports, Imports and Trade Balance"),
    OnboardingInterestModel(icon: "banknote", title:"Banking and credit", subtitle: "Loans , Interest rates and Moneyflow"),
    OnboardingInterestModel(icon: "bitcoinsign.circle", title:"Crypto", subtitle: "Bitcoin, Web3 and Digital Assets"),
    
]

struct DomainModel {
    let icon : String?
    let title : String
}
var domains: [DomainModel] = [
    DomainModel(icon: "chart.bar", title: "Stocks"),
    DomainModel(icon: "building.columns", title: "Mutual Funds"),
    DomainModel(icon: "bitcoinsign.circle", title: "Crypto"),
    DomainModel(icon: "globe", title: "Macroeconomy"),
    DomainModel(icon: "creditcard", title: "Banking"),
    DomainModel(icon: "cube.box", title: "Commodities")
]

