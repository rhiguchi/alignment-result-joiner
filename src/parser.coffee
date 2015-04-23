
RESULT_LINE_MATCHER = /^(.+?) +(\d+)(?: +|:)(\S+) +(\d+)$/
LINE_SEPARATOR = /\r?\n/

# アラインメント結果テキストパーサー
class Parser
  # @param replaceDot ドットを塩基に置き換えます
  constructor: (@replaceDot) ->
    @replaceDot ?= false
    return

  # 行から名前と配列を取り出して返します
  parseLine: (line) ->
    result = RESULT_LINE_MATCHER.exec(line)
    return null unless result?
    return {
      name: result[1]
      sequence: result[3]
    }

  # テキストを行ごとに分割して名前と配列を取り出します
  parse: (text) ->
    builder = new Builder(@replaceDot)

    # 文字列がある行ごとに処理
    lineContent = /^.+$/gm

    while lineResult = lineContent.exec text
      lineResult = @parseLine lineResult[0]
      continue unless lineResult?

      builder.add(lineResult.name, lineResult.sequence)


    return builder.build()

# オブジェクトを構築するため
class Builder
  # @param replaceDot ドットを塩基に置き換えます
  constructor: (@replaceDot) ->
    @result = {}
    # ドット置き換えの基準となる最初の配列
    @firstSequence = null

  build: ->
    data = {}
    replacer = @getReplacer()

    for name, sequence of @result
      sequence = replacer.replace sequence if @replaceDot
      data[name] = sequence

    return data

  # 配列を追加
  add: (name, sequence) ->
    @firstSequence ?= name

    old = @result[name]
    @result[name] = if old? then old + sequence else sequence
    return

  # 置き換えオブジェクトを返します
  getReplacer: -> return new DotReplacer(@result[@firstSequence] ? '')

# ドットを置き換える
class DotReplacer
  # @param baseSequence 置き換え基準の配列
  constructor: (@baseSequence) ->
    return

  # 配列中のドットを置き換えた文字列を返します
  replace: (target) ->
    # ドットが含まれているものだけ処理する
    return target if target.indexOf('.') is -1

    replaceBase = @baseSequence ? ''
    # 構築していく文字列
    result = ""

    for char, i in target
      char = replaceBase[i] if char is '.' and replaceBase.length > i
      result += char

    return result

# モジュールの書き出し
module.exports = Parser
