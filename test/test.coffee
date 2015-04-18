
expect = require("chai").expect
Joiner = require '../src/joiner'

describe 'Joiner', ->
  sampleLine1 = 'AB618619.seq            1 ATGGCTTCTGT-CAGCTTTC--AGGATCGT---GGCCGCAAACGGGTGCCATTATCCCTC     54'
  sampleLine2 = 'S PDC Illinois121   0 ------------------------------------------------------------------------------------------ 0'
  sampleLine3 = 'AY653206 1 demo      1315 ACAGGAAATTAA                                                   1326'

  describe '#constructor', ->
    it 'インスタンス化できる', ->
      expect(Joiner).to.be.a 'function'
      expect(new Joiner).to.be.an.instanceof Joiner

  describe '#append()', ->
    joiner = null

    beforeEach ->
      joiner = new Joiner
      return

    it '関数が定義されている', ->
      expect(joiner).to.have.property 'append'
      expect(joiner.append).to.be.a 'function'

    it '自身を返す', ->
      expect(joiner.append('')).to.eql joiner
      expect(joiner.append(sampleLine1)).to.eql joiner

  describe '#build()', ->
    joiner = null

    beforeEach ->
      joiner = new Joiner
      return

    it '関数が定義されている', ->
      expect(joiner).to.have.property 'build'
      expect(joiner.build).to.be.a 'function'

    it '読み込んだデータの名前分の要素数の配列が返される', ->
      # 標準状態
      expect(joiner.build()).to.eql []

      joiner.append('AB618619.seq    0 ---- 0')
      expect(joiner.build()).to.have.lengthOf(1)

      joiner.append('AB618622.seq    0 ---- 0')
      expect(joiner.build()).to.have.lengthOf(2)

      joiner.append('AB618622.seq    0 AAAAA 0')
      expect(joiner.build()).to.have.lengthOf(2)

      # 交互
      joiner = new Joiner
      joiner.append('AY539715.seq    0 AAAAA 0')
      joiner.append('AY653206.seq    0 AAAAA 0')
      joiner.append('AY539715.seq    0 AAAAA 0')
      expect(joiner.build()).to.have.lengthOf(2)

    it '読み込んだ行がアラインメント結果と異なる書式のときは無視される', ->
      # 標準状態
      expect(joiner.build()).to.eql []

      joiner.append('')
      joiner.append('data')
      expect(joiner.build()).to.have.lengthOf(0)

    it '配列名が取得できる', ->
      # 標準状態
      expect(joiner.build()).to.eql []

      result = joiner
        .append('AB618619.seq    0 ---- 0')
        .append('AB618622.seq    0 ---- 0')
        .append('S PED CH GDZQ    0 ---- 0')
        .build()

      expect(result[0]).to.have.property 'name', 'AB618619.seq'
      expect(result[1]).to.have.property 'name', 'AB618622.seq'
      expect(result[2]).to.have.property 'name', 'S PED CH GDZQ'

    it '塩基配列が取得できる', ->
      result =　joiner
        .append('AB618619.seq            1 ATGGCTTCTGT-CAGCTTTC--AGGATCGT---GGCCGCAAACGGGTGCCATTATCCCTC     54')
        .append('S PED CH GDZQ    30 ACTTTGTCTCGTTCGAGCAAAGTTTGCTGATGATCTACTCGATTTGCTCACCTTCCCGGGTGCACATCGCTTCTTACATAAACCCACGAG 119')
        .append('AB618619.seq           55 TATGCCCCTCTTAGGGTTACTAATGACAAACCCCTTTCTAAGGTACTTGCAAACAACGCT    114')
        .append('AB618619.seq         1315 ACAGGAAATTAA                                                   1326')
        .build()

      expect(result[0]).to.have.property('sequence',
        'ATGGCTTCTGT-CAGCTTTC--AGGATCGT---GGCCGCAAACGGGTGCCATTATCCCTC' +
        'TATGCCCCTCTTAGGGTTACTAATGACAAACCCCTTTCTAAGGTACTTGCAAACAACGCT' +
        'ACAGGAAATTAA')

      expect(result[1]).to.have.property 'sequence',
        'ACTTTGTCTCGTTCGAGCAAAGTTTGCTGATGATCTACTCGATTTGCTCACCTTCCCGGGTGCACATCGCTTCTTACATAAACCCACGAG'


  describe '#parseSequenceName(data)', ->
    joiner = null

    beforeEach ->
      joiner = new Joiner
      return

    it '関数が定義されている', ->
      expect(joiner).to.have.property 'parseSequenceName'
      expect(joiner.parseSequenceName).to.be.a 'function'

    it '正しい行データでないときは null が返される', ->
      expect(joiner.parseSequenceName('')).to.be.null
      expect(joiner.parseSequenceName('invalid')).to.be.null

    it '行データからシーケンス名が返される', ->
      expect(joiner.parseSequenceName(sampleLine1)).to.eq 'AB618619.seq'
      expect(joiner.parseSequenceName(sampleLine2)).to.eq 'S PDC Illinois121'
      expect(joiner.parseSequenceName(sampleLine3)).to.eq 'AY653206 1 demo'

  describe '#parseSequence(data)', ->
    joiner = null

    beforeEach ->
      joiner = new Joiner
      return

    it '関数が定義されている', ->
      expect(joiner).to.have.property 'parseSequence'
      expect(joiner.parseSequence).to.be.a 'function'

    it '正しい行データでないときは null が返される', ->
      expect(joiner.parseSequence('')).to.be.null
      expect(joiner.parseSequence('invalid')).to.be.null

    it '行データからシーケンスが返される', ->
      expect(joiner.parseSequence(sampleLine1)).to.eq 'ATGGCTTCTGT-CAGCTTTC--AGGATCGT---GGCCGCAAACGGGTGCCATTATCCCTC'
      expect(joiner.parseSequence(sampleLine2)).to.eq '------------------------------------------------------------------------------------------'
      expect(joiner.parseSequence(sampleLine3)).to.eq 'ACAGGAAATTAA'
