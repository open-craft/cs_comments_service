class Feed
  include Mongoid::Document
  include Mongoid::Timestamps

  field :feed_type, type: String
  field :info, type: Hash

  belongs_to :actor, class_name: "User", inverse_of: :activities, index: true, autosave: true
  belongs_to :target, inverse_of: :activities, polymorphic: true, autosave: true

  attr_accessible :feed_type, :info

  validates_presence_of :feed_type
  if not CommentService.config["allow_anonymity"]
    validates_presence_of :actor
  end
  validates_presence_of :target

  has_and_belongs_to_many :subscribers, class_name: "User", inverse_of: :subscribed_feeds, autosave: true

  def to_hash(params={})
    as_document.slice(*%w[_id feed_type info actor target])
  end
end
