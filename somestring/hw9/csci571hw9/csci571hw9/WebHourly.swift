//
//  WebStuff.swift
//  csci571hw9
//
//  Created by Jerry Lee on 5/2/22.
//

import Foundation
import SwiftUI
import WebKit

struct WebViewHourly: UIViewRepresentable {
    @Binding var title: String
    var url: URL
    var loadStatusChanged: ((Bool, Error?) -> Void)? = nil
    var ticker: String
    var latestPriceTimestamp: Double
    var change: Double

    func makeCoordinator() -> WebViewHourly.Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let view = WKWebView()
        view.navigationDelegate = context.coordinator
        let request = URLRequest(url: url)
        view.load(request)
        view.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        return view
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // you can access environment via context.environment here
        // Note that this method will be called A LOT
        uiView.loadFileURL(url, allowingReadAccessTo: url)
    }

    func onLoadStatusChanged(perform: ((Bool, Error?) -> Void)?) -> some View {
        var copy = self
        copy.loadStatusChanged = perform
        return copy
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: WebViewHourly
        

        init(_ parent: WebViewHourly) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            parent.loadStatusChanged?(true, nil)
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            var toTimeStamp = Date().timeIntervalSince1970
            var fromTimeStamp: Double = 0.0
            if (toTimeStamp - 1000 * parent.latestPriceTimestamp < 5*60*1000){
                toTimeStamp = parent.latestPriceTimestamp
            }
            fromTimeStamp = toTimeStamp - Double(5*60*1000)
            
            let url = "https://directed-sonar-346104.wl.r.appspot.com/getHistoricalData?ticker=\(parent.ticker)&timeInterval=5&fromTimestamp=\(Int(fromTimeStamp))&toTimestamp=\(Int(toTimeStamp))"
            webView.evaluateJavaScript("api_call(\"\(url)\", \"\(parent.ticker)\", \"\(parent.change)\")")
            parent.title = webView.title ?? ""
            parent.loadStatusChanged?(false, nil)
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.loadStatusChanged?(false, error)
        }
    }
}

struct DisplayHourly: View {
    @State var title: String = ""
    @State var error: Error? = nil
    var ticker: String
    var latestPriceTimestamp: Double
    var change: Double

    var body: some View {
        NavigationView {
            let path: String = Bundle.main.path(forResource: "hourly", ofType: "html")!
            let url = URL(fileURLWithPath: path, isDirectory: false)
            
            WebViewHourly(title: $title, url: url, ticker: ticker, latestPriceTimestamp: latestPriceTimestamp, change: change)
                .onLoadStatusChanged { loading, error in
                    if loading {
                        self.title = "Loading…"
                    }
                    else {
                        print("Done loading.")
                        if let error = error {
                            self.error = error
                            if self.title.isEmpty {
                                self.title = "Error"
                            }
                        }
                        else if self.title.isEmpty {
                            self.title = "Some Place"
                        }
                    }
            }
        }
    }
}

