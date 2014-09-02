class AddAdminToUsers < ActiveRecord::Migration
  def change
    add_column :users, :admin, :boolean, default: false
                                                                        #デフォルトでは管理者になれないということを示すため
  end
end
