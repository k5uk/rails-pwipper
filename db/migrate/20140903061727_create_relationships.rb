class CreateRelationships < ActiveRecord::Migration
  def change
    create_table :relationships do |t|
      t.integer :follower_id
      t.integer :followed_id

      t.timestamps
    end

    #relationshipsテーブルにインデックスを追加
    add_index :relationships, :follower_id
    add_index :relationships, :followed_id

    add_index :relationships, [:follower_id, :followed_id], unique: true
    #複合 (composite) インデックスを使用。これはfollower_idとfollowed_idを組み合わせたときの一意性 (uniquenes: 重複がないこと) を強制するもので、これにより、あるユーザーは別のユーザーを2度以上フォローすることはできなくなる。

  end
end