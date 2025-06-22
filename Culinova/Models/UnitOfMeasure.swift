import Foundation

enum UnitOfMeasure: String, Codable, CaseIterable, Identifiable {
    case g, kg, ml, l, tsp, tbsp, cup, piece

    var id: String { rawValue }

    var display: String {
        switch self {
        case .g:   return "g"
        case .kg:  return "kg"
        case .ml:  return "ml"
        case .l:   return "L"
        case .tsp: return "tsp"
        case .tbsp:return "tbsp"
        case .cup: return "cup"
        case .piece: return "pc"
        }
    }
}
