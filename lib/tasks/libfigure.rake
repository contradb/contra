require 'jslibfigure'

namespace :libfigure do
  desc "compile es6 libfigure back into es5 libfigure for asset pipeline etc"
  task :compile do
    print('compiling')
    Dir[Rails.root.join('app/javascript/libfigure/*.js')].each do |javascript_src|
      basename_js = File.basename(javascript_src) # e.g. 'define-figure.js'
      basename_es6 = basename_js.delete_suffix('.js') + '.es6'
      text = File.read(javascript_src)
      text = JSLibFigure.strip_import_and_export(text)
      # text = text.gsub(/^/,'/***/ ')
      File.open(Rails.root.join('app/assets/javascripts/libfigure/', basename_es6), 'w') do |f|
        f.write("// GENERATED FILE - source is in #{javascript_src.inspect} - regenerate this with bin/rake libfigure:compile\n")
        f.write(text)
        print('.')
      end
    end
    puts 'ok'
  end
end
