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
        filePreview.innerText = @result;

        addResult(item.name, item.sequence) for item in parseFromFile(@result)

      reader.readAsText file
    else
      filePreview.innerText = "読み込むことができないファイル形式です： #{file.type}"
  return

clearResultView = ->
  document.getElementById('result-view').innerHtml = ''
  return

addResult = (name, sequence) ->
  resultView = document.getElementById('result-view')

  itemElements = createResultItemElements(name, sequence)
  resultView.appendChild e.cloneNode(true) for e in itemElements

  return

createResultItemElements = (name, sequence) ->
  template = document.getElementById 'result-item-template'
  element = template.cloneNode(true)

  element.querySelector('.name').innerText = name
  element.querySelector('.sequence').innerText = sequence

  return element.children

parseFromFile = (text) ->
  joiner = new Joiner()

  lines = text.split /\r?\n/

  for line in lines
    joiner.append line

  return joiner.build()
