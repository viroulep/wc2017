#FIXME: shouldn't this somehow be already included during the app initialization?!
require 'solve_time'

class PersonalBest < ApplicationRecord
  include WCAModel
  belongs_to :user

  # List of fields we accept in the db
  @@obj_info = %w(user_id result_type event_id best world_ranking continental_ranking national_ranking).freeze

  def as_solve_time
    SolveTime.new(event_id, result_type.to_sym, best)
  end

  def to_s
    as_solve_time.clock_format
  end

  private
  def self.attrs_from_json(json_pb)
    json_pb["result_type"] = json_pb.delete("type")

    attrs, _ = get_attr(json_pb, false)
    attrs
  end
end
