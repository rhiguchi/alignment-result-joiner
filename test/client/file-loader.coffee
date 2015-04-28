{ FileLoader } = require 'client'

expect = chai.expect

describe 'FileLoader', ->
  model = null

  beforeEach ->
    model = new FileLoader()

  describe 'initialize', ->
    it 'インスタンス化できる', ->
      expect(model).to.be.an.instanceOf FileLoader
