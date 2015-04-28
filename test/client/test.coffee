
{ SequenceAlignment, FileLoader, AlignmentView } = require 'client'

expect = chai.expect

describe 'SequenceAlignment', ->
  describe 'initialize', ->
    it 'インスタンスできる', ->
      expect(new SequenceAlignment).to.be.an.instanceOf SequenceAlignment

  describe '.FileLoader', ->
    it 'クラスが定義されている', ->
      expect(FileLoader).to.be.a 'function'

  describe '.AlignmentView', ->
    it 'クラスが定義されている', ->
      expect(AlignmentView).to.be.a 'function'
