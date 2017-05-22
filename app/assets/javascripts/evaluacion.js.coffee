$(document).on "turbolinks:load", ->
  $ -> new Evaluacion() if $('[data-action=evaluaciones]').length > 0

class Evaluacion
  constructor: ->
    @cacheElements()
    @bindEvents()

  cacheElements: ->
    # Contenedor de URLs
    @$evaluacionUrls = $('#evaluacion-urls')

    # Variables
    @$obtieneUsuariosPath = @$evaluacionUrls.data('obtiene-usuarios')

    # Elementos
    @$inputEvaluadores = $('#evaluacion_evaluadores_')
    @$inputEvaluados = $('#evaluacion_evaluados_')

  bindEvents: ->
    $(document).on 'change', @$inputEvaluadores.selector, (e) => @actualiza_evaluadores(e)

  actualiza_evaluadores: (e) =>
    url = @$obtieneUsuariosPath
    datos = { usuarios: $(e.target).val() }
    _ = @
    $.ajax
      url: url
      type: 'POST'
      dataType: 'JSON'
      data: datos
    .done (data) ->
      _.$inputEvaluados.html(_.generar_opciones(data))

  generar_opciones: (data) ->
    html = ''
    _ = @
    data.map (usuario) ->
      html = html + '<option value="' + usuario.id + '">' + _.uid_nombre_completo(usuario) + '</option>'
    html

  uid_nombre_completo: (usuario) ->
    if usuario.nombres
      usuario.username + ' - ' + usuario.nombres + ' ' + usuario.apellidos
    else
      usuario.username
