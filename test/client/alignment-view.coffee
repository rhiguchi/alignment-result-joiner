{ AlignmentView } = require 'client'

expect = chai.expect

describe 'AlignmentView', ->
  model = null

  beforeEach ->
    model = new AlignmentView()

  describe 'initialize', ->
    it 'インスタンス化できる', ->
      expect(model).to.be.an.instanceOf AlignmentView
