//
//  APIFunctions.swift
//  csci571hw9
//
//  Created by Jerry Lee on 4/30/22.
//

import Foundation

class PortfolioService: ObservableObject {
    @Published var portfolio: [PortfolioStruct] = []
    @Published var balance: Float = 0
    @Published var networth: Float = 0
    
    func load() {
        self.portfolio = try! JSONDecoder().decode([PortfolioStruct].self, from: UserDefaults.standard.object(forKey: "portfolio") as! Data)
        self.balance = UserDefaults.standard.float(forKey: "balance")
        self.networth = UserDefaults.standard.float(forKey: "networth")
    }
    
    
    func movePortfolio(from source: IndexSet, to destination: Int){
        self.portfolio.move(fromOffsets: source, toOffset: destination)
        let enc = try? JSONEncoder().encode(portfolio)
        UserDefaults.standard.set(enc, forKey: "portfolio")
    }
    
    func buyStock(ticker: String, shares: Int, price: Float){
        var inPortfolio = false
        var newPortfolio: [PortfolioStruct] = []
        for p in self.portfolio {
            if (p.ticker == ticker) {
                newPortfolio.append(PortfolioStruct(ticker: ticker, shares: p.shares + shares))
                inPortfolio = true
            } else {
                newPortfolio.append(p)
            }
        }
        if (inPortfolio == false){
            newPortfolio.append(PortfolioStruct(ticker: ticker, shares: shares))
        }
        self.balance = self.balance - (price * Float(shares))
        UserDefaults.standard.set(self.balance, forKey: "balance")
        self.portfolio = newPortfolio
        let enc = try? JSONEncoder().encode(newPortfolio)
        UserDefaults.standard.set(enc, forKey: "portfolio")
    }
    
    func sellStock(ticker: String, shares: Int, price: Float){
        var newPortfolio: [PortfolioStruct] = []
        for p in self.portfolio {
            if (p.ticker == ticker) {
                if (p.shares - shares > 0){
                    newPortfolio.append(PortfolioStruct(ticker: ticker, shares: p.shares - shares))
                }
            } else {
                newPortfolio.append(p)
            }
        }
        self.balance = self.balance + (price * Float(shares))
        UserDefaults.standard.set(self.balance, forKey: "balance")
        self.portfolio = newPortfolio
        let enc = try? JSONEncoder().encode(newPortfolio)
        UserDefaults.standard.set(enc, forKey: "portfolio")
    }
    
    func getNumShares(ticker: String) -> Int{
        for p in self.portfolio {
            if (p.ticker == ticker) {
                return p.shares
            }
        }
        return 0
    }

}
