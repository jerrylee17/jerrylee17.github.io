//
//  structures.swift
//  csci571hw9
//
//  Created by Jerry Lee on 4/12/22.
//

import Foundation

// /getCompanyDescription
struct CompanyDescription: Hashable, Codable {
    var country: String
    var currency: String
    var exchange: String
    var finnhubIndustry: String
    var ipo: String
    var logo: String
    var name: String
    var ticker: String
    var weburl: String
}


// /getLatestPrice
struct LatestPrice: Hashable, Codable {
    var price: String;
    var change: String;
    var percentChange: String;
    var high: String;
    var low: String;
    var open: String;
    var previousClose: String;
    var timestamp: Double;
}


// /autocomplete
struct Autocomplete: Hashable, Codable {
    var description: String;
    var symbol: String;
    var displaySymbol: String;
}

// /getCompanyNews
struct CompanyNews: Hashable, Codable {
    var source: String;
    var datetime: Double;
    var headline: String;
    var image: String;
    var summary: String;
    var url: String;
}


// /getCompanySocialSentiment
struct Reddit: Hashable, Codable  {
    var mention: Int;
    var positiveMention: Int;
    var negativeMention: Int;
}

struct Twitter: Hashable, Codable  {
    var mention: Int;
    var positiveMention: Int;
    var negativeMention: Int;
}

struct CompanySocialSentiment: Hashable, Codable {
    var symbol: String;
    var reddit: [Reddit];
    var twitter: [Twitter];
}

struct filteredSocialSentiment: Hashable, Codable {
    var symbol: String;
    var reddit: Reddit;
    var twitter: Twitter;
}


// /getCompanyEarnings
struct CompanyEarnings: Hashable, Codable {
    var actual: Float;
    var estimate: Float;
    var period: String;
    var surprise: Float;
    var surprisePercent: Float;
    var symbol: String;
}

struct PortfolioStruct: Hashable, Codable {
    var ticker: String;
    var shares: Int;
}

struct FavoritesStruct: Hashable, Codable {
    var ticker: String;
    var description: String;
    var price: Float;
    var change: Float;
    var percentChange: Float;
}
