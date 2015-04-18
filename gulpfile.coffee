gulp = require 'gulp'
del = require 'del'
coffee = require 'gulp-coffee'
source = require 'vinyl-source-stream'
buffer = require 'vinyl-buffer'
browserify = require 'browserify'
sourcemaps = require 'gulp-sourcemaps'
mocha = require 'gulp-mocha'
gutil = require 'gulp-util'
webserver = require 'gulp-webserver'

require 'coffee-script/register'

gulp.task 'default', ->
  console.log('test')
  return

gulp.task 'clean', (cb) ->
  del 'build', cb

gulp.task 'webserver', ->
  server = webserver
      livereload: true
      # directoryListing: true
      open: true
  gulp.src ['public', 'build/browserify']
    .pipe(server)

gulp.task 'browserify', ->
  browserify
      entries: [
        './src/main.coffee'
      ]
      extensions: ['.coffee', '.js']
      debug: true
    .transform 'coffeeify'
    .bundle()
    .on 'error', gutil.log.bind(gutil, 'Browserify Error')
    .pipe source 'bundle.js'
    .pipe buffer()
    .pipe sourcemaps.init loadMaps: true
    .pipe sourcemaps.write '.'
    .pipe gulp.dest 'build/browserify'

gulp.task 'coffee', ->
  gulp.src 'src/**/*.coffee'
    .pipe coffee()
    .pipe gulp.dest 'build/assets/script'

gulp.task 'watch:test', ['test'], ->
  gulp.watch ['src/**/*.coffee', 'test/**/*.coffee'], ['test']

gulp.task 'test', ->
  gulp.src ['src/**/*.coffee', 'test/**/*.coffee'], read: false
    .pipe mocha reporter: 'spec'
    .on 'error', gutil.log
