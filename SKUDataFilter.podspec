Pod::Spec.new do |s|
s.name         = "SKUDataFilter"
s.version      = "1.0.1"
s.ios.deployment_target = '7.0'
s.summary      = "A fiter which deal with SKU datas"
#s.description  = <<-DESC
#                 DESC

s.homepage     = "https://github.com/SunriseOYR/SKUDataFilter"
s.license      = { :type => "MIT", :file => "LICENSE" }
s.author             = "Oranges and lemons"
s.social_media_url   = "https://www.jianshu.com/u/80c622a1fe98"
s.source       = { :git => "https://github.com/SunriseOYR/SKUDataFilter.git", :tag => "v#{s.version}" }
s.source_files  = "SKUDataFilter","SKUDataFilter/**/*"
s.public_header_files = 'SKUDataFilter/ORSKUDataFilter.h'
s.requires_arc = true

end