require 'errbit_pivotal_plugin/version'
require 'errbit_pivotal_plugin/issue_tracker'
require 'errbit_pivotal_plugin/rails'

module ErrbitPivotalPlugin
  def self.root
    File.expand_path '../..', __FILE__
  end
end

ErrbitPlugin::Registry.add_issue_tracker(ErrbitPivotalPlugin::IssueTracker)
