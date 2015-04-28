{ FileLoader } = require 'client'

expect = chai.expect

describe 'FileLoader', ->
  describe 'initialize', ->
    it 'インスタンス化できる', ->
      expect(new FileLoader()).to.be.an.instanceOf FileLoader

    it 'モデルが設定される', ->
      expect(new FileLoader().model).to.be.an 'object'
