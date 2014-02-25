require 'spec_helper'

describe StoryboardLint::Linter do
  describe "Default Linter" do
    before :all do
      src_root = File.join(File.dirname(__FILE__), "fixtures", "StoryboardLintTest")
      @matcher = StoryboardLint::Matcher.new(nil)
      @sbs = StoryboardLint::StoryboardScanner.new(src_root)
      @src = StoryboardLint::SourceScanner.new(src_root, @matcher)
      @l = StoryboardLint::Linter.new(@sbs, @src, @matcher)
    end
    
    it "should require a StoryboardScanner on init" do
      expect {StoryboardLint::Linter.new(nil, @src, @matcher)}.to raise_error
    end
    
    it "should require a SourceScanner on init" do
      expect {StoryboardLint::Linter.new(@sbs, nil, @matcher)}.to raise_error
    end
    
    it "should require a Matcher on init" do
      expect {StoryboardLint::Linter.new(@sbs, @src, nil)}.to raise_error
    end
  end
  
end