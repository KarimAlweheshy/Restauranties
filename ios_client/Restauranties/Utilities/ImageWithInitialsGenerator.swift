//
//  ImageWithInitialsGenerator.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/2/20.
//

import UIKit

final class ImageWithInitialsGenerator {
    func generate(for fullname: String) -> UIImage? {
        let nameParts = fullname.split(separator: " ")
        var text = String(nameParts.first?.first ?? "-".suffix(1)[0])
        if let secondPart = nameParts.last?.first {
            text += String(secondPart)
        }

        let lblNameInitialize = UILabel()
        lblNameInitialize.font = .boldSystemFont(ofSize: 80)
        lblNameInitialize.frame.size = CGSize(width: 160.0, height: 160.0)
        lblNameInitialize.textColor = .darkText
        lblNameInitialize.text = String(text)
        lblNameInitialize.textAlignment = .center
        lblNameInitialize.backgroundColor = .secondarySystemBackground
        lblNameInitialize.layer.cornerRadius = 80.0

        UIGraphicsBeginImageContext(lblNameInitialize.frame.size)
        lblNameInitialize.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
