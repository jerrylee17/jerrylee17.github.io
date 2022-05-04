//
//  APIFunctions.swift
//  csci571hw9
//
//  Created by Jerry Lee on 4/30/22.
//

import Foundation
import Alamofire
import simd

class APIFunctions: ObservableObject {
    var ticker: String = "";
    
    
    var isLoading: Bool = true;
    var autoCompleteURL: String = "https://directed-sonar-346104.wl.r.appspot.com/autocomplete";
    var latestPriceURL: String = "https://directed-sonar-346104.wl.r.appspot.com/getLatestPrice";
    var companyDescriptionURL: String = "https://directed-sonar-346104.wl.r.appspot.com/getCompanyDescription";
    var companyNewsURL: String = "https://directed-sonar-346104.wl.r.appspot.com/getCompanyNews";
    var companySocialSentimentURL: String = "https://directed-sonar-346104.wl.r.appspot.com/getCompanySocialSentiment";
    var companyPeersURL: String = "https://directed-sonar-346104.wl.r.appspot.com/getCompanyPeers";
    
    @Published var autoComplete: [Autocomplete] = []
    @Published var latestPrice: LatestPrice?
    @Published var companyDescription: CompanyDescription?
    @Published var companyNews: [CompanyNews]?
    @Published var companySocialSentiment: filteredSocialSentiment?
    @Published var companyPeers: [String]?
    
    func fetchAutoComplete(ticker: String) {
        guard let url = URL(string: "\(autoCompleteURL)?query=\(ticker)")
        else {
            print("URL doesn't exist")
            return
        }
        AF.request(url).responseDecodable(of: [Autocomplete].self ) { (response) in
            guard let res = response.value else {return}
            let filteredRes = res.filter{ val in return !val.symbol.contains(".")}
            self.autoComplete = filteredRes
        }
    }
    
    func fetchLatestPrice(ticker: String) {
        guard let url = URL(string: "\(latestPriceURL)?ticker=\(ticker)")
        else {
            print("URL doesn't exist")
            return
        }
        AF.request(url).responseDecodable(of: LatestPrice.self ) { (response) in
            guard let res = response.value else {return}
            self.latestPrice = res
        }
    }
    
    func fetchCompanyDescription(ticker: String) {
        guard let url = URL(string: "\(companyDescriptionURL)?ticker=\(ticker)")
        else {
            print("URL doesn't exist")
            return
        }
        AF.request(url).responseDecodable(of: CompanyDescription.self ) { (response) in
            guard let res = response.value else {return}
            self.companyDescription = res
        }
    }
    
    func fetchCompanyNews(ticker: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let toDate = Date()
        let fromDate = toDate.addingTimeInterval(-86400*7)
        let toDateFormatted = formatter.string(from: toDate)
        let fromDateFormatted = formatter.string(from: fromDate)
        
        guard let url = URL(string: "\(companyNewsURL)?ticker=\(ticker)&fromDate=\(fromDateFormatted)&toDate=\(toDateFormatted)")
        else {
            print("URL doesn't exist")
            return
        }
        AF.request(url).responseDecodable(of: [CompanyNews].self ) { (response) in
            guard let res = response.value else {return}
            let filteredRes = res.filter{val in return !(val.image == "")}
            self.companyNews = filteredRes.sorted(by: {$0.datetime > $1.datetime})
            self.isLoading = false
        }
    }
    
    func fetchCompanySocialSentiment(ticker: String) {
        guard let url = URL(string: "\(companySocialSentimentURL)?ticker=\(ticker)")
        else {
            print("URL doesn't exist")
            return
        }
        AF.request(url).responseDecodable(of: CompanySocialSentiment.self ) { (response) in
            guard let res = response.value else {return}
            let filteredReddit = res.reddit.reduce(Reddit(mention: 0, positiveMention: 0, negativeMention: 0), { x, y in
                Reddit(mention: x.mention+y.mention, positiveMention: x.positiveMention+y.positiveMention, negativeMention: x.negativeMention+y.negativeMention)
            })
            let filteredTwitter = res.twitter.reduce(Twitter(mention: 0, positiveMention: 0, negativeMention: 0), { x, y in
                Twitter(mention: x.mention+y.mention, positiveMention: x.positiveMention+y.positiveMention, negativeMention: x.negativeMention+y.negativeMention)
            })
            self.companySocialSentiment = filteredSocialSentiment(symbol: res.symbol, reddit: filteredReddit, twitter: filteredTwitter)
        }
    }
    
    func fetchCompanyPeers(ticker: String) {
        guard let url = URL(string: "\(companyPeersURL)?ticker=\(ticker)")
        else {
            print("URL doesn't exist")
            return
        }
        AF.request(url).responseDecodable(of: [String].self ) { (response) in
            guard let res = response.value else {return}
            let filteredRes = res.filter{ val in return !val.contains(".")}
            self.companyPeers = filteredRes
        }
    }
}
