require 'redmine'
require 'dispatcher' unless Rails::VERSION::MAJOR >= 3

Redmine::Plugin.register :redmine_custom_help_url do
  name 'Redmine Custom Help URL plugin'
  description 'A plugin to replace the help top-menu item with one for which an admin can define the URL himself without touching the Redmine core.'
  url 'https://github.com/MischaTheEvil/redmine_custom_help_url'
  author 'Mischa The Evil'
  author_url 'https://github.com/MischaTheEvil'
  version '0.0.2'
  
  settings :default => {:custom_help_url => ''},
           :partial => 'settings/redmine_custom_help_url_settings'

  delete_menu_item :top_menu, :help
end

if Rails::VERSION::MAJOR >= 3
  ActionDispatch::Callbacks.to_prepare do
    require_dependency 'redmine_custom_help_url'
  end
else
  Dispatcher.to_prepare do
    require_dependency 'redmine_custom_help_url'
  end
end

# Workaround inability to access Setting.plugin_name['setting'], both directly as well as via overridden
# module containing the call to Setting.*, before completed plugin registration since we use a call to either:
# * Setting.plugin_redmine_custom_help_url['custom_help_url'] or (and replaced by)
# * RedmineCustomHelpUrl::Redmine::Info.help_url,
# which both can *only* be accessed *after* completed plugin registration (http://www.redmine.org/issues/7104)
#
# We now use overridden module RedmineCustomHelpUrl::Redmine::Info instead of directly calling 
# Setting.plugin_redmine_custom_help_url['custom_help_url']
# Redmine::Plugin.find('redmine_custom_help_url').menu :top_menu, :help, Setting.plugin_redmine_custom_help_url['custom_help_url'], :last => true
Redmine::Plugin.find('redmine_custom_help_url').menu :top_menu, :help, RedmineCustomHelpUrl::Redmine::Info.help_url, :last => true
