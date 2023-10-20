// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "LNPopupUI",
	platforms: [
		.iOS(.v14),
		.macCatalyst(.v14)
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
        .package(url: "https://github.com/LeoNatan/LNPopupController.git", from: Version(stringLiteral: "2.15.24"))
    ],
    targets: [
        .target(
            name: "LNPopupUI",
			dependencies: [
				.product(name: "LNPopupController-Static", package: "LNPopupController")
			])
    ]
)
