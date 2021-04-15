Gem::Specification.new do |s|
  s.name = 'generator'
  s.version = '0.1.0'
  s.summary = 'Generate an info image to be displayed on an e-Paper frame.'
  s.authors = ['Mui Kai En']
  s.email = 'muikaien1@gmail.com'
  s.files = Dir["{lib}/**/*.rb", "LICENSE", "template.bmp"]
  s.license = 'MIT'
  s.add_dependency 'rmagick', '~> 4.2'
  s.add_dependency 'google-apis-calendar_v3', '~>0.5.0'
end
