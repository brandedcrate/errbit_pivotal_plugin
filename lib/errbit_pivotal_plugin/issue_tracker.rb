require 'pivotal-tracker'

module ErrbitPivotalPlugin
  class IssueTracker < ErrbitPlugin::IssueTracker

    LABEL = 'pivotal'

    NOTE = 'You can find your project\'s ID in the URL when you are ' <<
           'viewing a project in pivotal.'

    FIELDS = {
      :api_token => {
        :placeholder => 'API Token for your account'
      },
      :project_id => {
        :label => 'Project ID',
        :placeholder => 'Project ID (e.g. 1185196)'
      }
    }

    def self.label
      LABEL
    end

    def self.note
      NOTE
    end

    def self.fields
      FIELDS
    end

    def self.body_template
      @body_template ||= ERB.new(File.read(
        File.join(
          ErrbitPivotalPlugin.root, 'views', 'pivotal_issues_body.txt.erb'
        )
      ))
    end

    def url
      "https://www.pivotaltracker.com/"
    end

    def configured?
      params['project_id'].present? && params['api_token'].present?
    end

    def comments_allowed?; false; end

    def errors
      errors = []
      if self.class.fields.detect {|f| params[f[0].to_s].blank? }
        errors << [:base, 'You must specify your Pivotal Tracker API token and Project ID']
      end
      errors
    end

    def create_issue(problem, reported_by = nil)
      PivotalTracker::Client.token = params['api_token']
      PivotalTracker::Client.use_ssl = true
      project = PivotalTracker::Project.find params['project_id'].to_i
      story = project.stories.create({
        :name => "[#{ problem.environment }][#{ problem.where }] #{problem.message.to_s.truncate(100)}",
        :story_type => 'bug',
        :description => self.class.body_template.result(binding).unpack('C*').pack('U*'),
        :requested_by => reported_by.name
      })

      if story.errors.present?
        raise StandardError, story.errors.first
      else
        problem.update_attributes(
          :issue_link => "https://www.pivotaltracker.com/story/show/#{story.id}",
          :issue_type => self.class.label
        )
      end
    end
  end
end
