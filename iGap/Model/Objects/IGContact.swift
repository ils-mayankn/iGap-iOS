/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the RooyeKhat Media Company - www.RooyeKhat.co
 * All rights reserved.
 */

import RealmSwift
import Foundation

class IGContact: Object {

    dynamic var phoneNumber: String?
    dynamic var firstName: String?
    dynamic var lastName: String?
    dynamic var user: IGRegisteredUser?
    
    override static func primaryKey() -> String {
        return "phoneNumber"
    }
    
    convenience init(phoneNumber: String, firstName: String?, lastName: String?) {
        self.init()
        self.phoneNumber = phoneNumber
        self.firstName = firstName
        self.lastName = lastName
    }
}
