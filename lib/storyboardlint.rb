# encoding: UTF-8
# Have fun. Use at your own risk.
# Copyright (c) 2014 Johannes Fahrenkrug

require 'nokogiri'
require 'ostruct'
require 'optparse'

module StoryboardLint
  class StoryboardScanner
    def initialize(src_root)
      if !File.directory?(src_root)
        raise ArgumentError, "The directory '#{src_root}' does not exist."
      end
      
      @src_root = src_root
      @scan_performed = false    
    end
    
    def storyboard_files
      return @sb_files if @sb_files
  
      # find all storyboard files...
      @sb_files = Dir.glob(File.join(@src_root, "**/*.storyboard"))
    end
    
    def xib_files
      return @xib_files if @xib_files
  
      # find all XIB files...
      @xib_files = Dir.glob(File.join(@src_root, "**/*.xib"))
    end
    
    def segue_ids
      scan_files
      @segue_ids
    end
    
    def storyboard_ids
      scan_files
      @storyboard_ids
    end
    
    def reuse_ids
      scan_files
      @reuse_ids
    end
    
    def custom_class_names
      scan_files
      @custom_class_names
    end
    
    private
    
    def scan_files
      if !@scan_performed
        @segue_ids ||= []
        @storyboard_ids ||= []
        @reuse_ids ||= []
        @custom_class_names = []
    
        storyboard_files.each do |sb_file|
          sb_source = File.open(sb_file)
          doc = Nokogiri::XML(sb_source)
          doc.xpath('//segue').each do |element|
            seg_id = element.attr('identifier')
            @segue_ids << {:file => sb_file, :id => seg_id.to_s} if seg_id
          end

          @storyboard_ids += doc.xpath("//@storyboardIdentifier").to_a.map {|match| {:file => sb_file, :id => match.to_s}}
          @reuse_ids += doc.xpath("//@reuseIdentifier").to_a.map {|match| {:file => sb_file, :id => match.to_s}}
          @custom_class_names += doc.xpath("//@customClass").to_a.map {|match| {:file => sb_file, :class_name => match.to_s}}
        end
        
        xib_files.each do |xib_file|
          xib_source = File.open(xib_file)
          doc = Nokogiri::XML(xib_source)

          @reuse_ids += doc.xpath("//@reuseIdentifier").to_a.map {|match| {:file => xib_file, :id => match.to_s}}
        end
        
        @scan_performed = true
      end
    end
  end

  class SourceScanner    
    def initialize(src_root, matcher, additional_sources = nil)
      if !File.directory?(src_root)
        raise ArgumentError, "The directory '#{src_root}' does not exist."
      end
      
      if !matcher
        raise ArgumentError, "The matcher cannot be nil."
      end
      
      @additional_sources = additional_sources
      @matcher = matcher
      @src_root = src_root
      @scan_performed = false    
    end
    
    def source_files
      return @source_files if @source_files
  
      # find all *.h, *.c, *.m and *.mm files
      match_string = "**/*.{h,c,m,mm}"
      @source_files = Dir.glob(File.join(@src_root, match_string))
      
      if @additional_sources && @additional_sources.size > 0
        @additional_sources.each do |source_path|
          absolute_path = ''
          if source_path.start_with?("/")
            #absolute path
            absolute_path = source_path
          else
            #relative to src_root
            absolute_path = File.join(@src_root, source_path)
          end
          
          if File.directory?(absolute_path)
            @source_files += Dir.glob(File.join(absolute_path, match_string))
          else
            puts "warning: additional source directory '#{absolute_path}' does not exist!"
          end
        end
      end
      
      if @source_files and @source_files.size > 0
        @source_files.select! {|sf| File.file?(sf)}
      end
      
      @source_files
    end
    
    def segue_ids
      scan_files
      @segue_ids
    end
    
    def storyboard_ids
      scan_files
      @storyboard_ids
    end
    
    def reuse_ids
      scan_files
      @reuse_ids
    end
    
    def class_names
      scan_files
      @class_names
    end
    
    private
    
    def scan_files
      if !@scan_performed
        @class_names ||= []
        @segue_ids ||= []
        @storyboard_ids ||= []
        @reuse_ids ||= []

        source_files.each do |source_file|
          File.readlines(source_file, :encoding => 'UTF-8').each_with_index do |line, idx|
            # class names
            line.scan(@matcher.class_regex).each do |match|
              @class_names << {:file => source_file, :line => idx + 1, :class_name => match[0]}
            end
            
            # segue ids
            line.scan(@matcher.segue_id_regex_source).each do |match|
              @segue_ids << {:file => source_file, :line => idx + 1, :id => match[0]}
            end
            
            # storyboard ids
            line.scan(@matcher.storyboard_id_regex_source).each do |match|
              @storyboard_ids << {:file => source_file, :line => idx + 1, :id => match[0]}
            end
            
            # reuse ids
            line.scan(@matcher.reuse_id_regex_source).each do |match|
              @reuse_ids << {:file => source_file, :line => idx + 1, :id => match[0]}
            end
          end
        end
        
        @scan_performed = true
      end
    end
  end
  
  class Matcher
    DEFAULT_SEGUE_ID_PREFIX = "seg_"
    DEFAULT_STORYBOARD_ID_PREFIX = "sb_"
    DEFAULT_REUSE_ID_PREFIX = "ruid_"
    
    def initialize(options)
      options ||= OpenStruct.new
      
      @storyboard_id_regex_source = create_source_regex(DEFAULT_STORYBOARD_ID_PREFIX, options.storyboard_prefix, options.storyboard_suffix)
      @storyboard_id_regex_sb = create_storyboard_regex(DEFAULT_STORYBOARD_ID_PREFIX, options.storyboard_prefix, options.storyboard_suffix)
      
      @segue_id_regex_source = create_source_regex(DEFAULT_SEGUE_ID_PREFIX, options.segue_prefix, options.segue_suffix)
      @segue_id_regex_sb = create_storyboard_regex(DEFAULT_SEGUE_ID_PREFIX, options.segue_prefix, options.segue_suffix)
      
      @reuse_id_regex_source = create_source_regex(DEFAULT_REUSE_ID_PREFIX, options.reuse_prefix, options.reuse_suffix)
      @reuse_id_regex_sb = create_storyboard_regex(DEFAULT_REUSE_ID_PREFIX, options.reuse_prefix, options.reuse_suffix)
    end
        
    def class_regex
      /@interface\s+([a-zA-Z_]+\w*)/
    end
    
    [:storyboard, :segue, :reuse].each do |name|
      [:sb, :source].each do |kind|
        method_name = "#{name}_id_regex_#{kind}"
        define_method(method_name) { instance_variable_get("@#{method_name}") }
      end
    end
    
    private
    
    def create_source_regex(default_prefix, prefix, suffix)
      inner_regex_part = %{(?:\\"|[^"])+}
      if prefix.to_s.empty? and suffix.to_s.empty?
        return /@"(#{default_prefix}#{inner_regex_part})"/
      else
        return /@"(#{prefix}#{inner_regex_part}#{suffix})"/
      end
    end
    
    def create_storyboard_regex(default_prefix, prefix, suffix)
      inner_regex_part = %{(?:\\"|[^"])+}
      if prefix.to_s.empty? and suffix.to_s.empty?
        sb = /^#{default_prefix}/
      else        
        if !prefix.to_s.empty?
          if !suffix.to_s.empty?
            sb = /^#{prefix}[\w\s]*#{suffix}$/ 
          else !prefix.to_s.empty?
            sb = /^#{prefix}/
          end
        else
          sb = /#{suffix}$/
        end
      end
      
      sb
    end
  end
  
  class Linter
    def initialize(sb_scanner, source_scanner, matcher)
      if !sb_scanner
        raise ArgumentError, "The sb_scanner cannot be nil."
      end
      
      if !source_scanner
        raise ArgumentError, "The source_scanner cannot be nil."
      end
      
      if !matcher
        raise ArgumentError, "The matcher cannot be nil."
      end
      
      @matcher = matcher
      @sb_scanner = sb_scanner
      @source_scanner = source_scanner
    end
    
    def lint
     check_naming
     check_custom_classes
     check_ids
    end
    
    def check_naming
      [{:items => @sb_scanner.segue_ids, :regex => @matcher.segue_id_regex_sb, :name => 'Segue ID'},
       {:items => @sb_scanner.storyboard_ids, :regex => @matcher.storyboard_id_regex_sb, :name => 'Storyboard ID'},
       {:items => @sb_scanner.reuse_ids, :regex => @matcher.reuse_id_regex_sb, :name => 'Reuse ID'}].each do |data|
        data[:items].each do |item|
          if item[:id] !~ data[:regex]
            puts "warning: #{data[:name]} '#{item[:id]}' used in #{File.basename(item[:file])} does not match '#{data[:regex]}."
          end
        end
      end
    end
    
    def check_custom_classes
      @sb_scanner.custom_class_names.each do |custom_class|
        if !@source_scanner.class_names.map {|cn| cn[:class_name]}.include?(custom_class[:class_name])
          puts "error: Custom class '#{custom_class[:class_name]}' used in #{File.basename(custom_class[:file])} could not be found in source code."    
        end
      end
    end
    
    def check_ids
      [{:method_name => :segue_ids, :name => 'Segue ID', :target => 'Storyboard'},
       {:method_name => :storyboard_ids, :name => 'Storyboard ID', :target => 'Storyboard'},
       {:method_name => :reuse_ids, :name => 'Reuse ID', :target => 'Storyboard or XIB'}].each do |data|
        @source_scanner.send(data[:method_name]).each do |source_item|
          if !@sb_scanner.send(data[:method_name]).map {|sb_item| sb_item[:id]}.include?(source_item[:id])
            puts "#{source_item[:file]}:#{source_item[:line]}: warning: #{data[:name]} '#{source_item[:id]}' could not be found in any #{data[:target]}."    
          end
        end
      end
    end
    
    def self.run!(*args)
      options = OpenStruct.new
      
      opt_parser = OptionParser.new do |opts|
        opts.banner = "Usage: storyboardlint <target directory> [options]"
        opts.separator  ""
        opts.separator  "Options"

        opts.on("--storyboard-prefix [PREFIX]", "Storyboard IDs have to begin with PREFIX.") do |prefix|
          options.storyboard_prefix = prefix
        end
        
        opts.on("--storyboard-suffix [SUFFIX]", "Storyboard IDs have to end with SUFFIX") do |suffix|
          options.storyboard_suffix = suffix
        end
        
        opts.on("--segue-prefix [PREFIX]", "Segue IDs have to begin with PREFIX") do |prefix|
          options.segue_prefix = prefix
        end
        
        opts.on("--segue-suffix [SUFFIX]", "Segue IDs have to end with SUFFIX") do |suffix|
          options.segue_suffix = suffix
        end
        
        opts.on("--reuse-prefix [PREFIX]", "Reuse IDs have to begin with PREFIX") do |prefix|
          options.reuse_prefix = prefix
        end
        
        opts.on("--reuse-suffix [SUFFIX]", "Reuse IDs have to end with SUFFIX") do |suffix|
          options.reuse_suffix = suffix
        end
        
        opts.on( '--additional-sources /absolute/path,../relative/to/target_directory', Array, "List of additional directories to scan for source files") do |source_paths|
          options.additional_sources = source_paths
        end
        
        # No argument, shows at tail.  This will print an options summary.
        # Try it and see!
        opts.on_tail("-h", "--help", "Show this message") do
          puts opts
          exit
        end

        # Another typical switch to print the version.
        opts.on_tail("--version", "Show version") do
          puts "StoryboardLint v0.2.1"
          exit
        end
      end
      
      if ARGV.length < 1
        puts opt_parser
        exit 0
      end
      
      opt_parser.parse(args)

      matcher = StoryboardLint::Matcher.new(options)
      sb_scanner = StoryboardLint::StoryboardScanner.new(ARGV[0])
      source_scanner = StoryboardLint::SourceScanner.new(ARGV[0], matcher, options.additional_sources)

      linter = StoryboardLint::Linter.new(sb_scanner, source_scanner, matcher)
      linter.lint
      
      return 0
    end
  end
end