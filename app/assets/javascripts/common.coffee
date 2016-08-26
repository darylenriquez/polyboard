deleteButtonClicked = (event) ->
  $(this).parent().remove()

fomulateFlashNotice = (index, element) ->
  $.notify $(element).text(),
     style: 'bulma'
     className: $(element).data('key')

  $(element).remove()

$.notify.addStyle 'bulma', 
  html: "<div class='notification'><button class='delete'></button><span data-notify-text/></div>",
  classes: 
    base:
      "background-color": "#f5f7fa"
      "color": "#69707a"
    alert:
      "background-color": "#42afe3"
      "color": "white"
    notice:
      "background-color": "#f5f7fa"
      "color": "#69707a"
    primary:
      "background-color": "#1fc8db"
      "color": "white"
    info:
      "background-color": "#42afe3"
      "color": "white"
    success:
      "background-color": "#97cd76"
      "color": "white"
    warning:
      "background-color": "#fce473"
      "color": "white"
    danger:
      "background-color": "#ed6c63"
      "color": "white"



$ ->
  $('.notification > button.delete').click(deleteButtonClicked)
  $('.flash').each(fomulateFlashNotice)
  
