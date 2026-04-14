import Foundation

struct OrderPayment: Codable {
    let success: Bool
    let orderId: String
    let id: String
}
