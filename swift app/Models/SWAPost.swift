//
//  SWAPost.swift
//  swift app
//
//  Created by Carlos Knopel on 3/26/20.
//  Copyright © 2020 Carlos Knopel. All rights reserved.
//

import RealmSwift

class SWAPost: Object {
    @objc dynamic var postId: String?
    @objc dynamic var postTitle: String?
    @objc dynamic var postDate: String?
    @objc dynamic var postAuthor: String?
    @objc dynamic var postUrl: String?
}
