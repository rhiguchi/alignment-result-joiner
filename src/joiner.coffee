
PARSE_NAME = /^(.+?) +(\d+) +(\S+) +(\d+)$/

class AlignmentLineJoiner
  constructor: () ->
    # 名前をキーにした配列のマップ
    @sequenceMap = {}
    return

  # 解析元となるデータ行を加えます
  append: (line) ->
    name = @parseSequenceName(line)
    return @ unless name?

    sequence = @parseSequence(line)

    current = @sequenceMap[name]

    @sequenceMap[name] = if current? then current + sequence else sequence

    return @

  # 構築したシーケンスの配列を返します
  build: ->
    result = for name, sequence of @sequenceMap
      { name: name, sequence: sequence }
    return result

  # 結果行データから配列名を取り出して返します
  #
  # @return 配列名、もしくは null
  parseSequenceName: (line) ->
    result = PARSE_NAME.exec(line)
    return null unless result?
    return result[1]

  # 結果行データから配列を取り出して返します
  #
  # @return 配列名、もしくは null
  parseSequence: (line) ->
    result = PARSE_NAME.exec(line)
    return null unless result?
    return result[3]

module.exports = AlignmentLineJoiner
