import Foundation
import QRCode

struct RedirectionConfigurationModel: Codable, Equatable, Identifiable {
    var id: UUID?
    var shapeOnPixels: QRCodePixelShapes = .roundedRect
    var shapeEye: QRCodeEyeShapes = .roundedOuter

    static func apply(_ doc: inout QRCode.Document, _ redirectionDesign: RedirectionConfigurationModel) {
        doc.design.shape.eye = redirectionDesign.shapeEye.getQRClass()
        doc.design.shape.onPixels = redirectionDesign.shapeOnPixels.getQRClass()
    }
    
    enum ConfigOptions: CaseIterable {
        case shapeOnPixels
        case shapeEye
    }

    enum QRCodePixelShapes: String, Codable, CaseIterable, Equatable {
        case square = "square"
        case circle = "circle"
        case curvePixel = "curvePixel"
        case roundedRect = "roundedRect"
        case horizontal = "horizontal"
        case vertical = "vertical"
        case roundedPath = "roundedPath"
        case roundedEndIndent = "roundedEndIndent"
        case squircle = "squircle"
        case pointy = "pointy"
        case sharp = "sharp"
        case star = "star"
        case flower = "flower"
        case shiny = "shiny"

        func getQRClass() ->  QRCodePixelShapeGenerator {
            switch self {
            case .square: QRCode.PixelShape.Square()
            case .circle: QRCode.PixelShape.Circle()
            case .curvePixel: QRCode.PixelShape.CurvePixel()
            case .roundedRect: QRCode.PixelShape.RoundedRect()
            case .horizontal: QRCode.PixelShape.Horizontal()
            case .vertical: QRCode.PixelShape.Vertical()
            case .roundedPath: QRCode.PixelShape.RoundedPath()
            case .roundedEndIndent: QRCode.PixelShape.RoundedEndIndent()
            case .squircle: QRCode.PixelShape.Squircle()
            case .pointy: QRCode.PixelShape.Pointy()
            case .sharp: QRCode.PixelShape.Sharp()
            case .star: QRCode.PixelShape.Star()
            case .flower: QRCode.PixelShape.Flower()
            case .shiny: QRCode.PixelShape.Shiny()
            }
        }
    }

    enum QRCodeEyeShapes: String, Codable, CaseIterable, Equatable {
        case square = "square"
        case circle = "circle"
        case roundedRect = "roundedRect"
        case roundedOuter = "roundedOuter"
        case roundedPointingIn = "roundedPointingIn"
        case leaf = "leaf"
        case squircle = "squircle"
        case barsHorizontal = "barsHorizontal"
        case barsVertical = "barsVertical"
        case pixels = "pixels"
        case corneredPixels = "corneredPixels"
        case edges = "edges"
        case shield = "shield"

        func getQRClass() -> QRCodeEyeShapeGenerator {
            switch self {
            case .square: QRCode.EyeShape.Square()
            case .circle: QRCode.EyeShape.Circle()
            case .roundedRect: QRCode.EyeShape.RoundedRect()
            case .roundedOuter: QRCode.EyeShape.RoundedOuter()
            case .roundedPointingIn: QRCode.EyeShape.RoundedPointingIn()
            case .leaf: QRCode.EyeShape.Leaf()
            case .squircle: QRCode.EyeShape.Squircle()
            case .barsHorizontal: QRCode.EyeShape.BarsHorizontal()
            case .barsVertical: QRCode.EyeShape.BarsVertical()
            case .pixels: QRCode.EyeShape.Pixels()
            case .corneredPixels: QRCode.EyeShape.CorneredPixels()
            case .edges: QRCode.EyeShape.Edges()
            case .shield: QRCode.EyeShape.Shield()
            }
        }
    }
}
