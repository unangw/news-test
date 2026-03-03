//
//  Category.swift
//  News
//
//  Created by BTS.id on 02/03/26.
//

import UIKit

class Category {
    static var list: [String] = [
        "general",
        "business",
        "entertainment",
        "health",
        "science",
        "sport",
        "techology"
    ]
    
    static var images: [UIImage] = [
        .imgGeneral,
        .imgBusiness,
        .imgEntertainment,
        .imgHealth,
        .imgScience,
        .imgSport,
        .imgTechnology
    ]
    
    static var descriptions: [String] = [
        "Daily global news and top headlines",
        "Market updates and economic insights",
        "Latest movie, music, and celebrity news",
        "Wellness tips and medical discoveries",
        "Scientific research and innovations",
        "Live scores and major athletic events",
        "New gadgets and software innovations",
    ]
}
