class EventGroupCollection
  include ActiveModel::Model

  attr_accessor :event_groups

  delegate :size, to: :event_groups

  def initialize(items)
    @event_groups = items
  end

  def event_groups_attributes=(items)
    @event_groups = items
  end
end
