//
//  ContentView.swift
//  csci571hw9
//
//  Created by Jerry Lee on 4/5/22.
//

import SwiftUI
import CoreData


struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var searchBar: SearchBar = SearchBar()
    @StateObject var apiFunctions = APIFunctions()
    @State var autocomplete:[Autocomplete] = []
    
    
    let today = Date()
    let money = 25000
    let net_worth = 25000
    var portfolio: [PortfolioStruct]
    var favorites: [FavoritesStruct]
    
    init() {
        self.portfolio = [
//            PortfolioStruct(ticker: "AAPL", shares: 3),
//            PortfolioStruct(ticker: "TSLA", shares: 5),
        ]
        self.favorites = [
//            FavoritesStruct(ticker: "AAPL", description: "Apple Inc"),
//            FavoritesStruct(ticker: "TSLA", description: "Tesla Inc"),
        ]
    }
    
    var body: some View {
        
        
        NavigationView {
            if (false) {
                VStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            }
            else {
                List {
                    if (searchBar.text.isEmpty) {
                        Section(){
                            DateSection()
                        }
                        
                        Section(header: Text("PORTFOLIO")
                            .font(.caption)
                            .foregroundColor(Color.gray)) {
                                PortfolioData()
                                
                                ForEach(self.portfolio, id: \.ticker){
                                    stock in
                                    NavigationLink(destination: StockDetails(ticker: stock.ticker)) {
                                        StockCell(stock: stock, apiFunctions: apiFunctions)
                                    }
                                }
                            }
                        
                        Section(header: Text("FAVORITES")
                            .font(.caption)
                            .foregroundColor(Color.gray)) {
                                NavigationLink(destination: StockDetails(ticker: "AAPL")) {
                                    Text("Shit")
                                }
                                ForEach(self.favorites, id: \.ticker) {
                                    stock in
                                    NavigationLink(destination: StockDetails(ticker: stock.ticker)) {
                                        FavoriteCell(stock: stock, apiFunctions: apiFunctions)
                                    }
                                }
                            }
                        Section(){
                            Footer()
                        }
                    } else {
                        ForEach(apiFunctions.autoComplete, id: \.symbol) { stock in
                            NavigationLink(destination: StockDetails(ticker: stock.symbol, apiFunctions: apiFunctions)) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(stock.symbol)
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(Color.black)
                                            .multilineTextAlignment(.leading)
                                        Text(stock.description)
                                            .font(.title3)
                                            .foregroundColor(Color.gray)
                                            .multilineTextAlignment(.leading)
                                    }
                                    Spacer()
                                }
                            }
                        }.onReceive (searchBar.$text){ search in
                            let debounce = Debouncer(delay: 1)
                            debounce.run (action: {
                                apiFunctions.fetchAutoComplete(ticker: search)
                            })
                        }
                    }
                }
                .navigationBarTitle(Text("Stocks"))
                .toolbar {
                    EditButton()
                }
                .add(self.searchBar)
            }
        }
        .background(Color(white: 0.925))
        
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

struct PortfolioData: View {
    var body: some View {
        HStack {
            Text("Net Worth\n$25000.00")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color.black)
            Spacer()
            Text("Cash Balance \n$25000.00")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color.black)
        }
    }
}


struct FavoriteCell: View {
    var stock: FavoritesStruct
    var apiFunctions: APIFunctions
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(stock.ticker)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color.black)
                    .multilineTextAlignment(.leading)
                Text(stock.description)
                    .font(.title3)
                    .foregroundColor(Color.gray)
                    .multilineTextAlignment(.leading)
            }
            Spacer()
            
            
            VStack(alignment: .trailing) {
                Text("$\(stock.price, specifier: "%.2f")")
                    .font(.headline)
                    .padding(.trailing)
                
                HStack {
                    if (Float(stock.percentChange) > 0) {
                        Image(systemName: "arrow.up.right")
                    } else {
                        Image(systemName: "arrow.down.right")
                    }
                    Text("$\(stock.change, specifier: "%.2f")(\(stock.percentChange, specifier: "%.2f")%)")
                        .font(.headline)
                        .padding(.trailing)
                }.foregroundColor(changeTextColor(change: Float(stock.change)))
            }
        }
    }
}

struct StockCell: View {
    var stock: PortfolioStruct
    var apiFunctions: APIFunctions
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(stock.ticker)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color.black)
                    .multilineTextAlignment(.leading)
                Text(String(stock.shares))
                    .font(.title3)
                    .foregroundColor(Color.gray)
                    .multilineTextAlignment(.leading)
            }
            Spacer()
            
            
            VStack(alignment: .trailing) {
                Text("$\(Float(stock.price) * Float(stock.shares) , specifier: "%.2f")")
                    .font(.headline)
                    .padding(.trailing)
                
                HStack {
                    if (Float(stock.percentChange) > 0) {
                        Image(systemName: "arrow.up.right")
                    } else {
                        Image(systemName: "arrow.down.right")
                    }
                    Text("$\(stock.change, specifier: "%.2f")(\(stock.percentChange, specifier: "%.2f")%)")
                        .font(.headline)
                        .padding(.trailing)
                }.foregroundColor(changeTextColor(change: Float(stock.change)))
            }
        }
    }
}

func changeTextColor(change: Float) -> Color
{
    if (change > 0){
        return Color.green
    } else if (change < 0) {
        return Color.red
    } else {
        return Color.black
    }
}


struct DateSection: View {
    
    var body: some View {
        
        let date = Date()
        let calendar = Calendar.current
        let month_names = Calendar.current.monthSymbols
        
        let month = month_names[calendar.component(.month, from: date)-1]
        let day = calendar.component(.day, from: date)
        let year = calendar.component(.year, from: date)
        
        HStack {
            Text("\(month) \(String(day)), \(String(year))")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(Color.gray)
            Spacer()
        }
        .padding([.top, .bottom], 5.0)
        .background(/*@START_MENU_TOKEN@*//*@PLACEHOLDER=View@*/Color.white/*@END_MENU_TOKEN@*/)
        .cornerRadius(12)
    }
}

struct Footer: View {
    var body: some View {
        HStack {
            Spacer()
            Text("Powered by [Finnhub.io](https://finnhub.io/)")
                .font(.footnote)
                .foregroundColor(Color.gray)
                .accentColor(Color.gray)
                .padding(.horizontal)
            Spacer()
        }
        .padding([.top, .bottom])
        .background(/*@START_MENU_TOKEN@*//*@PLACEHOLDER=View@*/Color.white/*@END_MENU_TOKEN@*/)
        .cornerRadius(12)
        .padding([.leading, .trailing])
    }
}
