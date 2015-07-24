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

    def self.icons
      @icons ||= {
        create: [
          'image/png', ErrbitPivotalPlugin.read_static_file('pivotal_create.png')
        ],
        goto: [
          'image/png', ErrbitPivotalPlugin.read_static_file('pivotal_goto.png'),
        ],
        inactive: [
          'image/png', ErrbitPivotalPlugin.read_static_file('pivotal_inactive.png'),
        ]
      }
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
      options['project_id'].present? && options['api_token'].present?
    end

    def comments_allowed?; false; end

    def errors
      errors = []
      if self.class.fields.detect {|f| options[f[0]].blank? }
        errors << [:base, 'You must specify your Pivotal Tracker API token and Project ID']
      end
      errors
    end

    def create_issue(title, body, user: {})
      PivotalTracker::Client.token = options['api_token']
      PivotalTracker::Client.use_ssl = true
      project = PivotalTracker::Project.find options['project_id'].to_i
      story = project.stories.create({
        :name => title,
        :story_type => 'bug',
        :description => body
      })

      if story.errors.present?
        raise StandardError, story.errors.first
      end
      "https://www.pivotaltracker.com/story/show/#{story.id}"
    end
  end
end
