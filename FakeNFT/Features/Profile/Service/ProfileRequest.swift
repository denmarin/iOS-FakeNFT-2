import Foundation

struct ProfileRequest: NetworkRequest{
    var endpoint: URL? { URL(string: "\(RequestConstants.baseURL)/api/v1/profile/1")}
}
