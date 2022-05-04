//
//  APIFunctions.swift
//  csci571hw9
//
//  Created by Jerry Lee on 4/30/22.
//

import Foundation

class FavoriteService: ObservableObject {
    @Published var favorites: [String] = []
    
    func loadFavorites() {
        self.favorites = UserDefaults.standard.object(forKey: "favorites") as? [String] ?? [String]()
    }
    
    func initializeFavorites(){
        let fav: [String] = []
        UserDefaults.standard.set(fav, forKey: "favorites")
    }
    
    func addToFavorites(ticker: String){
        self.favorites.append(ticker)
        UserDefaults.standard.set(self.favorites, forKey: "favorites")
        print(UserDefaults.standard.object(forKey: "favorites") as? [String] ?? [String]())
    }
    
    func removeFromFavorites(ticker: String){
        if let index = self.favorites.firstIndex(of: ticker) {
            self.favorites.remove(at: index)
        }
        
        UserDefaults.standard.set(self.favorites, forKey: "favorites")
    }
    
    func moveFavorites(from source: IndexSet, to destination: Int){
        self.favorites.move(fromOffsets: source, toOffset: destination)
        UserDefaults.standard.set(self.favorites, forKey: "favorites")
    }
    
    func removeFavorites(offsets: IndexSet){
        self.favorites.remove(atOffsets: offsets)
        UserDefaults.standard.set(self.favorites, forKey: "favorites")
    }
}
