Parser = require './parser'
Backbone = require 'backbone'
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

    if file.type.match textType
      reader = new FileReader()
      reader.readAsText file

      setResult = (text) => @setSourceText text
      reader.onload = (e) -> setResult @result
    else
      @setFileTextAsInvalid(file.type)

  getSourceText: -> @get 'sourceText'

  # 結果ファイルを設定します
  setSourceText: (text) ->
    @result = @parser.parse text

    @set
      sourceText: text
      result: @result

  getResult: -> @result ? {}

  # ファイルが不正であったことを記します
  setFileTextAsInvalid: (invalidFileType) ->
    @result = null
    # エラー結果を設定
    @set
      sourceText: "読み込むことができないファイル形式です： #{invalidFileType}"
      result: @result


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
      $template.find('.name').text(name)
      $template.find('.sequence').text(sequence)
      $resultView.append $template.children().clone()

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
