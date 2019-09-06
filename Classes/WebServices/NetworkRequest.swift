//
//  NetworkRequest.swift
//
//
//

import Foundation
import UIKit

protocol NetworkRequest: class {
	associatedtype Model
	func load(withCompletion completion: @escaping (Model?) -> Void)
	func decode(_ data: Data) -> Model?
}

extension NetworkRequest {
	fileprivate func load(_ url: URL, withCompletion completion: @escaping (Model?) -> Void) {
		let configuration = URLSessionConfiguration.ephemeral
		let session = URLSession(configuration: configuration, delegate: nil, delegateQueue: OperationQueue.main)
		let task = session.dataTask(with: url, completionHandler: { [weak self] (data: Data?, response: URLResponse?, error: Error?) -> Void in
//            print(data as Any)
			guard let receivedData = data else {
				completion(nil)
				return
			}
			completion(self?.decode(receivedData))
		})
		task.resume()
	}
}

extension NetworkRequest {
    fileprivate func load(_ url: URL, httpMethod: String, body: String, headers: [AnyHashable: Any]?, withCompletion completion: @escaping ((Model?), [AnyHashable: Any]?) -> Void) {
        let configuration = URLSessionConfiguration.ephemeral
        
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = httpMethod
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        if let additionalHeaders = headers {
            for header in additionalHeaders {
                request.addValue(header.value as! String, forHTTPHeaderField: header.key as! String)
            }
        }
        request.httpBody = body.data(using: .utf8)!

        let session = URLSession(configuration: configuration, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request as URLRequest, completionHandler: { [weak self] (data: Data?, response: URLResponse?, error: Error?) -> Void in
            print(data as Any)
            if (data != nil) {
                print(String(decoding: data!, as: UTF8.self))
            }
            print(response as Any)
            let httpResponse = response as? HTTPURLResponse
            let responseHeaders = httpResponse?.allHeaderFields
            print(error as Any)
            guard let receivedData = data else {
                completion(nil, [:])
                return
            }
            completion(self?.decode(receivedData), responseHeaders)
        })
        task.resume()
    }
}

class ApiRequest<Resource: ApiResource> {
	let resource: Resource
	
	init(resource: Resource) {
		self.resource = resource
	}
}

extension ApiRequest: NetworkRequest {
	func decode(_ data: Data) -> Resource.Model? {
		return resource.makeModel(data: data)
	}
	
	func load(withCompletion completion: @escaping (Resource.Model?) -> Void) {
		load(resource.url, withCompletion: completion)
	}

    func load(httpMethod: String, body: String, headers: [AnyHashable: Any]?, completion: @escaping ((Resource.Model?), [AnyHashable: Any]?) -> Void) {
        load(resource.url, httpMethod: httpMethod, body: body, headers: headers, withCompletion: completion)
    }
}

class ImageRequest {
	let url: URL
	
	init(url: URL) {
		self.url = url
	}
}

extension ImageRequest: NetworkRequest {
	func decode(_ data: Data) -> UIImage? {
		return UIImage(data: data)
	}
	
	func load(withCompletion completion: @escaping (UIImage?) -> Void) {
		load(url, withCompletion: completion)
	}
}


