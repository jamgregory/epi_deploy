require 'git'
require_relative './helpers'

module EpiDeploy
  class GitWrapper
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
      
      def push(branch, options = {force: false, tags: true})
        git.push 'origin', branch, options
      end
      
      def add(files = nil)
        git.add files
      end
      
      def short_commit_hash
        git.log.first.sha[0..6]
      end
      
      def tag(tag_name)
        git.add_tag(tag_name, annotate: true)
      end
      
      def get_commit(git_reference)
        if git_reference == :latest
          fail("There is no latest release. Create one, or specify a reference with --ref") if tag_list.empty?
          git_reference = tag_list.first
        end
        
        git_object_type = git.lib.object_type(git_reference)

        case git_object_type
          when 'tag'    then git.tag(git_reference)
          when 'commit' then git.object(git_reference)
          else nil
        end
      end
      
      def change_branch_commit(branch, commit)
        Kernel.system "git branch -f #{branch} #{commit}"
        
        "git for-each-ref --sort=taggerdate --format '%(refname) %(taggerdate)' refs/tags"
        
        self.push branch, force: true, tags: true
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