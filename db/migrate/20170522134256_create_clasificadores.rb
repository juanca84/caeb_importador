class CreateClasificadores < ActiveRecord::Migration[5.0]
  def change
    create_table :clasificadores do |t|
      t.string :codigo
      t.string :descripcion
      t.string :tipo
      t.string :codigo_padre

      t.timestamps
    end
  end
end
