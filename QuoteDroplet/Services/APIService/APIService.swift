// Originally taken directly from MacOS version

import Foundation

class APIService: IAPIService {
    private let baseUrl = "http://quote-dropper-production.up.railway.app"
    
    private func makeGetRequest<T: Decodable>(urlString: String, completion: @escaping (T?, Error?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil, NSError(domain: "InvalidURL", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
            return
        }
        
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                let code = (response as? HTTPURLResponse)?.statusCode ?? -1
                completion(nil, NSError(domain: "HTTPError", code: code, userInfo: nil))
                return
            }
            
            guard let data = data else {
                completion(nil, NSError(domain: "NoDataError", code: -1, userInfo: nil))
                return
            }
            
            do {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                completion(decodedData, nil)
            } catch {
                completion(nil, error)
            }
        }.resume()
    }
    
    func getQuotesByAuthor(author: String, completion: @escaping ([Quote]?, Error?) -> Void) {
        let urlString = "\(baseUrl)/quotes/author=\(author)"
        
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
    
    func getQuotesBySearchKeyword(searchKeyword: String, searchCategory: String, completion: @escaping ([Quote]?, Error?) -> Void) {
        let urlString = "\(baseUrl)/admin/search/\(searchKeyword)?category=\(searchCategory)"
        print("URL STRING:")
        print(urlString)
        
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
    private func makePostRequest<T: Decodable>(urlString: String, completion: @escaping (T?, Error?) -> Void) {
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
            
            guard let data = data else {
                completion(nil, NSError(domain: "NoDataError", code: -1, userInfo: nil))
                return
            }
            
            do {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                completion(decodedData, nil)
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
}
