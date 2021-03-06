Parser = require './parser'
Backbone = require 'backbone'
_ = require 'underscore'
Backbone.$ = require 'jquery'
FileSaver = require 'file-saver.js'
sprintf = require('sprintf').sprintf

# アラインメント結果を取り扱うモデル
SequenceAlignment = Backbone.Model.extend
  defaults:
    sourceText: ''

  # 解析結果
  result: null
  # 読み込んだファイル名
  fileName: null
  # 読み取り器
  parser: null

  initialize: (options) ->
    @parser = options?.parser ? new Parser(true)
    return

  setFile: (file) ->
    textType = /text.*/
    @fileName = file.name

    # テキストファイルを設定する
    setResult = (text) => @setSourceText text

    if textType.test file.type
      reader = new FileReader()
      reader.readAsText file
      reader.onload = (e) -> setResult @result
    else
      setResult null

  getSourceText: -> @get 'sourceText'

  # 結果ファイルを設定します
  setSourceText: (text) ->
    @result = if text? then @parser.parse text else null

    # ファイルが不正のときはそのエラーをテキストとする
    sourceText = text ? "読み込むことができないファイル形式です"

    @set
      sourceText: sourceText
      result: @result

  getResult: -> @result ? {}


# ファイルを読み込んでモデルに格納
FileLoader = Backbone.View.extend
  events:
    # 読み込むファイルを設定
    'change input[type=file]': (event) ->
      @model.setFile event.currentTarget.files[0]
      return

    # 領域のどこにドロップしてもファイル適用
    'drop': (e) ->
      event = e.originalEvent
      event.stopPropagation()
      event.preventDefault()

      @model.setFile event.dataTransfer.files[0]
      return

    'dragover': (e) ->
      event = e.originalEvent
      event.preventDefault()
      event.dropEffect = 'copy'
      return

  initialize: (options) ->
    @model ?= new SequenceAlignment
    return


# アライメント解析結果を描画する
AlignmentView = Backbone.View.extend
  sequenceTemplate: _.template "<p><%= name %>\t<%= sequence %></p>\n"
  headerTemplate: _.template "<p>read file\t<%= fileName %></p>\n<p>date\t<%= date %></p>"
  # 変換後のデータ出力領域
  $resultView: null

  events:
    # 結果を保存
    'click button[name=save]': (event) ->
      event.preventDefault()
      @save()

  initialize: (options) ->
    @model ?= new SequenceAlignment

    # モデルの変化によって動作
    @listenTo @model, 'change', => @render()

    # 利用する要素の初期化
    @$resultView = @$('#result-view')
    return

  render: ->
    # 「変換前」の描画
    @$('#file-preview').text(@model.getSourceText())

    # 「変換後」の描画
    @renderResultView()

    # 保存ボタンの有効性
    @$('button[name=save]').attr 'disabled', !@model.result?

  renderResultView: ->
    # 属性を結果領域に追加
    appnedElement = (element) => @$resultView.append element

    # シーケンスを追加
    appendSequence = (name, sequence) =>
      appnedElement @sequenceTemplate
        name: name
        sequence: sequence
      return

    # 以前の出力を消去
    @$resultView.html('')

    appnedElement @headerTemplate
      fileName: @model.fileName
      date: getFormattedCurrentDate('%04d/%02d/%02d')

    # 結果のヘッダー
    appnedElement """<br>\n\n<p>name\tsequence</p>\n"""
    # 結果出力
    appendSequence(name, sequence) for name, sequence of @model.getResult()

    return

  # 結果をファイルに保存する
  save: ->
    content = @$('#result-view').text()
    data = new Blob([content], {type: "text/plain;charset=utf-8"})
    fileName = 'MAtoExcel_result' + getFormattedCurrentDate('%04d%02d%02d') + '.txt'

    FileSaver.saveAs(data, fileName)

# 日付を指定したフォーマットの文字列で返す
getFormattedCurrentDate = (format) ->
  date = new Date()
  sprintf format, date.getFullYear(), date.getMonth() + 1, date.getDate()

module.exports =
  SequenceAlignment: SequenceAlignment
  FileLoader: FileLoader
  AlignmentView: AlignmentView
