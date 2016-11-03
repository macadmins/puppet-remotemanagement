Puppet::Type.newtype(:remotemanagement) do
  @doc = %q{Manage Mac OS X Apple Remote Desktop client settings.
    remotemanagement { 'apple_remote_desktop':
      ensure            => 'running',
      allow_all_users   => false,
      enable_menu_extra => false,
      users             => {
        'fred'   => -1073741569,
        'daphne' => -2147483646,
        'velma'  => -1073741822
      },
    }

    === EXAMPLE USER PRIVILEGE SETTINGS ===
    Bit map for naprivs
    -------------------
    64 Bit Hex Int Bit Decimal Checkbox Item
    ================================================================
    FFFFFFFFC0000000 0 -1073741824 enabled but nothing set
    FFFFFFFFC0000001 1 -1073741823 send text msgs
    FFFFFFFFC0000002 2 -1073741822 control and observe, show when observing
    FFFFFFFFC0000004 3 -1073741820 copy items
    FFFFFFFFC0000008 4 -1073741816 delete and replace items
    FFFFFFFFC0000010 5 -1073741808 generate reports
    FFFFFFFFC0000020 6 -1073741792 open and quit apps
    FFFFFFFFC0000040 7 -1073741760 change settings
    FFFFFFFFC0000080 8 -1073741696 restart and shutdown

    FFFFFFFF80000002 -2147483646 control and observe don't show when observing
    FFFFFFFFC00000FF -1073741569 all enabled
    }

  def munge_boolean(value)
    case value
    when true, "true", :true
      true
    when false, "false", :false
      false
    else
      fail("munge_boolean only takes booleans")
    end
  end

  ensurable do
    newvalue(:stopped, :event => :service_stopped) do
      provider.stop
    end

    newvalue(:running, :event => :service_started) do
      provider.start
    end

    def retrieve
      provider.running? ? :running : :stopped
    end
  end

  newparam(:name) do
    desc "Name of the setup."
    isnamevar
    defaultto 'apple_remote_desktop'
  end


  newproperty(:vnc_password) do
    desc "The password used for VNC, stored as plain text!
    Thinking this is not a good idea? Yeah, me too. Don't use it."

    def is_to_s(value)
      value.hash
    end

    def should_to_s(value)
      value.hash
    end

    munge do |value|
      value.empty? ? nil : value
    end
  end


  newproperty(:users) do
    desc "A hash containing a username to privilege mapping."

    munge do |value|
      value.inject({}) { |m,(k,v)| m[k.to_s] = v.to_s;m }
    end

    def insync?(is)
      if @resource[:strict]
        is == should
      else
        is.merge(should) == is
      end
    end

    defaultto { return Hash.new }
  end

  newparam(:strict) do
    desc "Setting this to true will explicitly define which users are permitted RemoteManagement privs. This
          means that any account not defined in the :users hash will have their privs revoked if present."

    munge do |value|
      @resource.munge_boolean(value)
    end

    newvalues(true, false)
    defaultto true
  end

end
