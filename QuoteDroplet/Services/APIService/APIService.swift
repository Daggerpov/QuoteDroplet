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
    
    func getRandomQuoteByClassification(classification: String, completion: @escaping (Quote?, Error?) -> Void, isShortQuoteDesired: Bool = false) {
        var urlString = "\(baseUrl)/quotes"
        if classification != "all" {
            urlString += "/classification=\(classification)"
        }
        if isShortQuoteDesired {
            urlString += "/maxQuoteLength=65"
        }
        
        makeGetRequest(urlString: urlString) { (quotes: [Quote]?, error) in
            if let quotes = quotes, !quotes.isEmpty {
                let randomQuote = quotes.randomElement() ?? Quote(id: -1, text: "No Quote Found.", author: nil, classification: nil, likes: 0)
                completion(randomQuote, nil)
            } else {
                completion(nil, error)
            }
        }
    }
    
    func getQuotesByAuthor(author: String, completion: @escaping ([Quote]?, Error?) -> Void) {
        let urlString = "\(baseUrl)/quotes/author=\(author)"
        makeGetRequest(urlString: urlString, completion: completion)
    }
    
    func getQuotesBySearchKeyword(searchKeyword: String, searchCategory: String, completion: @escaping ([Quote]?, Error?) -> Void) {
        let urlString = "\(baseUrl)/admin/search/\(searchKeyword)?category=\(searchCategory)"
        makeGetRequest(urlString: urlString, completion: completion)
    }
    
    func getRecentQuotes(limit: Int, completion: @escaping ([Quote]?, Error?) -> Void) {
        let urlString = "\(baseUrl)/quotes/recent/\(limit)"
        makeGetRequest(urlString: urlString, completion: completion)
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
        
        let quoteObject: [String: Any] = [
            "text": text,
            "author": author ?? "",
            "classification": classification.lowercased(),
            "approved": false,
            "likes": 0
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: quoteObject, options: [])
        } catch {
            completion(false, error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(false, error)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 409 {
                    let conflictError = NSError(domain: "ConflictError", code: 409, userInfo: [NSLocalizedDescriptionKey: "Quote already exists in the database."])
                    completion(false, conflictError)
                } else {
                    completion(false, NSError(domain: "HTTPError", code: -1, userInfo: nil))
                }
                return
            }
            
            completion(true, nil)
        }.resume()
    }
    
    func likeQuote(quoteID: Int, completion: @escaping (Quote?, Error?) -> Void) {
        let urlString = "\(baseUrl)/quotes/like/\(quoteID)"
        makePostRequest(urlString: urlString, completion: completion)
    }
    
    func unlikeQuote(quoteID: Int, completion: @escaping (Quote?, Error?) -> Void) {
        let urlString = "\(baseUrl)/quotes/unlike/\(quoteID)"
        makePostRequest(urlString: urlString, completion: completion)
    }
    
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
        makeGetRequest(urlString: "\(baseUrl)/quotes/\(id)", completion: completion)
    }
    
    func getLikeCountForQuote(quoteGiven: Quote, completion: @escaping (Int) -> Void) {
        makeGetRequest(urlString: "\(baseUrl)/quoteLikes/\(quoteGiven.id)") { (response: [String: Any]?, _) in
            let likeCount = response?["likes"] as? Int ?? 0
            completion(likeCount)
        }
    }
    
    func getCountForCategory(category: QuoteCategory, completion: @escaping (Int) -> Void) {
        makeGetRequest(urlString: "\(baseUrl)/quoteCount?category=\(category.rawValue.lowercased())") { (response: [String: Any]?, _) in
            let count = response?["count"] as? Int ?? 0
            completion(count)
        }
    }
}

