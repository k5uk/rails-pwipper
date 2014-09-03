class Micropost < ActiveRecord::Base
  belongs_to :user

  #ファイル「user_spec.rb」の「it "should have the right microposts in the right order" do」のテストをパスするために、Railsのdefault_scopeにorderパラメータを渡して使用。
  default_scope -> { order('created_at DESC') }
  #DESCは SQLでいうところの “descending”であり、新しいものから古い順への降順ということ。

  validates :content, presence: true, length: { maximum: 140 }
                                                              #コンテンツの長さは上限140文字
  validates :user_id, presence: true
end
