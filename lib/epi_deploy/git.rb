require 'git'
require_relative './helpers'

module EpiDeploy
  class Git
      def on_master?
        git.current_branch == "master"
      end
      
      def pending_changes?
        git.status.changed.any?
      end
      
      def pull
        git.pull
      end
      
      def commit(message)
        git.commit_all message
      end
      
      def push(options = {force: false})
        Kernel.system "git push#{' -f' if options[:force]}"
      end
      
      def add(files = nil)
        git.add files
      end
      
      def short_commit_hash
        git.log.first.sha[0..6]
      end
      
      def tag(tag_name)
        git.add_tag(tag_name)
      end
      
      def get_commit(git_reference)
        if git_reference == :latest
          fail("There is no latest release. Create one, or specify a reference with --ref") if tag_list.empty?
          git_reference = tag_list.first
        end
        git_object = git.object(git_reference)
        return git_object if git_object.is_a?(::Git::Object::Commit)
        nil
      end
      
      def change_branch_commit(branch, commit)
        Kernel.system "git branch -f #{branch} #{commit}"
      end
      
      def tag_list(options = {limit: 5})
        @tag_list ||= `git tag`.split.reverse
      end
   
      private
        def git
          @git ||= ::Git.open(Dir.pwd)
        end
    
  end
end