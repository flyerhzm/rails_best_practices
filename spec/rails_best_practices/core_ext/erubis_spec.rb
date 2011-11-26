require 'spec_helper'

describe Erubis::OnlyRuby do
  subject {
    content =<<-EOF
    <h1>Title</h1>
    <% if current_user %>
      <%= link_to 'account', edit_user_path(current_user) %>
      <%= "Hello \#{current_user.email}" %>
    <% else %>
      Not logged in
    <% end %>
    EOF
    Erubis::OnlyRuby.new(content).src
  }

  it { should_not include("h1") }
  it { should_not include("Title") }
  it { should_not include("Not logged in") }
  it { should include("current_user") }
  it { should include("if") }
  it { should include("else") }
  it { should include("end") }
end
