class Page < ActiveRecord::Base
  validates_presence_of :title
  validates_presence_of :slug
end