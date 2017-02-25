//
//  Result.swift
//  VideoCamera
//
//  Created by Alfred Hanssen on 2/25/17.
//  Copyright © 2017 Alfie Hanssen. All rights reserved.
//

import Foundation

enum Result
{
    case success
    case failure(error: Error)
}

typealias ResultClosure = (_ result: Result) -> Void

