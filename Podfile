use_frameworks!
platform :ios, '12.0'

def common_pods
    pod 'SelerioARKit', '~>0.1.6'
end

target 'SelerioARKitBasics' do
    common_pods
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['ENABLE_BITCODE'] = 'NO'
        end
    end
end
