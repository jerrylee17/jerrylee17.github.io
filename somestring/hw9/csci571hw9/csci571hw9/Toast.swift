//
//  Toast.swift
//  csci571hw9
//
//  Created by Jerry Lee on 5/2/22.
//


import SwiftUI
import Foundation

struct Toast<Presenting>: View where Presenting: View {

    /// The binding that decides the appropriate drawing in the body.
    @Binding var isShowing: Bool
    /// The view that will be "presenting" this toast
    let presenting: () -> Presenting
    /// The text to show
    let text: String

    var body: some View {

        GeometryReader { geometry in
            ZStack(alignment: .center) {
                self.presenting()
                VStack {
                    Spacer()
                    Text(self.text)
                        .padding(EdgeInsets(top: 15, leading: 40, bottom: 15, trailing: 40))
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .font(.headline)
                        .cornerRadius(40)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .opacity(self.isShowing ? 1 : 0)
            }
        }
    }
}

extension View {

    func toast(isShowing: Binding<Bool>, text: String) -> some View {
        Toast(isShowing: isShowing,
              presenting: { self },
              text: text)
    }

}
