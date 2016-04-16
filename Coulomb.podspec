Pod::Spec.new do |s|
  s.name = "Coulomb"
  s.version = "1.0"
  s.summary = "Network Library built on Multipeer Connectivity."
  s.description = "A zero-config real-time networking library built on Apple's Multipeer Connectivity Framework."
  s.homepage = "https://github.com/SplooshKit/Coulomb"
  s.license = { :type => "MIT", :file => "LISENCE" }

  s.author = "SplooshKit"
  s.platform = :ios
  s.ios.deployment_target = "9.2"

  s.source = { :git => "https://github.com/SplooshKit/Coulomb.git", :tag => s.version }
  s.source_files = "NetworkLib/CoulombNetwork.swift"
end
