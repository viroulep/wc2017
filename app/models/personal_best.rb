#FIXME: shouldn't this somehow be already included during the app initialization?!
require 'solve_time'

class PersonalBest < ApplicationRecord
  belongs_to :user

  # List of fields we accept in the db
  PB_ATTRS = %w(user_id result_type event_id best world_ranking continental_ranking national_ranking).freeze
  INSERT_FORMAT = "(#{"?, "*(PB_ATTRS.size - 1)} ?)".freeze
  #FIXME there is probably an active record thing to build this from camel cas ones
  CAMEL_CASE_ATTRS = %w(eventId worldRanking continentalRanking nationalRanking).freeze

  def to_s
    SolveTime.new(event_id, result_type.to_sym, best).clock_format
  end

  def self.as_array(json_pb)
    attributes = attrs_from_json(json_pb)
    PB_ATTRS.map do |attr|
      attributes[attr]
    end
  end

  def self.insert_all(values_array)
    # Rails doesn't support inserting multiple rows at once, so we need to build
    # it manually, pass it to ActiveRecord for sanitizing, and then run it
    statement = "insert into personal_bests (#{PB_ATTRS.join(",")}) values "
    statement << "#{INSERT_FORMAT},"*(values_array.size-1)
    statement << INSERT_FORMAT
    sql = ActiveRecord::Base.send(:sanitize_sql_array, [statement,values_array].flatten)
    ActiveRecord::Base.connection.execute(sql)
  end

  private
  def self.attrs_from_json(json_pb)
    CAMEL_CASE_ATTRS.each do |key|
      json_pb[key.underscore] = json_pb[key] if json_pb.include?(key)
    end
    json_pb["result_type"] = json_pb["type"]
    obj_params = ActionController::Parameters.new(json_pb)
    obj_params.permit(PB_ATTRS)
  end
end
