
expect = require("chai").expect
Joiner = require '../src/joiner'

describe 'Joiner', ->
  describe '#constructor', ->
    it 'インスタンス化できる', ->
      expect(Joiner).to.be.a 'function'
      expect(new Joiner).to.be.an.instanceof Joiner
