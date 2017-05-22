require 'net/ldap'

class ServidorLdap
  def initialize(usuario, contrasena)
    @usuario = usuario
    @contrasena = contrasena
  end

  # Retorna un array con Net::LDAP y las configuraciones del servidor LDAP
  def autenticacion
    ldap_configs = Rails.application.secrets.ldap
    ldap_configs = ldap_configs.is_a?(Hash) ? [ldap_configs] : ldap_configs

    ldap_configs.each do |ldap_config|
      options = {
        host: ldap_config['host'],
        port: ldap_config['port']
      }
      ldap_config["ssl"] = :simple_tls if ldap_config["ssl"] === true
      options[:encryption] = ldap_config["ssl"].to_sym if ldap_config["ssl"]

      options.merge! auth: {
        method: :simple,
        username: generar_username(ldap_config),
        password: @contrasena
      }

      ldap = Net::LDAP.new options

      return ldap, ldap_config if ldap.bind
    end

    return nil, nil # No hay coincidencia, no hay autenticación
  end

  # Recupera la lista de usuarios de LDAP
  def usuarios
    ldap, ldap_config = autenticacion
    criterio = "*"
    filtro = Net::LDAP::Filter.eq(ldap_config['attribute'], criterio)
    ldap.search(base: ldap_config['base'], filter: filtro)
  end

  def generar_username(ldap_config)
    atributo = ldap_config['attribute']
    base = ldap_config['base']
    "#{atributo}=#{@usuario},#{base}"
  end
end
