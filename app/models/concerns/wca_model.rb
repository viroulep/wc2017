require 'active_support/concern'

module WCAModel
  extend ActiveSupport::Concern

  class_methods do
    def create_or_update(wca_object, additional_attrs={})
      obj_params = ActionController::Parameters.new(wca_object)
      accepted_params = class_variable_get(:@@obj_info) || {}
      obj_attr = obj_params.permit(accepted_params)
      obj_attr.merge!(additional_attrs)
      obj_id = obj_params.require(:id)
      obj = find_or_initialize_by(id: obj_id)
      [obj.update(obj_attr), obj]
    end
  end
end
