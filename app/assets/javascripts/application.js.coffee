progress_updater = null;

window.update_progress_bar = (element_id, url) ->
  progress_updater = $.PeriodicalUpdater(url, {}, (data, state) ->
    $("##{element_id}").html(data) unless state == "notmodified"
  )

window.stop_progress_bar = () ->
  progress_updater.stop() if progress_updater

$(->

  $('.record, .action').click(->
    window.location = $(this).find('a').attr('href')
  )

  $('a[data-view]').each(->
    view_type = $(this).data('view')
    re = new RegExp("^#?#{view_type}$")
    current_open_view = window.location.hash || 'general'

    if current_open_view.match(re)
      $(this).parent('li').addClass('current_view')
    else
      $("##{view_type}").hide()

    $('.data_box .heading').hide()

    $(this).click((event) ->
      $('.data_box').hide()
      $('.current_view').removeClass('current_view')
      $(this).parent('li').addClass('current_view')
      $("##{view_type}").show()
      window.location.hash = view_type
      event.preventDefault()
    )
  )

)
