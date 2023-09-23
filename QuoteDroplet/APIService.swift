// Taken directly from Quote Droplet (MacOS XCode project)

import Foundation

func getRandomQuoteByClassification(classification: String, completion: @escaping (Quote?, Error?) -> Void) {
    var urlString: String;
    if classification == "all" {
        urlString = "http://quote-dropper-production.up.railway.app/quotes/"
    } else {
        urlString = "http://quote-dropper-production.up.railway.app/quotes/classification=\(classification)"
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
