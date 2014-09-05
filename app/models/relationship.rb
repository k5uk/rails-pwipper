class Relationship < ActiveRecord::Base

  #belongs_to関連付けを Relationshipモデルに追加。
  #FollowedモデルもFollowerモデルも実際にはないので、クラス名Userを提供する必要がある。
  #デフォルトで作成されるRelationshipモデルとは異なり、followed_idのみアクセス可能となっている点に注意。
  belongs_to :follower, class_name: "User"
  belongs_to :followed, class_name: "User"

  #Relationshipモデルの検証を追加
  #follower_idは必ず存在するようにする
  validates :follower_id, presence: true
  #followed_idは必ず存在するようにする
  validates :followed_id, presence: true

end
