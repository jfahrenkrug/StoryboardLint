require 'spec_helper'

describe StoryboardLint::Matcher do
  describe "Default Matcher" do
    before :all do
      @m = StoryboardLint::Matcher.new(nil)
    end
    
    it "should create the correct regex to find class names" do
      r = @m.class_regex
      "Test".should_not match(r)
      "@interface Test".should match(r)
      "@interface Test_1234__ClassNAME".should match(r)
      "@protocol Test".should_not match(r)
      "@interface@TEST.com".should_not match(r)
    end
    
    it "should create the correct storyboard ID regex for storyboards" do
      r = @m.storyboard_id_regex_sb
      "test".should_not match(r)
      "sb_test".should match(r)
    end
    
    it "should create the correct storyboard ID regex for source files" do
      r = @m.storyboard_id_regex_source
      "test".should_not match(r)
      "sb_test".should_not match(r)
      '@"sb_test"'.should match(r)
    end
    
    it "should create the correct segue ID regex for storyboards" do
      r = @m.segue_id_regex_sb
      "test".should_not match(r)
      "seg_test".should match(r)
    end
    
    it "should create the correct segue ID regex for source files" do
      r = @m.segue_id_regex_source
      "test".should_not match(r)
      "seg_test".should_not match(r)
      '@"seg_test"'.should match(r)
    end
    
    it "should create the correct reuse ID regex for storyboards" do
      r = @m.reuse_id_regex_sb
      "test".should_not match(r)
      "ruid_test".should match(r)
    end
    
    it "should create the correct reuse ID regex for source files" do
      r = @m.reuse_id_regex_source
      "test".should_not match(r)
      "ruid_test".should_not match(r)
      '@"ruid_test"'.should match(r)
    end
  end
  
  describe "Suffix Matcher" do
    before :all do
      options = OpenStruct.new
      options.storyboard_suffix = "Storyboard"
      options.segue_suffix = "Segue"
      options.reuse_suffix = "Cell"
      @m = StoryboardLint::Matcher.new(options)
    end
    
    it "should create the correct storyboard ID regex for storyboards" do
      r = @m.storyboard_id_regex_sb
      "test".should_not match(r)
      "testStoryboard".should match(r)
    end
    
    it "should create the correct storyboard ID regex for source files" do
      r = @m.storyboard_id_regex_source
      "test".should_not match(r)
      "testStoryboard".should_not match(r)
      '@"testStoryboard"'.should match(r)
    end
    
    it "should create the correct segue ID regex for storyboards" do
      r = @m.segue_id_regex_sb
      "test".should_not match(r)
      "testSegue".should match(r)
    end
    
    it "should create the correct segue ID regex for source files" do
      r = @m.segue_id_regex_source
      "test".should_not match(r)
      "testSegue".should_not match(r)
      '@"testSegue"'.should match(r)
    end
    
    it "should create the correct reuse ID regex for storyboards" do
      r = @m.reuse_id_regex_sb
      "test".should_not match(r)
      "testCell".should match(r)
    end
    
    it "should create the correct reuse ID regex for source files" do
      r = @m.reuse_id_regex_source
      "test".should_not match(r)
      "testCell".should_not match(r)
      '@"testCell"'.should match(r)
    end
  end
  
  describe "Prefix Matcher" do
    before :all do
      options = OpenStruct.new
      options.storyboard_prefix = "sbpre"
      options.segue_prefix = "segpre"
      options.reuse_prefix = "cellpre"
      @m = StoryboardLint::Matcher.new(options)
    end
    
    it "should create the correct storyboard ID regex for storyboards" do
      r = @m.storyboard_id_regex_sb
      "test".should_not match(r)
      "sbpretest".should match(r)
    end
    
    it "should create the correct storyboard ID regex for source files" do
      r = @m.storyboard_id_regex_source
      "test".should_not match(r)
      "sbpretest".should_not match(r)
      '@"sbpretest"'.should match(r)
    end
    
    it "should create the correct segue ID regex for storyboards" do
      r = @m.segue_id_regex_sb
      "test".should_not match(r)
      "segpretest".should match(r)
    end
    
    it "should create the correct segue ID regex for source files" do
      r = @m.segue_id_regex_source
      "test".should_not match(r)
      "segpretest".should_not match(r)
      '@"segpretest"'.should match(r)
    end
    
    it "should create the correct reuse ID regex for storyboards" do
      r = @m.reuse_id_regex_sb
      "test".should_not match(r)
      "cellpretest".should match(r)
    end
    
    it "should create the correct reuse ID regex for source files" do
      r = @m.reuse_id_regex_source
      "test".should_not match(r)
      "cellpretest".should_not match(r)
      '@"cellpretest"'.should match(r)
    end
    
    it "should only capture the actual ID" do
      options = OpenStruct.new
      options.reuse_suffix = "Cell"
      m = StoryboardLint::Matcher.new(options)
      r = m.reuse_id_regex_source
      test_string = '@"cellName" : @"bronzeTableCell"'
      test_string.should match(r)
      test_string =~ r
      $1.should == 'bronzeTableCell'
    end
  end
  
end