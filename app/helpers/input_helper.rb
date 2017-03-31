module InputHelper
  def get_input_id(name, attribute_name)
    idify(name) + attribute_name
  end

  def idify(name)
    name.gsub(/[\[\]]/, '_').gsub(/__/, '_')
  end
end
