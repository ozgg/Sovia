require 'spec_helper'

describe "posts/index.html.erb" do
  it "renders entries/list" do
    assign(:entries, [])
    render
    expect(rendered).to render_template('entries/_list')
  end
end
