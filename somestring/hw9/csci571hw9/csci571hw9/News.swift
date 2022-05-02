//
//  News.swift
//  csci571hw9
//
//  Created by Jerry Lee on 5/1/22.
//

import SwiftUI
import Foundation
import Kingfisher

struct NewsDetail: View {
    var body : some View {
        Text("Here")
    }
}

struct NewsDetail_preview: PreviewProvider {
    static var previews: some View {
        NewsDetail().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
