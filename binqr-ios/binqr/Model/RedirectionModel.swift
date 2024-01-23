import Foundation
import QRCode

struct RedirectionModel: Codable, Equatable, Identifiable {
    var id: UUID?
    var name: String
    var slug: UUID?
    var redirectTo: String
    var configuration: RedirectionConfigurationModel?

    var urlString: String {
        return "https://binqr.io/r/\(slug!)"
    }
    var url: URL {
        return URL(string: urlString)!
    }
    var thumbnail: QRCode.Document {
        let doc = self.document(slug!.uuidString)
        doc.errorCorrection = .low
        
        return doc
    }
    var fullSize: QRCode.Document {
        let doc = self.document(urlString)
        doc.errorCorrection = .quantize
        doc.design.additionalQuietZonePixels = 1

        return doc
    }
    
    private func document(_ data: String) -> QRCode.Document {
        var doc = QRCode.Document(utf8String: data)
        doc.design.style.backgroundFractionalCornerRadius = 1
        RedirectionConfigurationModel.apply(&doc, self.configuration ?? RedirectionConfigurationModel())
        
        return doc
    }
    
    func updateDesign(shapeEye: RedirectionConfigurationModel.QRCodeEyeShapes, shapeOnPixels: RedirectionConfigurationModel.QRCodePixelShapes) -> QRCode.Document {
        var doc = self.fullSize
        RedirectionConfigurationModel.apply(&doc, RedirectionConfigurationModel(shapeOnPixels: shapeOnPixels, shapeEye: shapeEye))

        return doc
    }
    
    mutating func setDesign(shapeEye: RedirectionConfigurationModel.QRCodeEyeShapes, shapeOnPixels: RedirectionConfigurationModel.QRCodePixelShapes) {
        if (self.configuration == nil) {
            self.configuration = RedirectionConfigurationModel()
        }
        
        self.configuration!.shapeEye = shapeEye
        self.configuration!.shapeOnPixels = shapeOnPixels
    }
}
