//
//  FirebaseUserToUserAccountMapper.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/24/20.
//

import Foundation
import Firebase

struct FirebaseUserToUserAccountMapper {
    func map(user: User, claims: [String: Any]) -> UserAccount {
        UserAccount(
            claims: claims.compactMapValues { $0 as? Bool },
            creationDate: "\(Int(user.metadata.creationDate!.timeIntervalSince1970))",
            email: user.email!,
            isVerified: user.isEmailVerified,
            photoURL: user.photoURL,
            uid: user.uid,
            username: user.displayName!
        )
    }
}
