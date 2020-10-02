// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LNPopupUI",
	platforms: [
		.iOS(.v13),
		.macOS(.v10_15)
	],
    products: [
        .library(
            name: "LNPopupUI",
			type: .dynamic,
            targets: ["LNPopupUI"]),
		.library(
			name: "LNPopupUI-Static",
			type: .static,
			targets: ["LNPopupUI"]),
    ],
    dependencies: [
//		.package(path: "../LNPopupController")
		.package(url: "https://github.com/LeoNatan/LNPopupController.git", from: Version(stringLiteral: "2.10.16"))
    ],
    targets: [
        .target(
            name: "LNPopupUI",
			dependencies: ["LNPopupController-Static"],
			exclude: [
				"LNPopupUIExample",
				"Supplements"
			]),
		
    ]
)
