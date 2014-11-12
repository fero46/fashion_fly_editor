# encoding: UTF-8
module FashionFlyEditor
  class Category < ActiveRecord::Base
    has_many :collection
    belongs_to :parent, :polymorphic => true

    validates :slug,  uniqueness: true
    validates :name, presence: true

    before_save :update_slug

    def update_slug
      default = create_slug(self)
      myslug = default
      counter = 0
      other_category = Category.where(slug: myslug).first 
      while other_category.present? && other_category.id != self.id
        counter+=1
        myslug = "#{default}_#{counter}"
        other_category = Category.where(slug: myslug).first 
      end
      self.slug=myslug
    end

    def create_slug object
      return object.name if object.class.name != FashionFlyEditor::Category.name
      parent = object.parent
      parent_slug = parent.present? ?  create_slug(parent) + "_"  : ''
      return parent_slug + clean_name(object.name).try(:downcase)
    end

private
    def clean_name name
      return "" if name.blank?
      name.gsub('ö', 'oe').gsub('ü', 'ue').gsub('ä', 'ae').gsub('ß','ss').gsub('%', '').gsub(' ','_').gsub('&','und')
    end
  end
end
