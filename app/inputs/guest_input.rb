# frozen_string_literal: true
class GuestInput < SimpleForm::Inputs::Base
  include InputHelper
  def input(wrapper_options)
    # Here is some explanation about how generating the input works (to save people
    # some digging in SimpleForm's source code):
    # This method should return a string with the html code generating the input.
    # The base class includes a ton of helpers to generates html tag and other
    # predefined inputs.
    # In this class the input consists of one visible input (with the money mask),
    # and one hidden input, containing the actual value sent to the controller.
    merged_input_options = merge_wrapper_options(input_html_options, wrapper_options)

    obj_value = @builder.object.send(attribute_name)

    new_record = merged_input_options.delete(:new_record)

    merged_input_options[:value] = obj_value
    input_id = get_input_id(@builder.object_name, attribute_name.to_s)
    name_display = ""
    merged_input_options[:class] << "form-control"

    unless new_record
      merged_input_options[:class] << "existing-record"
      # This helper create an arbitrary tag (in this case a p), with the given attributes.
      name_display = template.content_tag(:p, obj_value,
                                          id: "#{input_id}_p",
                                          class: "form-control-static")
    end

    # Create an input string field
    string_field = @builder.text_field(attribute_name, merged_input_options)

    template.content_tag(:div,
                         string_field + name_display,
                         class: "form-group guest")
  end

  private
end
