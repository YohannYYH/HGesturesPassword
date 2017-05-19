
Pod::Spec.new do |s|

  s.name         = "HGesturesPassword"
  s.version      = "0.0.2"
  s.summary      = "yyh 手势密码"
  s.description  = "yyh 手势密码，创建、验证"

  s.homepage     = "https://github.com/YohannYYH/HGesturesPassword"
  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author    = "YohannYYH"

  s.platform     = :ios, "7.0"

  s.source       = { :git => "https://github.com/YohannYYH/HGesturesPassword.git", :tag => "#{s.version}" }
  s.source_files  = "HGesturesPassword/*.{h,m}"
end
