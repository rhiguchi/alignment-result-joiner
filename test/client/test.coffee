
{ SequenceAlignment, FileLoader, AlignmentView } = require 'client'

expect = chai.expect

describe 'SequenceAlignment', ->
  model = null

  beforeEach ->
    model = new SequenceAlignment()

  describe 'initialize', ->
    it 'インスタンス化できる', ->
      expect(model).to.be.an.instanceOf SequenceAlignment

    it 'パーサーが設定される', ->
      expect(model.parser).to.be.an 'object'


  describe '#getSourceText', ->
    it 'sourceText プロパティの値が返される', ->
      expect(model.getSourceText()).to.eq ''

      model.set 'sourceText', 'source-text'
      expect(model.getSourceText()).to.eq 'source-text'


  describe '#setSourceText', ->
    sampleSourceText1 = """
      AB618619.seq            1 ATGGCTTCTGT-CAGCTTTC--AGGATCGT---GGCCGCAAACGGGTGCCATTATCCCTC     54
      AB618622.seq            1 ATGGCTTCTGT-CAGCTTTC--AGGATCGT---GGCCGCAAACGGGTGCCATTATCCCTC     54

      AB618619.seq         1315 ACAGGAAATTAA                                                   1326
      AB618622.seq         1315 ACAGGAAATTAA                                                   1326
    """

    sampleSourceText2 = """
      DQ072726               1:ATGGCTTCTGTCAGCTTTCAGGATCGTGGCCGCAAACGAGTGCCCTTATCTCTTTATGCCCCTCTTAGGGTTACTAATGACAAACCCCTT 90
      JN547228 600+10 add    1:..............T.......................G.....A.....C..C.................................... 90

      DQ072726            1251:GGAATGGGACACAGCTGTTGATGGTGGTGACACGGCCGTTGAAATTATCAACGAGATCTTCGATACAGGAAATTAA               1326
      JN547228 600+10 add 1261:T..........................................................C...C............               1336
    """

    it 'ソーステキストが設定される', ->
      model.setSourceText(sampleSourceText1)
      expect(model.get 'sourceText').to.eq sampleSourceText1

      model.setSourceText(sampleSourceText2)
      expect(model.get 'sourceText').to.eq sampleSourceText2

    it '結果が設定される', ->
      model.setSourceText(sampleSourceText1)
      expect(model.get 'result').to.have.property 'AB618619.seq',
        "ATGGCTTCTGT-CAGCTTTC--AGGATCGT---GGCCGCAAACGGGTGCCATTATCCCTCACAGGAAATTAA"

      model.setSourceText(sampleSourceText2)
      expect(model.get 'result').to.have.property 'JN547228 600+10 add'

    it 'change イベントが送出される', (done) ->
      model.on 'change', ->
        expect(@get 'sourceText').to.not.be.empty
        expect(@get 'result').to.not.be.empty

        done()

      model.setSourceText(sampleSourceText1)

  describe '#getResult', ->
    it 'result 属性値が返される', ->
      # 初期値は空オブジェクト
      expect(model.getResult()).to.eql {}

      model.result = { 'name': 'sequence' }
      expect(model.getResult()).to.eql { 'name': 'sequence' }

      # null 値だと空オブジェクトが返される
      model.result =  null
      expect(model.getResult()).to.eql {}


  describe '.FileLoader', ->
    it 'クラスが定義されている', ->
      expect(FileLoader).to.be.a 'function'

  describe '.AlignmentView', ->
    it 'クラスが定義されている', ->
      expect(AlignmentView).to.be.a 'function'
