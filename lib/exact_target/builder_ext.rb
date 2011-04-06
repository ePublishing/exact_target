require 'builder'

Builder::XmlBase.class_eval do

  def tags_from_options!(options, *names)
    names.flatten.each do |name|
      tag! name.to_s, options[name.to_sym].to_s
    end
  end

end
