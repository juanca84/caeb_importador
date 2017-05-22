module ApplicationHelper
  def mostrar_estado(estado)
    case estado
    when 'por_iniciar'
      content_tag :span, t("general.estados.#{estado}"), class: 'label label-primary'
    when 'iniciado'
      content_tag :span, t("general.estados.#{estado}"), class: 'label label-warning'
    when 'concluido'
      content_tag :span, t("general.estados.#{estado}"), class: 'label label-success'
    else
      t("general.estados.#{estado}")
    end
  end
end
