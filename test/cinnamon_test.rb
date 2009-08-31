require 'test_helper'
require 'active_support'
require 'action_controller'

class CinnamonTest < Test::Unit::TestCase
  context 'config_files' do
    setup do
      Cinnamon.config_files = {}
    end

    should 'be an empty hash after loading the module' do
      assert_equal Cinnamon.config_files, {}
    end
  end
end
