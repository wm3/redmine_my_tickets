require 'redmine'

Redmine::Plugin.register :redmine_my_ticket_macro do
  name 'My Ticket Macro plugin'
  author 'Motoi Washida'
  description 'List Ticket for me'
  version '0.0.1'
  url 'http://w3ch.jp'
  author_url 'http://w3ch.jp'

  Redmine::WikiFormatting::Macros.register do

    desc "List issues with descriptions.\n\n" +
      "  !{{my_ticket(tracker=Defunct)}}\n" +
      "  !{{my_ticket(tracker=Defunct, version=1.0 release)}}\n"

    macro :my_ticket do |obj, args|
      args, options = extract_macro_options(args, :tracker, :version)

      condition = { :project_id => @project.id, 'issue_statuses.is_closed' => false }
      options.each do |key, value|
        case key
        when :tracker then condition["trackers.name"] = value.to_s
        when :version then condition['versions.name'] = value.to_s
        end
      end

      issues = Issue.visible.find :all,
          :include => [:tracker, :fixed_version, :status],
          :conditions => condition

      paragraph = lambda do |issue|
        "<h2>#{link_to_issue(issue)}</h2> <p>#{textilizable issue.description}</p>"
      end

      issues.map { |issue| paragraph.call(issue) } * ""
    end
  end

end
