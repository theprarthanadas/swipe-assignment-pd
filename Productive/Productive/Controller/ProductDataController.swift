//
//  ProductDataController.swift
//  Productive
//
//  Created by Prarthana Das on 19/08/23.
//

import Foundation
import UIKit

class ProductDataController{
    

    func getProductData(completion:@escaping (([ProductItem]?,Error?)->Void)) {
        let request = NSMutableURLRequest(url: NSURL(string: "https://app.getswipe.in/api/public/get")! as URL)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request as URLRequest){data, response, error in
            guard error == nil else{
                completion(nil, error)
                return
            }
            if let data = data {
                if let productData = try? JSONDecoder().decode([ProductItem].self, from: data){
                    completion(productData, nil)
                }
            }
        }
        task.resume()
    }
    
    func addProductData(productData: ProductItemAdd, onCompleting:@escaping ((ProductAdditionSuccessful?,Error?)->Void)){

        
        let image = UIImage(data: productData.image!)
        let imageKey = "image"
        let imageName = productData.product_name.trimmingCharacters(in: .whitespaces) + ".jpeg"
        
        let product_name_key = "product_name"
        let product_name_data = productData.product_name.trimmingCharacters(in: .whitespaces)
        
        let product_type_key = "product_type"
        let product_type_data = productData.product_type
        
        let tax_key = "tax"
        let tax_data = productData.tax

        let price_key = "price"
        let price_data = productData.price
        
        
        let url = URL(string: "https://app.getswipe.in/api/public/add")
        
        let boundary = UUID().uuidString

        
        var urlRequest = URLRequest(url: url!)
        urlRequest.httpMethod = "POST"
        
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        
        
        var body = Data()
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(imageKey)\"; filename=\"\(imageName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        if let imageData = image?.jpegData(compressionQuality: 0.75){
            body.append(imageData)
        }
 
        body.append("\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(product_name_key)\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(product_name_data)\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(product_type_key)\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(product_type_data)\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(price_key)\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(price_data)\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(tax_key)\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(tax_data)\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        urlRequest.httpBody = body
        
        
    

                let task = URLSession.shared.dataTask(with: urlRequest){data, response, error in
                    guard error == nil else{
                        print("POST UNSUCCESSFUL")
                       onCompleting(nil,error)
                        return
                    }
        
                    if let data = data {
                        if let successData = try? JSONDecoder().decode(ProductAdditionSuccessful.self, from: data){
                            print("POST SUCCESSFUL")
                            onCompleting(successData, nil)
                        }else {
                            print("DATA NOT DECODED")
                        }
                    }
                }
                task.resume()
    }
}
