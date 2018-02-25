class ChangeVgToNbVgInRegistrationDetail < ActiveRecord::Migration[5.0]
  def up
    add_column :registration_details, :nb_vg, :integer
    RegistrationDetail.where(vg: true).update_all(nb_vg: 1)
    remove_column :registration_details, :vg, :boolean
  end
  def down
    add_column :registration_details, :vg, :boolean
    RegistrationDetail.where('nb_vg > 0').update_all(vg: true)
    remove_column :registration_details, :nb_vg, :integer
  end
end
