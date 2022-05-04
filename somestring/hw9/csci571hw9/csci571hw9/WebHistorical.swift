//
//  WebStuff.swift
//  csci571hw9
//
//  Created by Jerry Lee on 5/2/22.
//

import Foundation
import SwiftUI
import WebKit

struct WebViewHistorical: UIViewRepresentable {
    @Binding var title: String
    var url: URL
    var loadStatusChanged: ((Bool, Error?) -> Void)? = nil
    var ticker: String
    var latestPriceTimestamp: Double
    var change: Double

    func makeCoordinator() -> WebViewHistorical.Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let view = WKWebView()
        view.navigationDelegate = context.coordinator
        let request = URLRequest(url: url)
        view.load(request)
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
        let parent: WebViewHistorical
        

        init(_ parent: WebViewHistorical) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            parent.loadStatusChanged?(true, nil)
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            let toTimeStamp = Date().timeIntervalSince1970
            var dateComponent = DateComponents()
            dateComponent.month = -6
            dateComponent.day = -1
            let fromTimeStamp: Double = Calendar.current.date(
                byAdding: dateComponent,
                to: Date())!.timeIntervalSince1970
            
            let url = "https://directed-sonar-346104.wl.r.appspot.com/getHistoricalData?ticker=\(parent.ticker)&timeInterval=D&fromTimestamp=\(Int(fromTimeStamp))&toTimestamp=\(Int(toTimeStamp))"
            webView.evaluateJavaScript("api_call(\"\(url)\", \"\(parent.ticker)\", \"\(parent.change)\")")
            parent.title = webView.title ?? ""
            parent.loadStatusChanged?(false, nil)
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.loadStatusChanged?(false, error)
        }
    }
}

struct DisplayHistorical: View {
    @State var title: String = ""
    @State var error: Error? = nil
    var ticker: String
    var latestPriceTimestamp: Double
    var change: Double

    var body: some View {
        NavigationView {
            let path: String = Bundle.main.path(forResource: "historical", ofType: "html")!
            let url = URL(fileURLWithPath: path, isDirectory: false)
            
            WebViewHistorical(title: $title, url: url, ticker: ticker, latestPriceTimestamp: latestPriceTimestamp, change: change)
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

