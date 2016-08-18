delete_button_clicked = (event) ->
  $(this).parent().remove()

$ ->
  $('.notification > button.delete').click(delete_button_clicked)