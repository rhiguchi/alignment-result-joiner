
expect = require("chai").expect
Parser = require '../src/parser'

describe 'class Parser', ->
  describe '#constructor()', ->
    it 'インスタンス化できる', ->
      expect(Parser).to.be.a 'function'
      expect(new Parser).to.be.an.instanceof Parser

  describe '#parseLine(line)', ->
    parseLine = (text) -> new Parser().parseLine(text)

    sampleLine1 = "AB618619.seq            1 ATGGCTTCTGT-CAGCTTTC--AGGATCGT---GGCCGCAAACGGGTGCCATTATCCCTC     54"
    sampleLine2 = "JN547228 600-10 del.seq      1 ATGGCTTCTGTCAGTTTTCAGGATCGTGGCCGCAAACGGGTGCCATTATCCCTCTATGCC     60"
    sampleLine3 = "DQ072726               1:ATGGCTTCTGTCAGCTTTCAGGATCGTGGCCGCAAACGAGTGCCCTTATCTCTTTATGCCCCTCTTAGGGTTACTAATGACAAACCCCTT 90"
    sampleLine4 = "JN547228 600-10 del 1241:T..........................................................C...C............               1316"

    it '不正な列では null が返される', ->
      expect(parseLine("")).to.be.null
      expect(parseLine("[GENETYX-MAC: Multiple Alignment]")).to.be.null
      expect(parseLine("Date        : 2015. 4.20")).to.be.null
      expect(parseLine("                               ***.************")).to.be.null

    it '名前が正しく得られる', ->
      expect(parseLine(sampleLine1)).to.have.property 'name', 'AB618619.seq'
      expect(parseLine(sampleLine2)).to.have.property 'name', 'JN547228 600-10 del.seq'
      expect(parseLine(sampleLine3)).to.have.property 'name', 'DQ072726'
      expect(parseLine(sampleLine4)).to.have.property 'name', 'JN547228 600-10 del'

    it '配列が正しく得られる', ->
      expect(parseLine(sampleLine1)).to.have.property 'sequence', 'ATGGCTTCTGT-CAGCTTTC--AGGATCGT---GGCCGCAAACGGGTGCCATTATCCCTC'
      expect(parseLine(sampleLine2)).to.have.property 'sequence', 'ATGGCTTCTGTCAGTTTTCAGGATCGTGGCCGCAAACGGGTGCCATTATCCCTCTATGCC'
      expect(parseLine(sampleLine3)).to.have.property 'sequence', 'ATGGCTTCTGTCAGCTTTCAGGATCGTGGCCGCAAACGAGTGCCCTTATCTCTTTATGCCCCTCTTAGGGTTACTAATGACAAACCCCTT'
      expect(parseLine(sampleLine4)).to.have.property 'sequence', 'T..........................................................C...C............'

  describe '#parse', ->
    parse = null

    beforeEach ->
      parse = (text) -> new Parser().parse(text)

    text1 = """
      [GENETYX-MAC: Multiple Alignment]
      AB618619.seq            1 ATGGCTTCTGT-CAGCTTTC--AGGATCGT---GGCCGCAAACGGGTGCCATTATCCCTC     54
      AY653206_demo2.seq      1 ATGGCTTCTGT-CAGTTTTC---GGATCGT---GGCCGCAAACGGGTGCCATTATCCCTC     53
                                ........... ... ....  ........   ...***********************.

      AB618619.seq         1315 ACAGGAAATTAA                                                   1326
      AY653206_demo2.seq   1314 ACAGGAAATTAA                                                   1326
                                ............
    """.replace /\As+/g, ""

    text2 = """
      DQ072726               1:ATGGCTTCTGTCAGCTTTCAGGATCGTGGCCGCAAACGAGTGCCCTTATCTCTTTATGCCCCTCTTAGGGTTACTAATGACAAACCCCTT 90
      EF185992               1:......................................G.....A........C.............................G...... 90
      JN547228 600-10 del    1:..............T.......................G.....A.....C..C.................................... 90
                               **************.**.********..*..*...***.*****.*****.**.*****************************.******

      DQ072726            1251:GGAATGGGACACAGCTGTTGATGGTGGTGACACGGCCGTTGAAATTATCAACGAGATCTTCGATACAGGAAATTAA               1326
      EF185992            1251:..............................T.............................................               1326
      JN547228 600-10 del 1241:T..........................................................C...C............               1316
                               .*****************************.********..**.*.*************.***.************
    """.replace /\As+/g, ""

    it '空の文字列では空のオブジェクトが返される', ->
      expect(parse('')).to.be.empty

    it '名前が配列のオブジェクトに格納される', ->
      result = parse text1
      expect(result).to.not.empty
      expect(result).to.have.property 'AB618619.seq'
      expect(result).to.have.property 'AY653206_demo2.seq'

      result = parse text2
      expect(result).to.not.empty
      expect(result).to.have.property 'DQ072726'
      expect(result).to.have.property 'EF185992'

    it '配列が正しく得られる', ->
      result = parse text1
      expect(result).to.have.property 'AB618619.seq',
        "ATGGCTTCTGT-CAGCTTTC--AGGATCGT---GGCCGCAAACGGGTGCCATTATCCCTC" +
        "ACAGGAAATTAA"
      expect(result).to.have.property 'AY653206_demo2.seq',
        "ATGGCTTCTGT-CAGTTTTC---GGATCGT---GGCCGCAAACGGGTGCCATTATCCCTC" +
        "ACAGGAAATTAA"

      result = parse text2
      expect(result).to.have.property 'DQ072726',
        "ATGGCTTCTGTCAGCTTTCAGGATCGTGGCCGCAAACGAGTGCCCTTATCTCTTTATGCCCCTCTTAGGGTTACTAATGACAAACCCCTT" +
        "GGAATGGGACACAGCTGTTGATGGTGGTGACACGGCCGTTGAAATTATCAACGAGATCTTCGATACAGGAAATTAA"
      expect(result).to.have.property 'EF185992',
        "......................................G.....A........C.............................G......" +
        "..............................T............................................."

    it 'ドットを塩基に置き換えた配列が得られる', ->
      parse = (text) -> new Parser(true).parse(text)

      result = parse text2
      expect(result['EF185992']).to
        .eq "ATGGCTTCTGTCAGCTTTCAGGATCGTGGCCGCAAACGGGTGCCATTATCTCTCTATGCCCCTCTTAGGGTTACTAATGACAAGCCCCTT" +
            "GGAATGGGACACAGCTGTTGATGGTGGTGATACGGCCGTTGAAATTATCAACGAGATCTTCGATACAGGAAATTAA"

      expect(result['JN547228 600-10 del']).to
        .eq "ATGGCTTCTGTCAGTTTTCAGGATCGTGGCCGCAAACGGGTGCCATTATCCCTCTATGCCCCTCTTAGGGTTACTAATGACAAACCCCTT" +
            "TGAATGGGACACAGCTGTTGATGGTGGTGACACGGCCGTTGAAATTATCAACGAGATCTCCGACACAGGAAATTAA"

