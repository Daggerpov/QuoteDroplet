// Taken directly from Quote Droplet (MacOS XCode project)

import Foundation

func getRandomQuoteByClassification(classification: String, completion: @escaping (Quote?, Error?) -> Void) {
    var urlString: String;
    if classification == "all" {
        // Modify the URL to include a filter for approved quotes
        urlString = "http://quote-dropper-production.up.railway.app/quotes/?approved=true"
    } else {
        // Modify the URL to include a filter for approved quotes and classification
        urlString = "http://quote-dropper-production.up.railway.app/quotes/classification=\(classification)?approved=true"
    }
    
    let url = URL(string: urlString)!

    var request = URLRequest(url: url)
    request.httpMethod = "GET"

    URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            completion(nil, error)
            return
        }
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            if let httpResponse = response as? HTTPURLResponse {
                completion(nil, NSError(domain: "HTTPError", code: httpResponse.statusCode, userInfo: nil))
            } else {
                completion(nil, NSError(domain: "HTTPError", code: -1, userInfo: nil))
            }
            return
        }

        guard let data = data else {
            completion(nil, NSError(domain: "NoDataError", code: -1, userInfo: nil))
            return
        }

        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let quotes = try decoder.decode([Quote].self, from: data)
            
            if quotes.isEmpty {
                completion(Quote(id: -1, text: "No Quote Found.", author: nil, classification: nil), nil)
            } else {
                let randomIndex = Int.random(in: 0..<quotes.count)
                completion(quotes[randomIndex], nil)
            }
        } catch {
            completion(nil, error)
        }
    }.resume()
}

func addQuote(text: String, author: String?, classification: String, completion: @escaping (Bool, Error?) -> Void) {
    let urlString = "http://quote-dropper-production.up.railway.app/quotes"
    guard let url = URL(string: urlString) else {
        completion(false, NSError(domain: "InvalidURL", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    // Create the quote object to be sent in the request body
    let quoteObject: [String: Any] = [
        "text": text,
        "author": author ?? "", // If author is nil, send an empty string
        "classification": classification.lowercased(), // Convert classification to lowercase
        "approved": false // Set approved status to false for new quotes
    ]
    
    // Convert the quote object to JSON data
    do {
        let jsonData = try JSONSerialization.data(withJSONObject: quoteObject, options: [])
        request.httpBody = jsonData
    } catch {
        completion(false, error)
        return
    }
    
    URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            completion(false, error)
            return
        }
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 409 {
                    // Handle the 409 error here
                    let conflictError = NSError(domain: "ConflictError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Thanks for submitting a quote.\n\nIt happens to already exist in the database, though. Great minds think alike."])
                                        completion(false, conflictError)
                } else {
                    completion(false, NSError(domain: "HTTPError", code: httpResponse.statusCode, userInfo: nil))
                }
            } else {
                completion(false, NSError(domain: "HTTPError", code: -1, userInfo: nil))
            }
            return
        }
        
        // The quote was successfully added
        completion(true, nil)
    }.resume()
}
