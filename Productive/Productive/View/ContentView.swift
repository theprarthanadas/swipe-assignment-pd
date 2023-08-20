//
//  ContentView.swift
//  Productive
//
//  Created by Prarthana Das on 19/08/23.
//

import SwiftUI

struct ContentView: View {
    @StateObject var products = Products()
    @State private var searchPhrase = ""
    @State private var showingAddProduct = false


    var body: some View {
        NavigationView{
            List{
                ForEach(searchResults, id: \.product_name){product in
                    HStack{
                        if product.image != "" {
                            AsyncImage(url: URL(string: product.image!)) { image in
                                image.resizable()
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 100, height: 100)
                        } else {
                            Image("genericProduct")
                                .resizable()
                                .frame(width: 100, height: 100)
                        }
                        VStack{
                            Text(product.product_name)
                                .font(.headline)
                            Text(product.product_type)
                                .font(.caption)
                        }
                        Spacer()
                        VStack{
                            Text(product.price + product.tax, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                            Text("*Tax included")
                                .font(.caption2)
                        }
                    }
                }
            }
            .navigationTitle("Productive")
            .searchable(text: $searchPhrase, prompt: "Look up a product")
            .toolbar {
                Button{
                    showingAddProduct = true
                } label:{
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showingAddProduct){
                AddProductView()
            }
        }
    }
    

    var searchResults: [ProductItem] {
        get{
            if searchPhrase.isEmpty {
                return products.items
            } else {
                return products.items.filter { @MainActor in
                    $0.product_name.lowercased().contains(searchPhrase.lowercased()) || $0.product_type.lowercased().contains(searchPhrase.lowercased())}
                
            }
        }
        set {
            products.items = newValue
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
