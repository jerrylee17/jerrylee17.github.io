//
//  WebStuff.swift
//  csci571hw9
//
//  Created by Jerry Lee on 5/2/22.
//

import Foundation
import SwiftUI
import WebKit

struct WebSurprises: UIViewRepresentable {
    @Binding var title: String
    var url: URL
    var loadStatusChanged: ((Bool, Error?) -> Void)? = nil
    var ticker: String

    func makeCoordinator() -> WebSurprises.Coordinator {
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
        let parent: WebSurprises
        

        init(_ parent: WebSurprises) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            parent.loadStatusChanged?(true, nil)
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {

            let url = "https://directed-sonar-346104.wl.r.appspot.com/getCompanyEarnings?ticker=\(parent.ticker)"
            print(url)
            webView.evaluateJavaScript("api_call(\"\(url)\", \"\(parent.ticker)\")")
            parent.title = webView.title ?? ""
            parent.loadStatusChanged?(false, nil)
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.loadStatusChanged?(false, error)
        }
    }
}

struct DisplaySurprises: View {
    @State var title: String = ""
    @State var error: Error? = nil
    var ticker: String

    var body: some View {
        NavigationView {
            let path: String = Bundle.main.path(forResource: "surprises", ofType: "html")!
            let url = URL(fileURLWithPath: path, isDirectory: false)
            
            WebSurprises(title: $title, url: url, ticker: ticker)
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

