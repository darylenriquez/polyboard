beforeLoadList = (item) ->
  item = this unless item?

  $(this).addClass 'is-loading'


beforeSendMail = () ->
  # Nothing to do yet


@setupCallbacks = () ->
  $('#paging-link').on 'ajax:beforeSend', beforeLoadList
  $('#mail-links .message').on 'ajax:complete', iframeHeightAndScroll
  $('.reply-pane form').on 'ajax:beforeSend', beforeSendMail


@setFrameHeight = (event) ->
  $(event.target).height("#{event.target.contentDocument.body.scrollHeight}px")


@setIframeHeight = () ->
  $('iframe').each (index, iframe) ->  $(iframe).height("#{iframe.contentDocument.body.scrollHeight}px")


@scrollToLast = () ->
  item = $(".messages > .card:last")
  
  $(".messages").animate({ scrollTop: (item.offset().top - item.parent().offset().top - item.parent().scrollTop())}, 1000) if item.length > 0


@iframeHeightAndScroll = () ->
  $('iframe').each (index, element) -> $(element).on 'load', setFrameHeight
  scrollToLast()


$ ->
  setupCallbacks()
  iframeHeightAndScroll()
