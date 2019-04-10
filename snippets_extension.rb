# Uncomment this if you reference any of your controllers in activate
# require_dependency "application_controller"
require "radiant-snippets-extension"

class SnippetsExtension < Radiant::Extension
  version     RadiantSnippetsExtension::VERSION
  description RadiantSnippetsExtension::DESCRIPTION
  url         RadiantSnippetsExtension::URL

  def activate
    
    if defined?(Radiant::Exporter)
      Radiant::Exporter.exportable_models << Snippet
      Radiant::Exporter.template_models << Snippet
    end
    
    Page.class_eval do
      include SnippetTags
    end
    
    Radiant::AdminUI.class_eval do
      attr_accessor :snippet, :snippet_file

      alias_method :snippets, :snippet
      alias_method :snippet_files, :snippet_file

      def load_default_snippet_regions
        OpenStruct.new.tap do |snippet|
          snippet.edit = Radiant::AdminUI::RegionSet.new do |edit|
            edit.main.concat %w{edit_header edit_form}
            edit.form.concat %w{edit_title edit_content edit_filter}
            edit.form_bottom.concat %w{edit_buttons edit_timestamp}
          end
          snippet.index = Radiant::AdminUI::RegionSet.new do |index|
            index.top.concat %w{}
            index.thead.concat %w{title_header actions_header}
            index.tbody.concat %w{title_cell actions_cell}
            index.bottom.concat %w{new_button}
          end
          snippet.new = snippet.edit
        end
      end

      def load_default_snippet_file_regions
        OpenStruct.new.tap do |snippet|
          snippet.show = Radiant::AdminUI::RegionSet.new do |edit|
            edit.main.concat %w{ header }
            edit.display_content.concat %w{ title content }
            edit.bottom.concat %w{ timestamp }
          end
          snippet.index = Radiant::AdminUI::RegionSet.new do |index|
            index.top.concat %w{}
            index.thead.concat %w{title_header}
            index.tbody.concat %w{title_cell}
            index.bottom.concat %w{new_button}
          end
        end
      end
    end
    
    admin.snippet       ||= Radiant::AdminUI.load_default_snippet_regions
    admin.snippet_file  ||= Radiant::AdminUI.load_default_snippet_file_regions
    
    Radiant::UserActionObserver.instance.send :add_observer!, ::Snippet
                                 
    tab 'Design' do
      add_item "Snippets", "/admin/snippets"
      add_item "Snippet Files", "/admin/snippet_files"
    end
    
  end
end
