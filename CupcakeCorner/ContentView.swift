//
//  ContentView.swift
//  CupcakeCorner
//
//  Created by Cesar Lopez on 3/29/23.
//

import SwiftUI

struct ContentView: View {
    @StateObject var orderManager = OrderManager()
    
    var body: some View {
        NavigationView {
            
            
            Form {
                Section {
                    Picker("Select your cake type", selection: $orderManager.order.type) {
                        ForEach(OrderManager.types.indices, id: \.self) {
                            Text(OrderManager.types[$0])
                        }
                    }
                    
                    Stepper("Number of cakes: \(orderManager.order.quantity)", value: $orderManager.order.quantity, in: 3...20)
                }
                
                Section {
                    Toggle("Any special requests?", isOn: $orderManager.order.specialRequestEnabled.animation())
                    
                    if (orderManager.order.specialRequestEnabled) {
                        Toggle("Add extra Frosting", isOn: $orderManager.order.extraFrosting)
                        Toggle("Add sprinkles", isOn: $orderManager.order.addSprinkles)
                    }
                }
                
                Section {
                    NavigationLink {
                        AddressView(orderManager: orderManager)
                    } label: {
                        Text("Delivery details")
                    }
                }
            }
            .navigationTitle("Cupcake Corner")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
