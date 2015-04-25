Parser = require './parser'
Backbone = require 'backbone'
_ = require 'underscore'
Backbone.$ = require 'jquery'
FileSaver = require 'file-saver.js'

# アラインメント結果を取り扱うモデル
SequenceAlignment = Backbone.Model.extend
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

    if file.type.match textType
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

    # ファイル名と日付をヘッダーとして出力
    date = new Date()
    dateString = "#{date.getFullYear()}/#{date.getMonth() + 1}/#{date.getDate()}"

    appnedElement @headerTemplate
      fileName: @model.fileName
      date: dateString

    # 結果のヘッダー
    appnedElement """<p>&nbsp;</p>\n<p>name\tsequence</p>\n"""
    # 結果出力
    appendSequence(name, sequence) for name, sequence of @model.getResult()

    return

  # 結果をファイルに保存する
  save: ->
    content = @$('#result-view').text()
    data = new Blob([content], {type: "text/plain;charset=utf-8"})
    FileSaver.saveAs(data, 'result.txt')


module.exports =
  SequenceAlignment: SequenceAlignment
  FileLoader: FileLoader
  AlignmentView: AlignmentView
