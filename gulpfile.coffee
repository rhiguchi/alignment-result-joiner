gulp = require 'gulp'
mocha = require 'gulp-mocha'
gutil = require 'gulp-util'

gulp.task 'default', ->
  console.log('test')
  return

gulp.task 'watch:test', ['test'], ->
  gulp.watch ['src/**/*.coffee', 'test/**/*.coffee'], ['test']

gulp.task 'test', ->
  gulp.src 'test/**/*.coffee', read: false
    .pipe mocha reporter: 'spec', compilers: 'coffee:coffee-script/register'
    .on 'error', gutil.log
