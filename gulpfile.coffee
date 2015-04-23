gulp = require 'gulp'
del = require 'del'
coffee = require 'gulp-coffee'
source = require 'vinyl-source-stream'
buffer = require 'vinyl-buffer'
browserify = require 'browserify'
watchify = require 'watchify'
sourcemaps = require 'gulp-sourcemaps'
mocha = require 'gulp-mocha'
gutil = require 'gulp-util'
webserver = require 'gulp-webserver'
zip = require 'gulp-zip'

require 'coffee-script/register'

path =
  build: 'build'
  dist: 'build/dist'
  bower: 'build/bower'

gulp.task 'default', ['run']

# ライブリロードを行う開発用サーバー
gulp.task 'run', ['bower', 'watchify'], ->
  gulp.src [
      path.bower,
      'build/browserify'
      'public'
    ]
    .pipe webserver
      livereload: true
      open: true

gulp.task 'clean', (cb) ->
  del 'build', cb

# 成果物の表示
gulp.task 'start', ['dist'], ->
  gulp.src path.dist
    .pipe webserver
      open: true

# 成果物パッケージ生成
gulp.task 'package', ['dist'], ->
  gulp.src "#{path.dist}/**/*"
    .pipe zip 'app.zip'
    .pipe gulp.dest path.build

# 成果物生成
gulp.task 'dist', ['browserify'], ->
  gulp.src [
      'build/bower/**/*'
      'build/browserify/**/*'
      'public/**/*'
    ]
    .pipe gulp.dest path.dist


gulp.task 'browserify', -> bundleBrowserify createBrowserifyBase()

# 基本設定された Browserify
createBrowserifyBase = ->
  browserifyBase = browserify
    entries: [
      './src/main.coffee'
    ]
    extensions: ['.coffee', '.js']
    debug: true
    # watchify 用引数
    cache: {}
    packageCache: {}

# バンドル処理を追加
bundleBrowserify = (b) ->
  b.bundle()
    .on 'error', gutil.log.bind(gutil, 'Browserify Error')
    .pipe source 'bundle.js'
    .pipe buffer()
    .pipe sourcemaps.init loadMaps: true
    .pipe sourcemaps.write '.'
    .pipe gulp.dest 'build/browserify'

#
watchifyBase = watchify createBrowserifyBase()

# バンドル処理
gulp.task 'watchify', watchifyBundler = ->
  bundleBrowserify watchifyBase

watchifyBase.on 'update', watchifyBundler
watchifyBase.on 'log', gutil.log

# bower ライブラリの自動取得
gulp.task 'bower', () ->
  bower = require 'bower'
  mainBowerFiles = require 'main-bower-files'

  bower.commands.install().on 'end', ->
    gulp.src mainBowerFiles()
      .pipe gulp.dest path.bower

gulp.task 'coffee', ->
  gulp.src 'src/**/*.coffee'
    .pipe coffee()
    .pipe gulp.dest 'build/assets/script'

gulp.task 'watch:test', ['test'], ->
  gulp.watch ['src/**/*.coffee', 'test/**/*.coffee'], ['test']

gulp.task 'test', ->
  gulp.src ['test/*.coffee'], read: false
    .pipe mocha reporter: 'spec'
    .on 'error', gutil.log
