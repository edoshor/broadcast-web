module LayoutHelper

  def display_show_item(name, value, as_is = false)
    engine = Haml::Engine.new <<-HAML
%p
  %strong #{name.humanize}:
  #{as_is ? value : value.to_s.gsub(/\s/, '&nbsp;')}
    HAML
    engine.render
  end

  def display_actions(f, location)
    engine = Haml::Engine.new <<-HAML
.actions
  %button.btn.btn-primary.btn-large{:type => 'submit', :'data-disable-with' => 'Please wait...'} Save
  %button.btn.btn-large{:onclick => "location.href='#{location}'; return false;", :type => 'button'} Cancel
    HAML
    engine.render self, :form => f
  end

  def display_errors(f)
    engine = Haml::Engine.new <<-HAML
- if form.error_notification
  .alert.alert-error.fade.in
    %a.close(data-dismiss="alert" href="#") &times;
    = form.error_notification :class => 'no-margin'
  %hr.soften
    HAML
    engine.render self, :form => f
  end
end
