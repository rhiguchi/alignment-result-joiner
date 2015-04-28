
{ SequenceAlignment, FileLoader, AlignmentView } = require '../../src/client'

expect = chai.expect

describe 'Client', ->
  describe '.SequenceAlignment', ->
    it 'クラスが定義されている', ->
      expect(SequenceAlignment).to.be.a 'function'

  describe '.FileLoader', ->
    it 'クラスが定義されている', ->
      expect(FileLoader).to.be.a 'function'

  describe '.AlignmentView', ->
    it 'クラスが定義されている', ->
      expect(AlignmentView).to.be.a 'function'
