require 'ceedling/plugin'
require 'ceedling/constants'

DEPENDENCIES_ROOT_NAME         = 'dependencies'
DEPENDENCIES_TASK_ROOT         = DEPENDENCIES_ROOT_NAME + ':'
DEPENDENCIES_SYM               = DEPENDENCIES_ROOT_NAME.to_sym

class Dependencies < Plugin

  def setup
    @plugin_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

    # Set up a fast way to look up dependencies by name or static lib path
    @dependencies = {}
    DEPENDENCIES_LIBRARIES.each do |deplib|
      @dependencies[ deplib[:name] ] = deplib.clone
      get_static_libraries_for_dependency(deplib).each do |key|
        @dependencies[key] = @dependencies[ deplib[:name] ]
      end
    end
  end

  def get_name(deplib)
    raise "Each dependency must have a name!" if deplib[:name].nil? 
    return deplib[:name].gsub(/\W*/,'')
  end

  def get_working_path(deplib)
    return deplib[:working_path] || File.join('dependencies', get_name(deplib))
  end

  def get_static_libraries_for_dependency(deplib)
    (deplib[:artifacts][:static_libraries] || []).map {|path| File.join(get_working_path(deplib), path)}
  end

  def get_dynamic_libraries_for_dependency(deplib)
    (deplib[:artifacts][:dynamic_libraries] || []).map {|path| File.join(get_working_path(deplib), path)}
  end

  def get_include_directories_for_dependency(deplib)
    (deplib[:artifacts][:includes] || []).map {|path| File.join(get_working_path(deplib), path)}
  end

  def fetch_if_required(lib_path)
    blob = @dependencies[lib_path]
    raise "Could not find dependency '#{lib_path}'" if blob.nil?
    return if (blob[:fetch].nil?)
    return if (blob[:fetch][:method].nil?)

    case blob[:fetch][:method]
    when :none
      return
    when :zip
      raise "TODO: Zip support not yet implemented in dependency plugin"
    when :git 
      raise "TODO: Git support not yet implemented in dependency plugin"
    else
      raise "Unknown fetch method '#{blob[:fetch][:method].to_s}' for dependency '#{blob[:name]}'"
    end
  end

  def build_if_required(lib_path)
    blob = @dependencies[lib_path]
    raise "Could not find dependency '#{lib_path}'" if blob.nil?
    raise "Could not find build steps for dependency '#{blob[:name]}'" if (blob[:build].nil? || blob[:build].empty?)

    blob[:build].each do |step|
      #TODO: actually execute the build steps
    end
  end
end

# end blocks always executed following rake run
END {
}
