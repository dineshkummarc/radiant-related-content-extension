module RelatedContent::PageExtensions
  def self.included(base)
    base.class_eval do
      has_many :outgoing_relations, :class_name => "PageRelation", 
                :foreign_key => "from_id", :dependent => :destroy, :order => :position
      has_many :incoming_relations, :class_name => "PageRelation", 
                :foreign_key => "to_id", :dependent => :destroy
      
      has_many :related_pages, :through => :outgoing_relations, :source => :to, :class_name => "Page", :order => 'page_relations.position'
      
      after_save :create_relations
      
      attr_accessor :delete_relations, :add_relations
    end
  end
  
  def create_relations
    if @delete_relations
      @delete_relations.each do |r|
        self.outgoing_relations.find_by_to_id(r).destroy
      end
    end
    existing_relations = outgoing_relations.map { |r| r.to_id.to_s }
    if @add_relations
      (@add_relations - existing_relations).uniq.each do |r|
        self.outgoing_relations.create(:to_id => r)
      end
    end
    @delete_relations = nil
    @add_relations = nil
  end
end
