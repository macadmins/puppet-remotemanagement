require 'cfpropertylist'
require 'digest/md5'

module RemoteManagementCommon

  RECORD_TYPES             = [:users, :groups, :computers, :computergroups]
  DSCL                     = '/usr/bin/dscl'
  SEARCH_NODE              = '/Search'



  # Search OpenDirectory
  # - find records in OpenDirectory given type, attribute and value
  # - returns Array of record names (not the actual records)
  def self.dscl_find_by(record_type, attribute, value)

    unless RECORD_TYPES.member? record_type.to_sym
      raise Puppet::Error, "not an OpenDirectory type: #{record_type}"
    end

    if attribute.empty? or value.empty?
      raise Puppet::Error, "Search params empty: \'#{attribute}\', \'#{value}\'"
    end

    # If we are looking for a record name, if might have backslahes in it
    # Active Directory records are returned this way, so split it.
    domain, value = value.split('\\') if value =~ /\w\\\w+/ and attribute.eql? 'name'

    cmd_args = [DSCL, SEARCH_NODE, '-search',
      "/#{record_type.to_s.capitalize}", attribute.to_s, "\'#{value.to_s}\'"]

    # Excute the search
    dscl_result = `#{cmd_args.join(' ')}`

    # If there is a domain component to the record name, rejoin them
    if domain and attribute.eql? 'name'
      value = [domain, value].join('\\') if domain
    end

    dscl_result.scan /#{Regexp.quote(value)}/i
  end

  def nil_or_empty?(value)
    value.nil? || value.empty?
  end

end
