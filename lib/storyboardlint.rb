# Have fun. Use at your own risk.
# Copyright (c) 2014 Johannes Fahrenkrug

require 'nokogiri'

module StoryboardLint
  SEGUE_ID_PREFIX = "seg_"
  STORYBOARD_ID_PREFIX = "sb_"
  REUSE_ID_PREFIX = "ruid_"

  class StoryboardScanner
    def initialize(src_root)
      @src_root = src_root
      @scan_performed = false    
    end
    
    def storyboard_files
      return @sb_files if @sb_files
  
      # find all storyboard files...
      @sb_files = Dir.glob(File.join(@src_root, "**/*.storyboard"))
    end
    
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
        
        @scan_performed = true
      end
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
  end

  class SourceScanner
    CLASS_REGEX = /@interface\s+([a-zA-Z_]+\w*)/
    SEGUE_ID_REGEX = /@"(#{SEGUE_ID_PREFIX}(?:\\"|[^"])+)"/
    STORYBOARD_ID_REGEX = /@"(#{STORYBOARD_ID_PREFIX}(?:\\"|[^"])+)"/
    REUSE_ID_REGEX = /@"(#{REUSE_ID_PREFIX}(?:\\"|[^"])+)"/
    
    def initialize(src_root)
      @src_root = src_root
      @scan_performed = false    
    end
    
    def source_files
      return @source_files if @source_files
  
      # find all *.h, *.c, *.m and *.mm files
      @source_files = Dir.glob(File.join(@src_root, "**/*.{h,c,m,mm}"))
    end
    
    def scan_files
      if !@scan_performed
        @class_names ||= []
        @segue_ids ||= []
        @storyboard_ids ||= []
        @reuse_ids ||= []

        source_files.each do |source_file|
          File.readlines(source_file).each_with_index do |line, idx|
            # class names
            line.scan(CLASS_REGEX).each do |match|
              @class_names << {:file => source_file, :line => idx + 1, :class_name => match[0]}
            end
            
            # segue ids
            line.scan(SEGUE_ID_REGEX).each do |match|
              @segue_ids << {:file => source_file, :line => idx + 1, :id => match[0]}
            end
            
            # storyboard ids
            line.scan(STORYBOARD_ID_REGEX).each do |match|
              @storyboard_ids << {:file => source_file, :line => idx + 1, :id => match[0]}
            end
            
            # reuse ids
            line.scan(REUSE_ID_REGEX).each do |match|
              @reuse_ids << {:file => source_file, :line => idx + 1, :id => match[0]}
            end
          end
        end
        
        @scan_performed = true
      end
    end
    
    def class_names
      scan_files
      @class_names
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
  end
  
  class Linter
    def initialize(sb_scanner, source_scanner)
      @sb_scanner = sb_scanner
      @source_scanner = source_scanner
    end
    
    def lint
     check_naming
     check_custom_classes
     check_ids
    end
    
    def check_naming
      @sb_scanner.segue_ids.each do |seg_id|
        if seg_id[:id] !~ /$#{SEGUE_ID_PREFIX}/
          puts "warning: Segue ID '#{seg_id[:id]}' used in #{File.basename(seg_id[:file])} does not start with '#{SEGUE_ID_PREFIX}' prefix."
        end
      end
      
      @sb_scanner.storyboard_ids.each do |sb_id|
        if sb_id[:id] !~ /$#{STORYBOARD_ID_PREFIX}/
          puts "warning: Storyboard ID '#{sb_id[:id]}' used in #{File.basename(sb_id[:file])} does not start with '#{STORYBOARD_ID_PREFIX}' prefix."
        end
      end
      
      @sb_scanner.reuse_ids.each do |ru_id|
        if ru_id[:id] !~ /$#{REUSE_ID_PREFIX}/
          puts "warning: Reuse ID '#{ru_id[:id]}' used in #{File.basename(ru_id[:file])} does not start with '#{REUSE_ID_PREFIX}' prefix."
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
      @source_scanner.segue_ids.each do |seg_id|
        if !@sb_scanner.segue_ids.map {|sb_seg_id| sb_seg_id[:id]}.include?(seg_id[:id])
          puts "#{seg_id[:file]}:#{seg_id[:line]}: warning: Segue ID '#{seg_id[:id]}' could not be found in any Storyboard."    
        end
      end
      
      @source_scanner.storyboard_ids.each do |sb_id|
        if !@sb_scanner.storyboard_ids.map {|sb_sb_id| sb_sb_id[:id]}.include?(sb_id[:id])
          puts "#{sb_id[:file]}:#{sb_id[:line]}: warning: Storyboard ID '#{sb_id[:id]}' could not be found in any Storyboard."    
        end
      end
      
      @source_scanner.reuse_ids.each do |ru_id|
        if !@sb_scanner.reuse_ids.map {|sb_ru_id| sb_ru_id[:id]}.include?(ru_id[:id])
          puts "#{ru_id[:file]}:#{ru_id[:line]}: warning: Reuse ID '#{ru_id[:id]}' could not be found in any Storyboard."    
        end
      end
    end
    
    def self.run!(*args)
      puts "StoryboardLint"
      puts "by Johannes Fahrenkrug, @jfahrenkrug, springenwerk.com"
      puts

      if args.size < 1
        puts "Usage: storyboardlint <target directory>"
        exit
      end

      sb_scanner = StoryboardLint::StoryboardScanner.new(ARGV[0])
      source_scanner = StoryboardLint::SourceScanner.new(ARGV[0])

      linter = StoryboardLint::Linter.new(sb_scanner, source_scanner)
      linter.lint
      
      return 0
    end
  end
end