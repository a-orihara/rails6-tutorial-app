class AddActivationToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :activation_digest, :string
    # 1
    add_column :users, :activated, :boolean, default: false
    add_column :users, :activated_at, :datetime
  end
end

# 1
# admin 属性(リスト 10.54)のときと同様に、 activated 属性のデフォルトの論理値を false 
# にしておきます(リスト 11.2)。
# activated?が使用可能に。