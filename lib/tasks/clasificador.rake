namespace :caeb do
  ##
  # Para el caso de los clasificadores públicos en la ADSIB tienen un listado
  # el cual por el momento se importa a la base de datos mediante la tarea
  # que está descrito a continuación.
  # TODO: Lo ideal es tener una interfaz web que permita cargar estos datos a
  # partir de una hoja de cálculo
  # uso: rake db:materiales["/directorio/del/archivo.ods"]
  desc "Cargado de los clasificadores públicos para almacenes"
  task :importar, [:documento] => [:environment] do |t, args|
    unless args[:documento].present?
      puts "Es necesario especificar un parámetro con la ubicación del archivo .ODS"
      next # http://stackoverflow.com/a/2316518/1174245
    end

    Clasificador.all.map{|c| c.delete}

    file_path = args[:documento]
    puts 'archivo:' + file_path
    sheet = Roo::CSV.new(file_path, csv_options: {col_sep: ","})
    cod_seccion = nil
    cod_division = nil
    cod_grupo = nil
    cod_clase = nil
    subclase = nil
    objeto = nil
    i = 0
    (2..sheet.last_row).each do |indice_fila|
      #objeto = { descripcion: sheet.cell(indice_fila, 6).force_encoding('UTF-8') }
      objeto = { descripcion: '312312' }
      if sheet.cell(indice_fila, 1).present?
        cod_seccion = sheet.cell(indice_fila, 1)
        objeto['codigo'] = sheet.cell(indice_fila, 1)
        objeto['tipo'] = 'SECCION'
      elsif sheet.cell(indice_fila, 2).present?
        cod_division = sheet.cell(indice_fila, 2)
        objeto['codigo'] = sheet.cell(indice_fila, 2)
        objeto['tipo'] = 'DIVISION'
        objeto['codigo_padre'] = cod_seccion
      elsif sheet.cell(indice_fila, 3).present?
        cod_grupo = sheet.cell(indice_fila, 3)
        objeto['codigo'] = sheet.cell(indice_fila, 3)
        objeto['tipo'] = 'GRUPO'
        objeto['codigo_padre'] = cod_division
      elsif sheet.cell(indice_fila, 4).present?
        cod_clase = sheet.cell(indice_fila, 4)
        objeto['codigo'] = sheet.cell(indice_fila, 4)
        objeto['tipo'] = 'CLASE'
        objeto['codigo_padre'] = cod_grupo
      elsif sheet.cell(indice_fila, 5).present?
        cod_seccion = sheet.cell(indice_fila, 5)
        objeto['codigo'] = sheet.cell(indice_fila, 5)
        objeto['tipo'] = 'SUBCLASE'
        objeto['codigo_padre'] = cod_clase
      end

      clasificador = Clasificador.new(objeto)
      clasificador.save
      i += 1
    end
    puts "Se registraron #{i} registros"
  end
end

def obtieneDatos(fila)

end
