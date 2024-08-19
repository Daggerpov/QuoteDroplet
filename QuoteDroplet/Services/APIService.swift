// Taken directly from Quote Droplet (MacOS XCode project)

import Foundation

let baseUrl = "http://quote-dropper-production.up.railway.app"

func getRandomQuoteByClassification(classification: String, completion: @escaping (Quote?, Error?) -> Void, isShortQuoteDesired: Bool = false) {
    var urlString: String;
    if classification == "all" {
        // Modify the URL to include a filter for approved quotes
        urlString = "\(baseUrl)/quotes"
    } else {
        // Modify the URL to include a filter for approved quotes and classification
        urlString = "\(baseUrl)/quotes/classification=\(classification)"
    }
    
    if isShortQuoteDesired {
        urlString += "/maxQuoteLength=65"
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
                completion(Quote(id: -1, text: "No Quote Found.", author: nil, classification: nil, likes: 0), nil)
            } else {
                let randomIndex = Int.random(in: 0..<quotes.count)
                completion(quotes[randomIndex], nil)
            }
        } catch {
            completion(nil, error)
        }
    }.resume()
}

func getQuotesByAuthor(author: String, completion: @escaping ([Quote]?, Error?) -> Void) {
    let urlString = "\(baseUrl)/quotes/author=\(author)"
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
            completion(quotes, nil)
        } catch {
            completion(nil, error)
        }
    }.resume()
}

func getQuoteByAuthorAndIndex(author: String, index: Int, completion: @escaping (Quote?, Error?) -> Void) {
    let urlString = "\(baseUrl)/quotes/author=\(author)/index=\(index)"
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
            let quote = try decoder.decode(Quote.self, from: data)
            completion(quote, nil)
        } catch {
            completion(nil, error)
        }
    }.resume()
}


func getRecentQuotes(limit: Int, completion: @escaping ([Quote]?, Error?) -> Void) {
    let urlString = "\(baseUrl)/quotes/recent/\(limit)"
    guard let url = URL(string: urlString) else {
        completion(nil, NSError(domain: "InvalidURL", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
        return
    }
    
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
            completion(quotes, nil)
        } catch {
            completion(nil, error)
        }
    }.resume()
}


func addQuote(text: String, author: String?, classification: String, completion: @escaping (Bool, Error?) -> Void) {
    let urlString = "\(baseUrl)/quotes"
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
        "approved": false, // Set approved status to false for new quotes
        "likes": 0
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

func likeQuote(quoteID: Int, completion: @escaping (Quote?, Error?) -> Void) {
    let urlString = "\(baseUrl)/quotes/like/\(quoteID)"
    guard let url = URL(string: urlString) else {
        completion(nil, NSError(domain: "InvalidURL", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            completion(nil, error)
            return
        }
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode),
              let data = data else {
            if let httpResponse = response as? HTTPURLResponse {
                completion(nil, NSError(domain: "HTTPError", code: httpResponse.statusCode, userInfo: nil))
            } else {
                completion(nil, NSError(domain: "HTTPError", code: -1, userInfo: nil))
            }
            return
        }
        
        // Parse the JSON response to get the updated quote
        do {
            let updatedQuote = try JSONDecoder().decode(Quote.self, from: data)
            completion(updatedQuote, nil)
        } catch {
            completion(nil, error)
        }
    }.resume()
}

func unlikeQuote(quoteID: Int, completion: @escaping (Quote?, Error?) -> Void) {
    let urlString = "\(baseUrl)/quotes/unlike/\(quoteID)"
    guard let url = URL(string: urlString) else {
        completion(nil, NSError(domain: "InvalidURL", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            completion(nil, error)
            return
        }
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode),
              let data = data else {
            if let httpResponse = response as? HTTPURLResponse {
                completion(nil, NSError(domain: "HTTPError", code: httpResponse.statusCode, userInfo: nil))
            } else {
                completion(nil, NSError(domain: "HTTPError", code: -1, userInfo: nil))
            }
            return
        }
        
        // Parse the JSON response to get the updated quote
        do {
            let updatedQuote = try JSONDecoder().decode(Quote.self, from: data)
            completion(updatedQuote, nil)
        } catch {
            completion(nil, error)
        }
    }.resume()
}

func getQuoteByID(id: Int, completion: @escaping (Quote?, Error?) -> Void) {
    guard let url = URL(string: "\(baseUrl)/quotes/\(id)") else {
        completion(nil, NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
        return
    }
    
    URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            completion(nil, error)
            return
        }
        
        guard let data = data else {
            completion(nil, NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"]))
            return
        }
        
        do {
            let quote = try JSONDecoder().decode(Quote.self, from: data)
            completion(quote, nil)
        } catch {
            completion(nil, error)
        }
    }.resume()
}

func getLikeCountForQuote(quoteGiven: Quote, completion: @escaping (Int) -> Void) {
    guard let url = URL(string: "\(baseUrl)/quoteLikes/\(quoteGiven.id)") else {
        completion(0)
        return
    }
    
    URLSession.shared.dataTask(with: url) { data, response, error in
        if let data = data,
           let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
           let likeCount = json["likes"] as? Int {
            completion(likeCount)
        } else {
            completion(0)
        }
    }.resume()
}

func getCountForCategory(category: QuoteCategory, completion: @escaping (Int) -> Void) {
    guard let url = URL(string: "\(baseUrl)/quoteCount?category=\(category.rawValue.lowercased())") else {
        completion(0)
        return
    }
    URLSession.shared.dataTask(with: url) { data, response, error in
        if let data = data,
           let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
           let count = json["count"] as? Int {
            completion(count)
        } else {
            completion(0)
        }
    }.resume()
}
