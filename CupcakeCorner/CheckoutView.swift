//
//  CheckoutView.swift
//  CupcakeCorner
//
//  Created by Cesar Lopez on 3/29/23.
//

import SwiftUI

struct CheckoutView: View {
    @ObservedObject var orderManager: OrderManager
    
    @State private var confirmationTitle = ""
    @State private var confirmationMessage = ""
    @State private var showingConfirmation = false
    
    var body: some View {
        ScrollView {
            VStack {
                AsyncImage(
                    url: URL(string: "https://hws.dev/img/cupcakes@3x.jpg"),
                    scale: 3
                ) { image in
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    ProgressView()
                }
                .frame(height: 233)
                
                Text("Your total is \(orderManager.order.cost, format: .currency(code: "USD"))")
                    .font(.title)
                
                Button("Place Order") {
                    Task {
                        await placeOrder()
                    }
                }
                    .padding()
            }
        }
        .navigationTitle("Check out")
        .navigationBarTitleDisplayMode(.inline)
        .alert(confirmationTitle, isPresented: $showingConfirmation) {
            Button("OK") {}
        } message: {
            Text(confirmationMessage)
        }
    }
    
    func placeOrder() async {
        guard let encoded = try? JSONEncoder().encode(orderManager.order) else {
            print("Failed to encode order")
            return
        }
        
        let url = URL(string: "https://reqres.in/api/cupcakes")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        do {
            let (data, _) = try await URLSession.shared.upload(for: request, from: encoded)
            
            let decodedOrder = try JSONDecoder().decode(Order.self, from: data)
            
            confirmationTitle = "Thank you"
            confirmationMessage = "Your order for \(decodedOrder.quantity) x \(OrderManager.types[decodedOrder.type].lowercased()) cupcakes is on its way!"
             showingConfirmation = true
        } catch {
            confirmationTitle = "Checkout failed"
            confirmationMessage = "Sorry, there was a problem with your order try again soon."
             showingConfirmation = true
        }
    }
}

struct CheckoutView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CheckoutView(orderManager: OrderManager())
        }
    }
}
