# frozen_string_literal: true

require 'spec_helper'

describe Erubis::OnlyRuby do
  subject do
    content = <<-EOF
    <h1>Title</h1>
    <% if current_user %>
      <%= link_to 'account', edit_user_path(current_user) %>
      <%= "Hello \#{current_user.email}" %>
    <% else %>
      Not logged in
    <% end %>
    EOF
    described_class.new(content).src
  end

  it { is_expected.not_to include('h1') }
  it { is_expected.not_to include('Title') }
  it { is_expected.not_to include('Not logged in') }
  it { is_expected.to include('current_user') }
  it { is_expected.to include('if') }
  it { is_expected.to include('else') }
  it { is_expected.to include('end') }
end
