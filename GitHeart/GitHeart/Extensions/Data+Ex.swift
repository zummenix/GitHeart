//
//  Data+Ex.swift
//  GitHeart
//
//  Created by Aleksey Kuznetsov on 29.06.2021.
//

import Foundation

extension Data: ByteSizable {
    var byteSize: Int {
        return count
    }
}
