Parser = require './parser'
Backbone = require 'backbone'
_ = require 'underscore'
Backbone.$ = require 'jquery'
FileSaver = require 'file-saver.js'

# アラインメント結果を取り扱うモデル
SequenceAlignment = Backbone.Model.extend
  # 解析結果
  result: null
  # 読み取り器
  parser: null

  initialize: (options) ->
    @parser = options?.parser ? new Parser(true)
    return

  setFile: (file) ->
    textType = /text.*/

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
  sequenceTemplate: _.template("<p><%= name %>\t<%= sequence %></p>");

  events:
    # 結果を保存
    'click button[name=save]': (event) ->
      event.preventDefault()
      @save()

  initialize: (options) ->
    @model ?= new SequenceAlignment

    # モデルの変化によって動作
    @listenTo @model, 'change', => @render()
    return

  render: ->
    console.log 'render', @model
    @$('#file-preview').text(@model.getSourceText())

    # 結果
    $resultView = @$('#result-view')
    $resultView.html('')

    $template = $('#result-item-template').clone()

    for name, sequence of @model.getResult()
      view = @sequenceTemplate
        name: name
        sequence: sequence

      $resultView.append view

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
