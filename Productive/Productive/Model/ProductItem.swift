//
//  ProductItem.swift
//  Productive
//
//  Created by Prarthana Das on 19/08/23.
//

import Foundation
import UIKit

struct ProductItem:  Codable {
    let image: String?
    let price: Double
    let product_name: String
    let product_type: String
    let tax: Double
    
}

struct ProductItemAdd: Codable{
    let image: Data?
    let price: Double
    let product_name: String
    let product_type: String
    let tax: Double
    
    init(image: Data, price: Double, product_name: String, product_type: String, tax: Double) {
        self.image = image
        self.price = price
        self.product_name = product_name
        self.product_type = product_type
        self.tax = tax
    }
}

struct ProductAdditionSuccessful: Codable{
    let message: String
    let product_details: ProductItemAdd
    let success: Bool
    let product_id: Int
}


class Products: ObservableObject {
    
    @Published var items = [ProductItem](){
        didSet{
            Products.init()
        }
    }
    
    let productDataController = ProductDataController()
    
    var productTypes : [String] {
        var interim = Set<String>()
        for item in items {
            if item.product_type != ""{
                interim.insert(item.product_type)
            }
        }
        return Array(interim).sorted()
    }
    
    
    init(){
         productDataController.getProductData{ products, error in
             guard error == nil else {
                 return
             }
             if let products = products {
                 self.items = products.filter{$0.price > 0 && $0.product_name != "" && $0.product_type != ""}
                 return
             }
             self.items = []
        }
    }
}
