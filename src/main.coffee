
{ SequenceAlignment, FileLoader, AlignmentView } = require './client'

window.onload = ->
  alignment = new SequenceAlignment()

  fileLoader = new FileLoader
    model: alignment
    el: document.getElementById('input-view')

  alignmentView = new AlignmentView
    model: alignment
    el: document.getElementById('alignment-view')

  return
