import Foundation

struct ProfilePutRequest: NetworkRequest {
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/profile/1")
    }
    var httpMethod: HttpMethod = .put
    var dto: Dto?
}

struct ProfileUpdateDto: Dto {
    let name: String
    let description: String
    let avatar: String
    let website: String
    let likes: [String]
    
    func asDictionary() -> [String : String] {
        [
            "name": name,
            "description": description,
            "avatar": avatar.isEmpty ? "null" : avatar,
            "website": website,
            "likes": likes.isEmpty ? "null" : likes.joined(separator: ",")
        ]
    }
}
