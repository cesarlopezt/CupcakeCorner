//
//  ContentView.swift
//  CupcakeCorner
//
//  Created by Cesar Lopez on 3/29/23.
//

import SwiftUI

struct Response: Codable {
    var results: [Result]
}

struct Result: Codable {
    var trackId: Int
    var trackName: String
    var collectionName: String
}



class User: ObservableObject, Codable {
    enum CodingKeys: CodingKey {
        case name
    }
    
    @Published var name = ""
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
    }
}


struct TestForm: View {
    @State private var username = ""
    @State private var email = ""
    
    var body: some View {
        Form {
            Section {
                TextField("Username", text: $username)
                TextField("Email", text: $email)
            }
            Section {
                Button("Create account") {
                    print("creating account")
                }
            }
            .disabled(disabledForm)
        }
    }
    
    var disabledForm: Bool {
        username.isEmpty || email.isEmpty
    }
}

struct DumpView: View {
    @State private var results = [Result]()
    @State private var showingForm = false
    
    
    var body: some View {
        NavigationView {
            VStack {
                AsyncImage(url: URL(string: "https://hws.dev/img/bad.png")) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFit()
                    } else if phase.error != nil {
                        Text("There was an error loading the image")
                    } else {
                        ProgressView()
                    }
                }
                .frame(width: 200, height: 200)
                List(results, id: \.trackId) { item in
                    VStack(alignment: .leading) {
                        Text(item.trackName).font(.headline)
                        Text(item.collectionName)
                    }
                }
            }
            .toolbar {
                Button("Form") {
                    showingForm.toggle()
                }
            }
            .task {
                await loadData()
            }
            .sheet(isPresented: $showingForm) {
                TestForm()
            }
        }
    }
    
    func loadData() async {
        guard let url = URL(string: "https://itunes.apple.com/search?term=taylor-swift&entity=song") else {
            print("Invalid URL")
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let decodedResponse  = try? JSONDecoder().decode(Response.self, from: data) {
                print(decodedResponse.results)
                results = decodedResponse.results
            }
        } catch {
            print("Invalid Data")
        }
    }
}

struct DumpView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
