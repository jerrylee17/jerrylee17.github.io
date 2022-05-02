//
//  StockDetails.swift
//  csci571hw9
//
//  Created by Jerry Lee on 4/19/22.
//

import SwiftUI
import Kingfisher

struct StockDetails: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    var ticker: String = ""
//    @ObservedObject var apiFunctions: APIFunctions
    @StateObject var apiFunctions = APIFunctions()
    @State var newsSheetOpen = false;
    @State var tradeOpen = false;
    @State var tradeShares: String = "";
    
    var body: some View {
        if (apiFunctions.companyDescription == nil
            || apiFunctions.latestPrice == nil
            || apiFunctions.companySocialSentiment == nil
            || apiFunctions.companyNews == nil
            || apiFunctions.companyPeers == nil
            || apiFunctions.isLoading == true){
            VStack{
                Spacer()
                ProgressView()
                Spacer()
            }.onAppear{
                //backend calls
                apiFunctions.fetchLatestPrice(ticker: ticker)
                apiFunctions.fetchCompanyDescription(ticker: ticker)
                apiFunctions.fetchCompanySocialSentiment(ticker: ticker)
                apiFunctions.fetchCompanyNews(ticker: ticker)
                apiFunctions.fetchCompanyPeers(ticker: ticker)
            }
        }
        else {
            ScrollView{
                VStack {
                    // Logo + name
                    HStack {
                        VStack {
                            Text(apiFunctions.companyDescription!.name)
                                .font(.subheadline)
                            .foregroundColor(Color.gray)
                            Spacer()
                        }
                        
                        Spacer()
                        KFImage(URL(string: String(apiFunctions.companyDescription!.logo)))
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 50, height: 50)
                    }
                    
                    // Price / perecent
                    HStack {
                        Text("$\(Float(apiFunctions.latestPrice!.price)!, specifier: "%.2f")")
                            .fontWeight(.bold)
                            .font(.title)
                            .padding(.trailing)
                        
                        if (Float(apiFunctions.latestPrice!.percentChange)! > 0) {
                            Image(systemName: "arrow.up.right")
                            .foregroundColor(changeTextColor(change: Float(apiFunctions.latestPrice!.change)!))
                        } else {
                            Image(systemName: "arrow.down.right")
                            .foregroundColor(changeTextColor(change: Float(apiFunctions.latestPrice!.change)!))
                        }
                        Text("$\(Float(apiFunctions.latestPrice!.change)!, specifier: "%.2f")(\(Float(apiFunctions.latestPrice!.percentChange)!, specifier: "%.2f")%)")
                            .font(.headline)
                            .padding(.trailing)
                            .foregroundColor(changeTextColor(change: Float(apiFunctions.latestPrice!.change)!))

                        Spacer()
                    }
                    
                    // Charts
                    TabView {
                        TabLeft()
                            .tabItem {
                                Label("Hourly", systemImage: "chart.xyaxis.line")
                            }
                        
                        TabRight()
                            .tabItem {
                                Label("Historical", systemImage: "clock")
                            }
                    }
                    .frame(
                        width: .infinity, height: 450, alignment: .center
                    )
                    
                    // Portfolio
                    VStack{
                        Text("Portfolio")
                            .padding(.bottom)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.title2)
                    
                        HStack {
                            Text("You have 0 shares of AAPL Start trading!")
                                .font(.body)
                            Spacer()
                            Button(action: {tradeOpen = true}){
                                Text("Trade!")
                            }
                            .sheet(isPresented: $tradeOpen) {
                                VStack {
                                    Image(systemName: "xmark")
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                        .padding([.top, .leading, .trailing])
                                        .onTapGesture{tradeOpen = false}
                                        .foregroundColor(.black)
                                    
                                    Text("Trade \(apiFunctions.companyDescription!.name) shares").foregroundColor(.black)
                                    Spacer()
                                    HStack {
                                        TextField("0", text: $tradeShares)
                                        .padding()
                                        .foregroundColor(.black)
                                        .keyboardType(.numberPad)
                                        .font(Font.system(size: 100, design: .default))
                                        
                                        VStack {
                                            let shareText = Int(tradeShares) ?? 0 == 1 ? "Share" : "Shares"
                                            Text(shareText)
                                                .font(.largeTitle)
                                                .foregroundColor(.black)
                                                .padding([.top, .trailing])
                                        }
                                    }
                                    HStack {
                                        Spacer()
                                        Group {
                                            let tot = Float(apiFunctions.latestPrice!.price)! * (Float(self.tradeShares) ?? 0.0)
                                            Text("x $\(Float(apiFunctions.latestPrice!.price)!, specifier: "%.2f")/share = \(tot, specifier: "%.2f")")
                                                .foregroundColor(.black)
                                                .padding(.trailing)
                                                .font(.title3)
                                        }
                                    }
                                    Spacer()
                                    
                                    Text("$10.00 available to buy \(ticker)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                        
                                    HStack{
                                        Spacer()
                                        Button (action: {}){
                                            Text("Buy")
                                        }
                                        .padding(EdgeInsets(top: 15, leading: 70, bottom: 15, trailing: 70))
                                        .background(/*@START_MENU_TOKEN@*//*@PLACEHOLDER=View@*/Color.green/*@END_MENU_TOKEN@*/)
                                        .foregroundColor(/*@START_MENU_TOKEN@*/.white/*@END_MENU_TOKEN@*/)
                                        .cornerRadius(50)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        Button (action: {}){
                                            Text("Sell")
                                        }
                                        .padding(EdgeInsets(top: 15, leading: 70, bottom: 15, trailing: 70))
                                        .background(/*@START_MENU_TOKEN@*//*@PLACEHOLDER=View@*/Color.green/*@END_MENU_TOKEN@*/)
                                        .foregroundColor(/*@START_MENU_TOKEN@*/.white/*@END_MENU_TOKEN@*/)
                                        .cornerRadius(50)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        Spacer()
                                        
                                    }
                                }
                                
                            }
                            .frame(width: 120, height: 50)
                            .background(/*@START_MENU_TOKEN@*//*@PLACEHOLDER=View@*/Color.green/*@END_MENU_TOKEN@*/)
                            .foregroundColor(/*@START_MENU_TOKEN@*/.white/*@END_MENU_TOKEN@*/)
                            .cornerRadius(50)
                        }
                    }
                    .padding(.vertical)
                    
                    // Stats
                    VStack {
                        Text("Stats")
                            .padding(.bottom)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.title2)
                    
                        HStack {
                            VStack(alignment: .leading){
                                HStack {
                                    Text("High Price:")
                                        .fontWeight(.bold)
                                    Text(apiFunctions.latestPrice!.high)
                                }.padding(.bottom, 4)
                                HStack {
                                    Text("Low price:")
                                        .fontWeight(.bold)
                                    Text(apiFunctions.latestPrice!.low)
                                }
                            }
                            .padding(.trailing)
                            VStack{
                                HStack {
                                    Text("Open price:")
                                        .fontWeight(.bold)
                                    Text(apiFunctions.latestPrice!.open)
                                        
                                }.padding(.bottom, 4)
                                HStack {
                                    Text("Prev close:")
                                        .fontWeight(.bold)
                                    Text(apiFunctions.latestPrice!.previousClose)
                                }
                            }
                            Spacer()
                        }
                    }.padding(.bottom)
                    
                    // About
                    VStack{
                        Text("About")
                            .padding(.bottom)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.title2)

                        HStack {
                            VStack(alignment: .leading) {
                                Text("IPO Start Date:")
                                    .font(.callout)
                                    .fontWeight(.bold)
                                    .padding(.bottom, 0.5)
                                Text("Industry:")
                                    .font(.callout)
                                    .fontWeight(.bold)
                                    .padding(.bottom, 0.5)
                                Text("Webpage:")
                                    .font(.callout)
                                    .fontWeight(.bold)
                                    .padding(.bottom, 0.5)
                                Text("Company Peers:")
                                    .font(.callout)
                                    .fontWeight(.bold)
                                    .padding(.bottom, 0.5)
                            }

                            .padding(.trailing)
                            VStack(alignment: .leading) {
                                ScrollView(.horizontal) {
                                    Text(apiFunctions.companyDescription!.ipo)
                                        .font(.callout)
                                    .padding(.bottom, 0.5)
                                }
                                ScrollView(.horizontal) {
                                    Text(apiFunctions.companyDescription!.finnhubIndustry)
                                        .font(.callout)
                                    .padding(.bottom, 0.5)
                                }
                                ScrollView(.horizontal) {
                                    Link(apiFunctions.companyDescription!.weburl, destination: URL(string: apiFunctions.companyDescription!.weburl)!)
                                        .font(.callout)
                                    .padding(.bottom, 0.5)
                                }
                                ScrollView(.horizontal) {
                                    HStack {
                                        ForEach(apiFunctions.companyPeers![..<5], id: \.self) { stock in
                                            NavigationLink(destination: StockDetails(ticker: stock)){
                                                Text("\(stock), ")
                                                    .font(.callout)
                                                    .padding(.bottom, 0.5)
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.leading)
                            Spacer()
                        }
                    }
                    .padding(.bottom)
                    
                    // Insights table
                    VStack{
                        Text("Insights")
                            .padding(.bottom)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.title2)
                    
                        VStack{
                            Text("Social Sentiments")
                                .font(.title2)
                                .padding(.bottom)
                            HStack {
                                List {
                                    Text("Apple Inc")
                                    Text("Total Mentions").frame(height: 45)
                                    Text("Positive Mentions").frame(height: 45)
                                    Text("Negative Mentions").frame(height: 45)
                                }
                                .listStyle(PlainListStyle())
                                
                                List {
                                    Text("Reddit")
                                    Text(String(apiFunctions.companySocialSentiment!.reddit.mention)).frame(height: 45)
                                    Text(String(apiFunctions.companySocialSentiment!.reddit.positiveMention)).frame(height: 45)
                                    Text(String(apiFunctions.companySocialSentiment!.reddit.negativeMention)).frame(height: 45)
                                }
                                .listStyle(PlainListStyle())
                                
                                List {
                                    Text(apiFunctions.companyDescription!.name)
                                    Text(String(apiFunctions.companySocialSentiment!.twitter.mention)).frame(height: 45)
                                    Text(String(apiFunctions.companySocialSentiment!.twitter.positiveMention)).frame(height: 45)
                                    Text(String(apiFunctions.companySocialSentiment!.twitter.negativeMention)).frame(height: 45)
                                }
                                .listStyle(PlainListStyle())
                                
                            }.frame(width: .infinity, height: 250)
                        }
                    }
                    .padding(.vertical)
                    
                    // Recommendation trends chart
                    
                    // Historical EPS Surprises chart
                    
                    // News
                    VStack{
                        Text("News")
                            .padding(.bottom)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.title2)
                        
                        // First row
                        if (apiFunctions.companyNews!.count > 0){
                            VStack {
                                VStack {
                                    KFImage(URL(string: apiFunctions.companyNews![0].image)).resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: .infinity, height: 220)
                                        .scaledToFill()
                                        .clipped()
                                        .cornerRadius(20)
                                }
                                Spacer()
                                VStack {
                                    HStack {
                                        Text(apiFunctions.companyNews![0].source)
                                            .font(.footnote)
                                            .fontWeight(.bold)
                                            .foregroundColor(Color.gray)
                                        Text(getTimeSince(time:apiFunctions.companyNews![0].datetime))
                                            .font(.footnote)
                                            .fontWeight(.bold)
                                            .foregroundColor(Color.gray)
                                    }.frame(maxWidth: .infinity, alignment: .leading)
                                    Text(apiFunctions.companyNews![0].headline)
                                        .fontWeight(.bold)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }.frame(width: 360, height: 300)
                                .onTapGesture{newsSheetOpen = true}
                                .sheet(isPresented: $newsSheetOpen) {
                                    newsSheet(newsSheetOpen: $newsSheetOpen,
                                              news: apiFunctions.companyNews![0])
                                }

                            Divider()
                                .padding(.vertical)

                            ForEach(apiFunctions.companyNews![1..<20], id: \.datetime) { news in
                                HStack{
                                    VStack {
                                        HStack {
                                            Text(news.source)
                                                .font(.footnote)
                                                .fontWeight(.bold)
                                                .foregroundColor(Color.gray)
                                            Text(getTimeSince(time:news.datetime))
                                                .font(.footnote)
                                                .fontWeight(.bold)
                                                .foregroundColor(Color.gray)
                                        }.frame(maxWidth: .infinity, alignment: .leading)
                                        Text(news.headline)
                                            .fontWeight(.bold)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    KFImage(URL(string: news.image))
                                        .resizable()
                                        .scaledToFill()
                                        .aspectRatio(1, contentMode: .fill)
                                        .frame(width: 100, height: 100)
                                        .clipped()
                                        .cornerRadius(20)
                                }
                                .onTapGesture{newsSheetOpen = true}
                                .sheet(isPresented: $newsSheetOpen) {
                                    newsSheet(newsSheetOpen: $newsSheetOpen,
                                              news: news)
                                }
                            }
                        }
                    }
                }
                .padding(.all)
            }.navigationTitle(ticker)
        }
    }
}

struct TabLeft: View {
    var body : some View {
        Text("Tab 1")
    }
}

struct TabRight: View {
    var body : some View {
        Text("Tab 2")
    }
}

struct StockDetails_preview: PreviewProvider {
    static var previews: some View {
        StockDetails(ticker: "AAPL").environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

func getTimeSince(time: Double) -> String{
    let currentEpoch = Date().timeIntervalSince1970
    let elapsed = currentEpoch - time
    let timeElapsed = Date(timeIntervalSince1970: elapsed)
    let calendar = Calendar.current
    let day = calendar.component(.day, from: timeElapsed)
    let hour = calendar.component(.hour, from: timeElapsed)
    let minute = calendar.component(.minute, from: timeElapsed)
    if (day > 1){
        return "\(day-1) d, \(hour) hr, \(minute) min"
    } else {
        return "\(hour) hr, \(minute) min"
    }
}

func getDateTime(time: Double) -> String {
    let date = Date(timeIntervalSince1970: time)
    let calendar = Calendar.current
    let month_names = Calendar.current.monthSymbols
    
    let month = month_names[calendar.component(.month, from: date)-1]
    let day = calendar.component(.day, from: date)
    let year = calendar.component(.year, from: date)
    return "\(month) \(day), \(year)"
}

struct newsSheet: View {
    @Binding var newsSheetOpen: Bool
    @State var news: CompanyNews
    
    var body: some View {
        VStack{
            Image(systemName: "xmark")
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding([.top, .leading, .trailing])
                .onTapGesture{newsSheetOpen = false}
            Text(news.source)
                .font(.title)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(getDateTime(time: news.datetime))
                .font(.callout)
                .foregroundColor(Color.gray)
                .frame(maxWidth: .infinity, alignment: .leading)
            Divider()
            Text(news.headline)
                .font(.title3)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(news.summary)
                .font(.footnote)
                .frame(maxWidth: .infinity, alignment: .leading)
            HStack{
                Text("For more details, click ")
                    .foregroundColor(Color.gray)
                Link("here", destination: URL(string: news.url)!)
                Spacer()
            }.font(.footnote)
            
            HStack{
                Button(action: {
                    let shareString = "Check out this link:"
                    let twitterURL = news.url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
                    let stringToOpen = "https://twitter.com/intent/tweet?text=\(shareString)&url=\(twitterURL)"
                    let escapedShareString = stringToOpen.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
                    let url = URL(string: escapedShareString)
                    UIApplication.shared.open(url!)
                }) {
                    Image("TwitterIcon").resizable()
                        .scaledToFill()
                        .aspectRatio(1, contentMode: .fill)
                        .frame(width: 50, height: 50)
                }
                
                Button(action: {
                    let facebookURL = news.url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
                    let stringToOpen = "https://www.facebook.com/sharer/sharer.php?u=\(facebookURL)&amp;src=sdkpreparse"
                    let escapedShareString = stringToOpen.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
                    let url = URL(string: escapedShareString)
                    UIApplication.shared.open(url!)
                }) {
                    Image("FacebookIcon").resizable()
                        .scaledToFill()
                        .aspectRatio(1, contentMode: .fill)
                        .frame(width: 50, height: 50)
                }
                Spacer()
            }
            
            Spacer()
        }.padding(.all)
    }
}
