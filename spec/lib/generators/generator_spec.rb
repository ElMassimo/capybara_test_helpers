require 'generator_spec'
require 'generators/test_helper/test_helper_generator'

RSpec.describe TestHelperGenerator, type: :generator do
  destination File.expand_path("../../../tmp", __dir__)

  before do
    prepare_destination
  end

  context 'normal helpers' do
    before { run_generator %w[button] }

    it "generates a test helper" do
      assert_file 'test_helpers/button_test_helper.rb', <<~TEST_HELPER
        # frozen_string_literal: true

        class ButtonTestHelper < BaseTestHelper
        # Selectors: Semantic aliases for elements, a useful abstraction.
          SELECTORS = {}

        # Getters: A convenient way to get related data or nested elements.

        # Actions: Encapsulate complex actions to provide a cleaner interface.

        # Assertions: Check on element properties, used with `should` and `should_not`.

        # Background: Helpers to add/modify/delete data in the database or session.
        end
      TEST_HELPER
    end
  end

  context 'base helper' do
    before { run_generator %w[base] }

    it "generates the base test helper" do
      assert_file 'test_helpers/base_test_helper.rb', <<~TEST_HELPER
        # frozen_string_literal: true

        class BaseTestHelper < Capybara::TestHelper
        # Selectors: Semantic aliases for elements, a useful abstraction.
          SELECTORS = {}

        # Getters: A convenient way to get related data or nested elements.

        # Actions: Encapsulate complex actions to provide a cleaner interface.

        # Assertions: Check on element properties, used with `should` and `should_not`.

        # Background: Helpers to add/modify/delete data in the database or session.
        end
      TEST_HELPER
    end
  end
end
