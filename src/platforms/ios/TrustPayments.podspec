Pod::Spec.new do |s|
  s.name             = "TrustPayments"
  s.version          = "2.5.0"
  s.summary          = "Authorise payments through Trust Payments."
  s.description      = <<-DESC
                       The Trust Payments library will allow you to tokenize and authorise payments in your iOS app.
  DESC
  s.homepage         = "https://www.trustpayments.com"
  s.documentation_url = "https://docs.trustpayments.com"
  s.screenshots      = "https://gitlab.com/trustpayments-public/mobile-sdk/ios/-/raw/master/Screenshots/dropInViewController.png", "https://gitlab.com/trustpayments-public/mobile-sdk/ios/-/raw/master/Screenshots/cardinalCommerce.png"
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = "Trust Payments"
  s.source           = { :git => "https://gitlab.com/trustpayments-public/mobile-sdk/ios.git", :tag => s.version.to_s }
  # s.social_media_url = ""

  s.platform         = :ios, "11.0"
  s.swift_version = "5.0"

  s.default_subspecs = %w[Core UI]

  s.subspec "Core" do |s|
    s.source_files   = "TrustPayments/TrustPaymentsCore/**/*.{h,swift}"
    s.resources = ["TrustPayments/TrustPaymentsCore/Resources/**/*.{json}"]
    s.public_header_files = "TrustPayments/TrustPaymentsCore/*.{h}"
    s.header_dir = "TrustPaymentsCore"
    s.dependency "TrustPayments/3DSecure"
    s.dependency "TrustPayments/Card"
    s.dependency "TrustKit", '1.6.4'
    s.dependency "Sentry", '7.9.0'
    s.dependency "SeonSDK", '3.0.6'
  end

  s.subspec "UI" do |s|
    s.source_files   = "TrustPayments/TrustPaymentsUI/**/*.{h,swift}"
    s.resources = ["TrustPayments/TrustPaymentsUI/Resources/**/*.{xcassets}"]
    s.public_header_files = "TrustPayments/TrustPaymentsUI/*.{h}"
    s.header_dir = "TrustPaymentsUI"
    s.dependency "TrustPayments/3DSecure"
    s.dependency "TrustPayments/Core"
    s.dependency "TrustPayments/Card"
  end

  s.subspec "3DSecure" do |s|
    s.source_files   = "TrustPayments/TrustPayments3DSecure/**/*.{h,swift}"
    s.public_header_files = "TrustPayments/TrustPayments3DSecure/*.{h}"
    s.vendored_frameworks = 'TrustPayments/Cardinal/2.2.5/CardinalMobile.xcframework'
    s.header_dir = "TrustPayments3DSecure"
  end

  s.subspec "Card" do |s|
    s.source_files   = "TrustPayments/TrustPaymentsCard/**/*.{h,swift}"
    s.resources = ["TrustPayments/TrustPaymentsCard/Resources/**/*.{xcassets}"]
    s.public_header_files = "TrustPayments/TrustPaymentsCard/*.{h}"
    s.header_dir = "TrustPaymentsCard"
  end
end
