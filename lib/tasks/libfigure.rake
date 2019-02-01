require 'jslibfigure'

namespace :libfigure do
  desc "compile es6 libfigure back into es5 libfigure for asset pipeline etc"
  task :compile do
    print('compiling')
    Dir[Rails.root.join('app/javascript/libfigure/*.js')].each do |javascript_src|
      basename = File.basename(javascript_src)
      text = File.read(javascript_src)
      text = JSLibFigure.filter_out_import_and_export(text)
      text = text.gsub(/^/,'/***/ ')
      File.open(Rails.root.join('app/assets/javascripts/libfigure/',basename), 'w') do |f|
        f.write("// GENERATED FILE - source is in #{javascript_src.inspect} - regenerate this with the rake task\n")
        f.write(text)
        print('.')
      end
    end
    puts 'ok'
  end
end
