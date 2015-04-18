
PARSE_NAME = /^(.+?) +(\d+) +(\S+) +(\d+)$/

class AlignmentLineJoiner
  constructor: () ->
    return

  # 結果行データから配列名を取り出して返します
  #
  # @return 配列名、もしくは null
  parseSequenceName: (line) ->
    result = PARSE_NAME.exec(line)
    return null unless result?
    return result[1]

module.exports = AlignmentLineJoiner
