
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

    it '配列が返される', ->
      expect(joiner.build()).to.eql []

    it '読み込んだ配列情報からシーケンスを返す', ->
      joiner.append('S PED CH GDZQ    30 ACTTTGTCTCGTTCGAGCAAAGTTTGCTGATGATCTACTCGATTTGCTCACCTTCCCGGGTGCACATCGCTTCTTACATAAACCCACGAG 119')

      result = joiner.build()
      expect(result).to.have.lengthOf(1)
      expect(result[0]).to.have.property 'name', 'S PED CH GDZQ'
      expect(result[0]).to.have.property 'sequence', 'ACTTTGTCTCGTTCGAGCAAAGTTTGCTGATGATCTACTCGATTTGCTCACCTTCCCGGGTGCACATCGCTTCTTACATAAACCCACGAG'

      joiner = new Joiner
      joiner.append('AB618619.seq            1 ATGGCTTCTGT-CAGCTTTC--AGGATCGT---GGCCGCAAACGGGTGCCATTATCCCTC     54')
      joiner.append('AB618619.seq           55 TATGCCCCTCTTAGGGTTACTAATGACAAACCCCTTTCTAAGGTACTTGCAAACAACGCT    114')
      joiner.append('AB618619.seq         1315 ACAGGAAATTAA                                                   1326')

      result = joiner.build()
      expect(result).to.have.lengthOf(1)
      expect(result[0]).to.have.property 'name', 'AB618619.seq'
      expect(result[0]).to.have.property('sequence',
        'ATGGCTTCTGT-CAGCTTTC--AGGATCGT---GGCCGCAAACGGGTGCCATTATCCCTC' +
        'TATGCCCCTCTTAGGGTTACTAATGACAAACCCCTTTCTAAGGTACTTGCAAACAACGCT' +
        'ACAGGAAATTAA')


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
