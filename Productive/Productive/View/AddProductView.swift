//
//  AddProductView.swift
//  Productive
//
//  Created by Prarthana Das on 19/08/23.
//

import SwiftUI
import PhotosUI

struct AddProductView: View {
    
    @ObservedObject var products = Products()
    @State private var product_type = "Product"
    @State private var product_type_new = ""
    @State private var product_name = ""
    @State private var price = 0.0
    @State private var taxPercentage = 12
    @FocusState private var editorFocused : Bool
    @Environment(\.dismiss) var dismiss
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var imageItem: PhotosPickerItem?
    @State private var imageSelected: Image?
    @State private var imageData: Data?
    
    
    var flagSuccessfulSave = false
    let taxPercentages = [5, 12, 18, 28]
    let productDataController = ProductDataController()
    
    
    var currencyCode: FloatingPointFormatStyle<Double>.Currency {
        return .currency(code: Locale.current.currency?.identifier ?? "USD")
    }
    
    var tax: Double{
        return price * Double(taxPercentage)/100
    }
    
    var grandTotal : Double {
        return tax + price
    }
    
    var body: some View {
        NavigationView{
            Form{
                Section{
                    Picker("Product Type", selection: $product_type){
                        ForEach(products.productTypes, id: \.self){
                            Text($0)
                        }
                    }
                    if(product_type == "Other"){
                        TextField("Enter Product Type", text: $product_type_new)
                    }
                }header:{
                    Text("Product type")
                }
                
                VStack(alignment:.leading){
                    Section{
                        TextField("Enter product name here", text: $product_name)
                            .focused($editorFocused)
                    } header: {
                        Text("Product name")
                    }
                    Spacer()
                    Section{
                        PhotosPicker("Select product image", selection: $imageItem, matching: .images)
                        if let imageSelected {
                            imageSelected
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                        }
                    }
                    .onChange(of: imageItem){ _ in
                        Task {
                            if let data = try? await imageItem?.loadTransferable(type: Data.self) {
                                if let uiImage = UIImage(data: data){
                                    imageData = data
                                    imageSelected = Image(uiImage: uiImage)
                                    return
                                }
                            }
                            print("Image selection failed")
                        }
                    }
                }
                
                
                Section{
                    TextField("Price", value: $price, format: currencyCode)
                        .keyboardType(.decimalPad)
                        .focused($editorFocused)
                }header: {
                    Text("Product Price")
                }
                
                Section{
                    Picker("Tax", selection: $taxPercentage){
                        ForEach(taxPercentages, id:\.self){
                            Text($0, format: .percent)
                        }
                    }.pickerStyle(.segmented)
                }header:{
                    Text("Tax brackets")
                }
                Section{
                    Text(tax, format: currencyCode)
                }header: {
                    Text("Tax Imposed")
                }

                Section{
                    Text(grandTotal, format: currencyCode)
                }header: {
                    Text("Grand Total")
                }
                
                
            }
            .navigationTitle("Add Product")
            .toolbar {
                ToolbarItem(placement: ToolbarItemPlacement.navigationBarTrailing){
                    Button("Add"){
                        if(product_type_new != ""){
                            product_type = product_type_new
                        }
                        let productItem = ProductItemAdd(image: imageData ?? Data(), price: price, product_name: product_name, product_type: product_type, tax: tax)

                        productDataController.addProductData(productData: productItem){data, error in
                            guard error == nil else {
                                alertTitle = "Failure"
                                alertMessage = "Product data could not saved"
                                print("Data not saved")
                                return
                            }
                            if let data = data{
                                let isImagePresent = data.product_details.image!.count
                              //  products.items.append(ProductItem(image: isImagePresent == 0 ? "" : "someImage", price: price, product_name: product_name, product_type: product_type, tax: tax))
                                print(data.product_id)
                                print(data.product_details)
                                alertTitle = "Successful"
                                alertMessage = data.message + "\nProduct ID: \(data.product_id)"
                                showAlert = true
                            } else {
                                print("POST SUCCESSDFUL BUT DATA NOT DECODED")
                            }
                        }
                    }
                    .disabled( product_name.isEmpty || price.isZero)
                }
                
                
                ToolbarItemGroup(placement: .keyboard){
                    Spacer()
                    Button("Done"){
                        editorFocused = false
                    }
                }
            }
            .alert(alertTitle,isPresented: $showAlert){
                Button("Okay"){
                    dismiss()
                }
            }message : {
                Text(alertMessage)
            }
        }
    }
}

struct AddProductView_Previews: PreviewProvider {
    static var previews: some View {
        AddProductView()
    }
}
