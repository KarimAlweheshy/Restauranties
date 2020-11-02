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
        let placeholderInitial = "-".suffix(1)[0]
        let firstNameInitial = nameParts.first?.first ?? placeholderInitial
        let lastNameInitial = nameParts.last?.first ?? placeholderInitial

        let lblNameInitialize = UILabel()
        lblNameInitialize.font = .boldSystemFont(ofSize: 80)
        lblNameInitialize.frame.size = CGSize(width: 160.0, height: 160.0)
        lblNameInitialize.textColor = .darkText
        lblNameInitialize.text = String(firstNameInitial) + String(lastNameInitial)
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
