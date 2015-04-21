Joiner = require './joiner'

window.onload = ->
  fileInput = document.getElementById('file-input');
  filePreview = document.getElementById('file-preview');

  fileInput.addEventListener 'change', (e) ->
    file = fileInput.files[0]
    textType = /text.*/

    clearResultView()

    if file.type.match textType
      reader = new FileReader()

      reader.onload = (e) ->
        filePreview.textContent = @result;

        addResult(item.name, item.sequence) for item in parseFromFile(@result)

      reader.readAsText file
    else
      filePreview.textContent = "読み込むことができないファイル形式です： #{file.type}"
  return

clearResultView = ->
  document.getElementById('result-view').innerHTML = ''
  return

addResult = (name, sequence) ->
  resultView = document.getElementById('result-view')

  itemElements = createResultItemElements(name, sequence)
  resultView.appendChild e.cloneNode(true) for e in itemElements

  return

createResultItemElements = (name, sequence) ->
  template = document.getElementById 'result-item-template'
  element = template.cloneNode(true)

  element.querySelector('.name').textContent = name
  element.querySelector('.sequence').textContent = sequence

  return element.children

parseFromFile = (text) ->
  joiner = new Joiner()

  lines = text.split /\r?\n/

  for line in lines
    joiner.append line

  return joiner.build()
