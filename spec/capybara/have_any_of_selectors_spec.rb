# frozen_string_literal: true

RSpec.feature '#have_any_of_selectors', helpers: [:html_page] do
  before do
    html_page.visit_page
  end

  it 'should be able to use aliases' do
    html_page.assert_any_of_selectors(:css, :missing_element, :link_for_paragraph)
    html_page.assert_all_of_selectors(:css, :link_for_paragraph)

    expect { html_page.assert_none_of_selectors(:css, :link_for_paragraph) }
      .to raise_error Capybara::ExpectationNotMet
  end

  it 'should be true if any of the given selectors are on the page' do
    html_page.should.have_any_of_selectors(:css, 'h2#blah', :link_for_paragraph)
    html_page.should.have_any_of_selectors('h2#blah', :link_for_paragraph, 'h2#h2two')
    html_page.assert_any_of_selectors(:css, 'h2#blah', :link_for_paragraph)
    html_page.assert_any_of_selectors('h2#blah', :link_for_paragraph, 'h2#h2two')
  end

  it 'should be false if none of the given selectors are not on the page' do
    expect do
      html_page.should.have_any_of_selectors('h2#blah')
    end.to raise_error RSpec::Expectations::ExpectationNotMetError

    expect do
      html_page.should.have_any_of_selectors('span a#foo', 'h2#h2nope', 'h2#h2one_no')
    end.to raise_error RSpec::Expectations::ExpectationNotMetError

    expect do
      html_page.assert_any_of_selectors('h2#blah')
    end.to raise_error Capybara::ExpectationNotMet

    expect do
      html_page.assert_any_of_selectors('span a#foo', 'h2#h2nope', 'h2#h2one_no')
    end.to raise_error Capybara::ExpectationNotMet
  end
end
