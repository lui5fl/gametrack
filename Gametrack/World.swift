//
//  World.swift
//  Gametrack
//
//  Created by Luis Fariña on 08/07/2020.
//  Copyright © 2020 Luis Fariña. All rights reserved.
//

// https://www.pointfree.co/blog/posts/21-how-to-control-the-world
struct World {
    var database: () -> AppDatabase
}

var Current = World(database: { fatalError("Database is uninitialized") })
