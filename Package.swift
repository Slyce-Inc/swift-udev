// swift-tools-version:5.0

import PackageDescription

let package = Package(
  name: "Udev",
  products: [
    .library(name: "Udev", targets: ["Udev"]),
  ],
  dependencies: [
  ],
  targets: [
    .target(
      name: "Udev",
      dependencies: ["Clibudev"]
    ),
    .systemLibrary(
      name: "Clibudev", 
      pkgConfig: "libudev", 
      providers: [
        .apt(["libudev-dev"])
      ]),    
  ]
)
