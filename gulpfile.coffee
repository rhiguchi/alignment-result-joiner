gulp = require 'gulp'
mocha = require 'gulp-mocha'
gutil = require 'gulp-util'
webserver = require 'gulp-webserver'

require 'coffee-script/register'

gulp.task 'default', ->
  console.log('test')
  return

gulp.task 'webserver', ->
  server = webserver
      livereload: true
      # directoryListing: true
      open: true
  gulp.src('public')
    .pipe(server)

gulp.task 'watch:test', ['test'], ->
  gulp.watch ['src/**/*.coffee', 'test/**/*.coffee'], ['test']

gulp.task 'test', ->
  gulp.src ['src/**/*.coffee', 'test/**/*.coffee'], read: false
    .pipe mocha reporter: 'spec'
    .on 'error', gutil.log
