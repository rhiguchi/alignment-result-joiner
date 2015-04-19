Joiner = require './joiner'
console.log 'Joiner', Joiner

window.onload = ->
  fileInput = document.getElementById('file-input');
  filePreview = document.getElementById('file-preview');

  fileInput.addEventListener 'change', (e) ->
    file = fileInput.files[0]
    textType = /text.*/

    if file.type.match textType
      reader = new FileReader()

      reader.onload = (e) -> filePreview.innerText = reader.result;

      reader.readAsText file
    else
      filePreview.innerText = "読み込むことができないファイル形式です： #{file.type}"
  return

