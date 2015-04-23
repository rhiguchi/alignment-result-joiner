
RESULT_LINE_MATCHER = /^(.+?) +(\d+)(?: +|:)(\S+) +(\d+)$/
LINE_SEPARATOR = /\r?\n/

# アラインメント結果テキストパーサー
class Parser
  constructor: () ->
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
    builder = new Builder

    # 文字列がある行ごとに処理
    lineContent = /^.+$/gm

    while lineResult = lineContent.exec text
      lineResult = @parseLine lineResult[0]
      continue unless lineResult?

      builder.add(lineResult.name, lineResult.sequence)

    return builder.result

# オブジェクトを構築するため
class Builder
  constructor: ->
    @result = {}

  add: (name, sequence) ->
    old = @result[name]

    @result[name] = if old? then old + sequence else sequence
    return

# モジュールの書き出し
module.exports = Parser
