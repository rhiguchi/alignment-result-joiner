
expect = chai.expect

describe 'hello', ->
  it 'should say hello to person', ->
    expect(hello 'Bob').to.eq 'hello Bob'

  it 'should say "hello world" if no provided', ->
    expect(hello()).to.eq 'hello world'
