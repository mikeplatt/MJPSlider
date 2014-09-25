Pod::Spec.new do |s|

    s.name              = 'MJPSlider'
    s.version           = '0.1.9'
    s.summary           = 'iOS Slider'
    s.homepage          = 'https://github.com/mikeplatt/MJPSlider'
    s.license           = {
        :type => 'MIT',
        :file => 'LICENSE'
    }
    s.author            = {
        'mikeplatt' => 'mikeplatt@inboox.com'
    }
    s.source            = {
        :git => 'https://github.com/mikeplatt/MJPSlider.git',
        :tag => s.version.to_s
    }
    s.source_files      = 'Source/*.{m,h}'
    s.requires_arc      = true
	s.platform 			= :ios, "7.0"

end