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
    @StateObject var favoriteService = FavoriteService()
    @StateObject var portfolioService = PortfolioService()
    @State var autocomplete:[Autocomplete] = []
    @State var portfolio: [PortfolioStruct] = []
    @State var favorites: [String] = []
    @State var favoriteLoaded: Bool = false
    @State var networth: Float = 0.0
    
    init() {
        if (!UserDefaults.standard.bool(forKey: "favorites")){
            let fav: [String] = []
            UserDefaults.standard.set(fav, forKey: "favorites")
        }
        if (!UserDefaults.standard.bool(forKey: "portfolio")){
            let port: [PortfolioStruct] = []
            let enc = try? JSONEncoder().encode(port)
            UserDefaults.standard.set(enc, forKey: "portfolio")
        }
        if (!UserDefaults.standard.bool(forKey: "balance")){
            UserDefaults.standard.set(25000.00, forKey: "balance")
        }
    }
    
    var body: some View {
        NavigationView {
            if (favoriteLoaded == false) {
                VStack {
                    Spacer()
                    ProgressView()
                    Text("Fetching Data...")
                        .foregroundColor(.gray)
                    Spacer()
                }.onAppear{
                    portfolioService.load()
                    favoriteService.loadFavorites()
                    self.networth = portfolioService.networth
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        favoriteLoaded = true
                    }
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
                                
                                PortfolioData(balance: portfolioService.balance, worth: self.networth)
                                
                                ForEach(portfolioService.portfolio, id: \.self){
                                    stock in
                                    NavigationLink(destination: StockDetails(ticker: stock.ticker, favoriteService: favoriteService, portfolioService: portfolioService)) {
                                        StockCell(stock: stock, networth: $networth)
                                    }
                                }.onMove(perform: movePortStocks)
                            }
                        
                        Section(header: Text("FAVORITES")
                            .font(.caption)
                            .foregroundColor(Color.gray)) {
                                ForEach(favoriteService.favorites, id:\.self) {
                                    stock in
                                    NavigationLink(destination: StockDetails(ticker: stock, favoriteService: favoriteService, portfolioService: portfolioService)) {
                                        FavoriteCell(stock: stock, favoriteLoaded: $favoriteLoaded)
                                    }
                                }
                                .onMove(perform: moveStocks)
                                .onDelete(perform: deleteStocks)
                            }
                        Section(){
                            Footer()
                        }
                    } else {
                        ForEach(apiFunctions.autoComplete, id: \.symbol) { stock in
                            NavigationLink(destination: StockDetails(ticker: stock.symbol, favoriteService: favoriteService, portfolioService: portfolioService)) {
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
        .onAppear{
//            print('here')
//            self.portfolio = try! JSONDecoder().decode([PortfolioStruct].self, from: UserDefaults.standard.object(forKey: "portfolio") as! Data)
//            self.favorites = UserDefaults.standard.object(forKey: "favorites") as? [String] ?? [String]()
//            self.networth = portfolioService.balance
//            for p in portfolioService.portfolio {
//                self.networth = self.networth + (p.price * Float(p.shares))
//            }
        }
    }

    func movePortStocks(from source: IndexSet, to destination: Int) {
        withAnimation {
            portfolioService.movePortfolio(from: source, to: destination)
        }
    }
    
    func moveStocks(from source: IndexSet, to destination: Int) {
        withAnimation {
            favoriteService.moveFavorites(from: source, to: destination)
        }
    }
    
    func deleteStocks(offsets: IndexSet) {
        withAnimation {
            favoriteService.removeFavorites(offsets: offsets)
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

struct PortfolioData: View {
    var balance: Float
    var worth: Float
    var body: some View {
        HStack {
            Text("Net Worth\n$\(worth, specifier: "%.2f")")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color.black)
            Spacer()
            Text("Cash Balance \n$\(balance, specifier: "%.2f")")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color.black)
        }
    }
}


struct FavoriteCell: View {
    var stock: String
    @StateObject var apiFunctions = APIFunctions()
    @Binding var favoriteLoaded: Bool
    
    var body: some View {
        HStack {
            if (apiFunctions.companyDescription == nil || apiFunctions.latestPrice == nil){
                VStack{
                    Spacer()
                    ProgressView()
                    Spacer()
                }.onAppear{
                    apiFunctions.fetchLatestPrice(ticker: stock)
                    apiFunctions.fetchCompanyDescription(ticker: stock)
                }
            }
            else {
                VStack(alignment: .leading) {
                    Text(stock)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color.black)
                        .multilineTextAlignment(.leading)
                    Text(apiFunctions.companyDescription!.name)
                        .font(.title3)
                        .foregroundColor(Color.gray)
                        .multilineTextAlignment(.leading)
                }.onAppear{
                    self.favoriteLoaded = true
                }
                Spacer()
                
                
                VStack(alignment: .trailing) {
                    Text("$\(Float(apiFunctions.latestPrice!.price)!, specifier: "%.2f")")
                        .font(.headline)
                        .padding(.trailing)
                    
                    HStack {
                        if (Float(apiFunctions.latestPrice!.percentChange)! > 0) {
                            Image(systemName: "arrow.up.right")
                        } else {
                            Image(systemName: "arrow.down.right")
                        }
                        Text("$\(Float(apiFunctions.latestPrice!.change)!, specifier: "%.2f")(\(Float(apiFunctions.latestPrice!.percentChange)!, specifier: "%.2f")%)")
                            .font(.headline)
                            .padding(.trailing)
                    }.foregroundColor(changeTextColor(change: Float(apiFunctions.latestPrice!.change)!))
                }
            }
        }
    }
}

struct StockCell: View {
    var stock: PortfolioStruct
    @StateObject var apiFunctions = APIFunctions()
    @Binding var networth: Float
    
    var body: some View {
        if (apiFunctions.latestPrice == nil){
            VStack{
                Spacer()
                ProgressView()
                Spacer()
            }.onAppear{
                apiFunctions.fetchLatestPrice(ticker: stock.ticker)
            }
        }
        else {
            HStack {
                VStack(alignment: .leading) {
                    Text(stock.ticker)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color.black)
                        .multilineTextAlignment(.leading)
                    Text("\(String(stock.shares)) shares")
                        .font(.title3)
                        .foregroundColor(Color.gray)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
                
                
                VStack(alignment: .trailing) {
                    Text("$\(Float(apiFunctions.latestPrice!.price)! * Float(stock.shares) , specifier: "%.2f")")
                        .font(.headline)
                        .padding(.trailing)
                    
                    HStack {
                        if (Float(apiFunctions.latestPrice!.percentChange)! > 0) {
                            Image(systemName: "arrow.up.right")
                        } else {
                            Image(systemName: "arrow.down.right")
                        }
                        Text("$\(Float(apiFunctions.latestPrice!.change)!, specifier: "%.2f")(\(Float(apiFunctions.latestPrice!.percentChange)!, specifier: "%.2f")%)")
                            .font(.headline)
                            .padding(.trailing)
                    }.foregroundColor(changeTextColor(change: Float(apiFunctions.latestPrice!.change)!))
                }
            }
            .onAppear{
                networth = networth + Float(apiFunctions.latestPrice!.price)! * Float(stock.shares)
                
//                let portfolio = try! JSONDecoder().decode([PortfolioStruct].self, from: UserDefaults.standard.object(forKey: "portfolio") as! Data)
//                for var p in portfolio {
//                    if (p.ticker == stock.ticker) {
//                        p.price = Float(apiFunctions.latestPrice!.price)!
//                        let enc = try? JSONEncoder().encode(portfolio)
//                        UserDefaults.standard.set(enc, forKey: "portfolio")
//                        break
//                    }
//                }
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
