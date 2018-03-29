require 'json'

class StartPointChecker

  def initialize(path)
    @path = path.chomp('/')
    @manifests = {}
    @errors = {}
  end

  attr_reader :manifests # { manifest-filename => json-manifest-object }
  attr_reader :errors    # { manifest-filename => [ 'error', ... ] }

  # - - - - - - - - - - - - - - - - - - - -

  def check
    # check start_point_type.json is in root but do not add to manifests[]
    manifest = json_manifest(setup_filename)
    if manifest.nil?
      return errors
    end

    unless check_start_point_type_json_meets_its_spec(manifest)
      return errors
    end

    # TODO this should go after checking multiple start_point_type.json files
    if manifest['type'] == 'exercises'
      check_at_least_one_instructions
      return errors
    end

    Dir.glob("#{@path}/**/start_point_type.json").each do |filename|
      spt = json_manifest(filename)
      if spt['type'] != manifest['type']
        setup_error('different types in start_point_type.json files')
        return errors
      end
    end

    # json-parse all manifest.json files and add to manifests[]
    Dir.glob("#{@path}/**/manifest.json").each do |filename|
      manifest = json_manifest(filename)
      @manifests[filename] = manifest unless manifest.nil?
    end
    # check manifests
    check_at_least_one_manifest
    check_all_manifests_have_a_unique_display_name
    @manifests.each do |filename, manifest|
      @manifest_filename = filename
      @manifest = manifest
      check_no_unknown_keys_exist
      check_all_required_keys_exist
      # required
      check_visible_filenames_is_valid
      check_display_name_is_valid
      check_image_name_is_valid
      # optional
      check_runner_choice_is_valid
      check_progress_regexs_is_valid
      check_filename_extension_is_valid
      check_tab_size_is_valid
      check_highlight_filenames_is_valid
      check_max_seconds_is_valid
    end
    errors
  end

  # - - - - - - - - - - - - - - - - - - - -

  def known_keys
    %w( display_name
        visible_filenames
        image_name
        runner_choice
        filename_extension
        highlight_filenames
        progress_regexs
        tab_size
        max_seconds
      )
  end

  # - - - - - - - - - - - - - - - - - - - -

  def required_keys
    %w( display_name
        visible_filenames
        image_name
        runner_choice
      )
  end

  private

  self.new('').known_keys.each do |key|
    define_method(key.to_sym) { @manifest[key] }
  end

  # - - - - - - - - - - - - - - - - - - - -

  def check_start_point_type_json_meets_its_spec(manifest)
    @key = 'type'
    type = manifest[@key]
    if type.nil?
      setup_error 'missing'
      return false
    end
    unless ['languages','exercises','custom'].include? type
      setup_error 'must be [languages|exercises|custom]'
      return false
    end
    return true
  end

  # - - - - - - - - - - - - - - - - - - - -

  def check_at_least_one_instructions
    unless Dir.glob("#{@path}/**/instructions").count > 0
      @errors[@path] ||= []
      @errors[@path] << 'no instructions files'
    end
  end

  # - - - - - - - - - - - - - - - - - - - -

  def check_at_least_one_manifest
    unless @manifests.size > 0
      @errors[@path] ||= []
      @errors[@path] << 'no manifest.json files'
    end
  end

  # - - - - - - - - - - - - - - - - - - - -

  def check_all_manifests_have_a_unique_display_name
    key = 'display_name'
    display_names = {}
    @manifests.each do |filename, manifest|
      display_name = manifest[key]
      display_names[display_name] ||= []
      display_names[display_name] << filename
    end
    display_names.each do |display_name, filenames|
      if filenames.size > 1
        filenames.each do |filename|
          @errors[filename] << "#{key}: duplicate '#{display_name}'"
        end
      end
    end
  end

  # - - - - - - - - - - - - - - - - - - - -

  def check_no_unknown_keys_exist
    @manifest.keys.each do |key|
      unless known_keys.include? key
        @key = key
        error 'unknown key'
      end
    end
  end

  # - - - - - - - - - - - - - - - - - - - -

  def check_all_required_keys_exist
    required_keys.each do |key|
      unless @manifest.keys.include? key
        @key = key
        error 'missing'
      end
    end
  end

  # - - - - - - - - - - - - - - - - - - - -

  def check_visible_filenames_is_valid
    @key = 'visible_filenames'
    return if visible_filenames.nil? # required-key different check
    # check its form
    unless visible_filenames.is_a? Array
      error 'must be an Array of Strings'
      return
    end
    unless visible_filenames.all?{ |item| item.is_a? String }
      error 'must be an Array of Strings'
      return
    end
    # check all visible files exist and are world-readable
    dir = File.dirname(@manifest_filename)
    visible_filenames.each do |filename|
      unless File.exists?(dir + '/' + filename)
        error "missing '#{filename}'"
        next
      end
      unless File.stat(dir + '/' + filename).world_readable?
        error "'#{filename}' must be world-readable"
      end
    end
    # check no duplicate visible files
    visible_filenames.uniq.each do |filename|
      unless visible_filenames.count(filename) == 1
        error "duplicate '#{filename}'"
      end
    end
    # check cyber-dojo.sh is a visible_filename
    unless visible_filenames.include? 'cyber-dojo.sh'
      error "must contain 'cyber-dojo.sh'"
      return
    end
  end

  # - - - - - - - - - - - - - - - - - - - -

  def check_highlight_filenames_is_valid
    @key = 'highlight_filenames'
    return if highlight_filenames.nil? # it's optional
    # check its form
    unless highlight_filenames.is_a? Array
      error 'must be an Array of Strings'
      return
    end
    unless highlight_filenames.all?{ |item| item.is_a? String }
      error 'must be an Array of Strings'
      return
    end
    # check all are visible
    highlight_filenames.each do |h_filename|
      if visible_filenames.none? {|v_filename| v_filename == h_filename }
        error "'#{h_filename}' must be in visible_filenames"
      end
    end
    # check no duplicates
    highlight_filenames.uniq.each do |filename|
      unless highlight_filenames.count(filename) == 1
        error "duplicate '#{filename}'"
      end
    end
  end

  # - - - - - - - - - - - - - - - - - - - -

  def check_runner_choice_is_valid
    @key = 'runner_choice'
    return if runner_choice.nil? # required-key different check
    unless runner_choice.is_a? String
      error 'must be a String'
      return
    end
    unless ['stateful','stateless','processful'].include? runner_choice
      error 'must be "stateful" or "stateless" or "processful"'
    end
  end

  # - - - - - - - - - - - - - - - - - - - -

  def check_display_name_is_valid
    @key = 'display_name'
    return if display_name.nil? # required-key different check
    unless display_name.is_a? String
      error 'must be a String'
      return
    end
    parts = display_name.split(',').select { |part| part.strip != '' }
    unless parts.length == 2
      error "not in 'major,minor' format"
      return
    end
    if parts[0].include?('-')
      error "'major,minor' major cannot contain hyphens(-)"
    end
  end

  # - - - - - - - - - - - - - - - - - - - -

  def check_image_name_is_valid
    @key = 'image_name'
    return if image_name.nil? # required-key different check
    unless image_name.is_a? String
      error 'must be a String'
      return
    end

    # http://stackoverflow.com/questions/37861791/
    i = image_name.index('/')
    if i.nil? || i == -1 || (
        !image_name[0...i].include?('.') &&
        !image_name[0...i].include?(':') &&
         image_name[0...i] != 'localhost')
      hostname = ''
      remote_name = image_name
    else
      hostname = image_name[0..i-1]
      remote_name = image_name[i+1..-1]
    end

    unless valid_hostname?(hostname)
      error 'is invalid'
    end
    unless valid_remote_name?(remote_name)
      error 'is invalid'
    end
  end

  def valid_hostname?(hostname)
    return true if hostname == ''
    port = '[\d]+'
    component = "([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9])"
    hostname =~ /^(#{component}(\.#{component})*)(:(#{port}))?$/
  end

  def valid_remote_name?(remote_name)
    alpha_numeric = '[a-z0-9]+'
    separator = '([.]{1}|[_]{1,2}|[-]+)'
    component = "#{alpha_numeric}(#{separator}#{alpha_numeric})*"
    name = "#{component}(/#{component})*"
    tag = '[\w][\w.-]{0,127}'

    digest_component = '[A-Za-z][A-Za-z0-9]*'
    digest_separator = '[-_+.]'
    digest_algorithm = "#{digest_component}(#{digest_separator}#{digest_component})*"
    digest_hex = "[0-9a-fA-F]{32,}"
    digest = "#{digest_algorithm}[:]#{digest_hex}"
    remote_name =~ /^(#{name})(:(#{tag}))?(@#{digest})?$/
  end

  # - - - - - - - - - - - - - - - - - - - -

  def check_progress_regexs_is_valid
    @key = 'progress_regexs'
    return if progress_regexs.nil?  # it's optional
    unless progress_regexs.is_a? Array
      error 'must be an Array of 2 Strings'
      return
    end
    if progress_regexs.length != 2
      error 'must be an Array of 2 Strings'
      return
    end
    unless progress_regexs.all? { |item| item.is_a? String }
      error 'must be an Array of 2 Strings'
      return
    end
    progress_regexs.each do |s|
      begin
        Regexp.new(s)
      rescue
        error "cannot create regex from #{s}"
      end
    end
  end

  # - - - - - - - - - - - - - - - - - - - -

  def check_filename_extension_is_valid
    @key = 'filename_extension'
    return if filename_extension.nil? # it's optional

    target = filename_extension
    if target.is_a?(String)
      target = [ target ]
    end

    unless target.is_a? Array
      error 'must be a String or Array of Strings'
      return
    end
    unless target.size > 0
      error 'must be a String or Array of Strings'
      return
    end
    unless target.all? { |item| item.is_a?(String) }
      error 'must be a String or Array of Strings'
      return
    end
    if target.any? { |item| item == '' }
      error 'is empty'
      return
    end
    if target.any? { |item| item[0] != '.' }
      error 'must start with a dot'
      return
    end
    if target.any? { |item| item == '.' }
      error 'must be more than just a dot'
      return
    end
    if target.sort.uniq.size != target.size
      error 'contains duplicate'
      return
    end
  end

  # - - - - - - - - - - - - - - - - - - - -

  def check_max_seconds_is_valid
    @key = 'max_seconds'
    return if max_seconds.nil? # it's optional
    unless max_seconds.is_a? Integer
      error 'must be an int'
      return
    end
    if max_seconds.to_i <= 0
      error 'must be an int > 0'
      return
    end
    if max_seconds.to_i > 20
      error 'must be an int <= 20'
      return
    end
  end

  # - - - - - - - - - - - - - - - - - - - -

  def check_tab_size_is_valid
    @key = 'tab_size'
    return if tab_size.nil? # it's optional
    unless tab_size.is_a? Integer
      error 'must be an int'
      return
    end
    if tab_size.to_i <= 0
      error 'must be an int > 0'
      return
    end
    if tab_size.to_i > 8
      error 'must be an int <= 8'
      return
    end
  end

  # - - - - - - - - - - - - - - - - - - - -

  def setup_filename
    @path + '/start_point_type.json'
  end

  # - - - - - - - - - - - - - - - - - - - -

  def json_manifest(filename)
    @errors[filename] = []
    unless File.exists?(filename)
      @errors[filename] << 'is missing'
      return nil
    end
    begin
      content = IO.read(filename)
      return JSON.parse(content)
    rescue JSON::ParserError
      @errors[filename] << 'bad JSON'
    end
    return nil
  end

  # - - - - - - - - - - - - - - - - - - - -

  def error(msg)
    @errors[@manifest_filename] << (@key + ': ' + msg)
  end

  def setup_error(msg)
    @errors[setup_filename] << (@key + ': ' + msg)
  end

end
