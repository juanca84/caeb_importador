$(document).on "turbolinks:load", ->
  $ -> new Usuarios() if $('[data-action=usuarios]').length > 0

class Usuarios
  constructor: ->
    @cacheElements()
    @bindEvents()

  cacheElements: ->
    # Contenedor de URLs
    @$usuariosIndex = $('#usuarios-index')

    # Variables
    @$actualizaUsuariosPath = @$usuariosIndex.data('usuarios-path')

    # Elementos
    @$checkboxRol = $('.usuario-rol')

  bindEvents: ->
    $(document).on 'click', @$checkboxRol.selector, (e) => @actualizarRol(e)

  actualizarRol: (e) =>
    admin = null
    admin = 'admin' if $(e.target).is(':checked')
    datos = {usuario: {roles: admin }}
    id = $(e.target).prop('id').split('_')[1]
    $.ajax
      url: [@$actualizaUsuariosPath, id].join('/')
      type: 'PUT'
      dataType: 'JSON'
      data: datos
    .done (data) ->
      $fila = $(e.target).closest('tr')
      $fila.toggleClass('warning')

