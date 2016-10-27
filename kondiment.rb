require 'bundler'
Bundler.require

require 'pathname'
require 'optparse'

class Kondiment
  def initialize repo_path
    @repo_path = Pathname.new repo_path
  end

  def build! output_path
    if output_path.exist?
      if options[:overwrite]
        output_path.rmtree
      else
        puts "output path #{output_path} already exists. Use --overwrite to overwrite"
        exit 1
      end
    end

    output_path.mkdir

    compiled = main_template.render self
    index_path = output_path.join('index.html')
    index_path.write(compiled)

    copy_assets output_path
    copy_media output_path

    `open #{index_path.to_s}`
  end


  private
  def options
    options = {}
    OptionParser.new do |opts|
      opts.banner = "Usage: example.rb [options]"

      opts.on("-o", "--overwrite", "Overwrite existing output path") do |o|
        options[:overwrite] = o
      end
    end.parse!
    options
  end


  def steps
    return @steps if @steps

    @steps = []
    logs = git.log.to_a.reverse

    logs.each_with_index do |log, index|
      @steps << Step.new(log, index)
    end

    @steps
  end

  def git
    @git ||= Git.open @repo_path
  end

  def kondiment_root
    Pathname.new(__FILE__).dirname
  end

  def template_root
    kondiment_root.join('templates')
  end

  def main_template
    Haml::Engine.new template_root.join('tutorial.haml').read, escape_html: true
  end

  def copy_assets output_path
    FileUtils.cp_r kondiment_root.join('assets'), output_path.join('assets')
  end

  def copy_media output_path
    FileUtils.cp_r @repo_path.join('tutorial-media'), output_path.join('media')
  end

  class Step
    attr_reader :log

    FRONTMATTER_REGEX = /---\n(.+)\n---/m

    def initialize log, index
      @log, @index = log, index
    end

    def title
      log.message.lines.first.strip
    end

    def markdown
      body.gsub(FRONTMATTER_REGEX, '').strip
    end

    def html
      GitHub::Markup.render('step.md', markdown)
    end

    def hide_diff
      data[:hideDiff]
    end

    def slug
      title.gsub(/\W/, '-').downcase
    end

    def number
      @index + 1
    end

    def images
      return [] unless log.parent

      log.parent.diff(log).entries.select {|entry|
        entry.path.starts_with? 'tutorial-media'
      }.map {|entry|
        "media/#{File.basename entry.path}"
      }
    end

    def changes
      return [] unless log.parent
      return @changes if @changes
      @changes = log.parent.diff(log).entries.reject {|entry|
        entry.path.starts_with?('tutorial-media') ||
        entry.path.ends_with?('.gitignore') ||
        entry.path.ends_with?('.jshintrc') ||
        entry.path.ends_with?('photo-test.js') ||
        entry.path.ends_with?('bower.json') ||
        entry.path.ends_with?('package.json')
      }.map {|entry| ChangedFile.new(entry, log) }
    end

    private

    def data
      if frontmatter
        JSON.parse(frontmatter).with_indifferent_access
      else
        {}
      end
    end

    def body
      log.message.lines[1..-1].join
    end

    def frontmatter
      body.match(FRONTMATTER_REGEX).try(:[], 1)
    end

    class ChangedFile

      def initialize log_entry, log
        @log_entry, @log = log_entry, log
      end

      def path
        @log_entry.path
      end

      def id
        "#{@log.sha}-#{@log_entry.object_id}"
      end

      def contents
        repo = @log.instance_variable_get('@base').repo.path
        result = `git --git-dir="#{repo}" show #{@log.sha}:"#{path}"`
        unless result.present?
          result = "(File removed)"
        end
        result
      end

      def diff
        @log_entry.patch
      end
    end

  end

end

if $0 == __FILE__
  unless ARGV[0].present?
    raise "pass the path to the tutorial repo"
  end
  unless ARGV[1].present?
    raise "pass the path to the output"
  end
  tutorial = Kondiment.new ARGV[0]
  tutorial.build! Pathname.new(ARGV[1])
end