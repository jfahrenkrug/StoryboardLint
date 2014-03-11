require 'spec_helper'

describe StoryboardLint::SourceScanner do
  
  it "should require an existing path when being initialized" do
    expect {StoryboardLint::SourceScanner.new("/some/path/that/does/not/exist", StoryboardLint::Matcher.new(nil))}.to raise_error
    expect {StoryboardLint::SourceScanner.new(File.dirname(__FILE__), StoryboardLint::Matcher.new(nil))}.to_not raise_error
  end
  
  it "should require a matcher when being initialized" do
    expect {StoryboardLint::SourceScanner.new(File.dirname(__FILE__), nil)}.to raise_error
  end
  
  
  describe "Default Options" do
    before :all do
      @src = StoryboardLint::SourceScanner.new(File.join(File.dirname(__FILE__), "fixtures", "StoryboardLintTest", "StoryboardLintTest"), StoryboardLint::Matcher.new(nil), ["../Pods"])
    end
    
    it "should find all source files" do
      file_names = @src.source_files.map {|full_path| File.basename(full_path)}
      file_names.size.should == 9
      
       ["SPWKAppDelegate.h", "SPWKDetailViewController.h", "SPWKMasterViewController.h", "main.m", "SPWKAppDelegate.m", "SPWKDetailViewController.m", "SPWKMasterViewController.m", "SomeFile.m", "Something.h"].each do |fn|
          file_names.should include(fn)
       end
    end
    
    it "should find all segue IDs that match the default naming convention" do
      ids = @src.segue_ids
      ids.size.should == 2
      
      ["seg_somethingNonExistent", "seg_showDetailSegue"].each do |id|
        ids.map {|i| i[:id]}.should include(id)
      end
    end
    
    it "should find all storyboard IDs that match the default naming convention" do
      ids = @src.storyboard_ids
      ids.size.should == 4
      
      ["sb_thisDoesNotExist", "sb_navigationControllerStoryboard", "sb_masterControllerStoryboard", "sb_detailControllerStoryboard"].each do |id|
        ids.map {|i| i[:id]}.should include(id)
      end
    end
    
    it "should find all reuse IDs that match the default naming convention" do
      ids = @src.reuse_ids
      ids.size.should == 3
      ['ruid_somethingNonExistent', 'ruid_TableCell', 'ruid_cellFromXIB'].each do |id|
        ids.map {|i| i[:id]}.should include(id)
      end
    end
    
    it "should find all class names in the project" do
      names = @src.class_names.map {|n| n[:class_name]}
      names.size.should == 6
      
      ["SPWKAppDelegate", "SPWKDetailViewController", "SPWKMasterViewController", "SPWKDetailViewController", "SPWKMasterViewController", "ClassFromCocoaPod"].each do |name|
        names.should include(name)
      end
    end
  end
  
  describe "Custom Suffixes" do
    before :all do
      options = OpenStruct.new
      options.storyboard_suffix = "Storyboard"
      options.segue_suffix = "Segue"
      options.reuse_suffix = "Cell"
      matcher = StoryboardLint::Matcher.new(options)
      @src = StoryboardLint::SourceScanner.new(File.join(File.dirname(__FILE__), "fixtures", "StoryboardLintTest"), matcher)
    end
        
    it "should find all segue IDs that match the given naming convention" do
      ids = @src.segue_ids
      ids.size.should == 2
      
      ['seg_showDetailSegue', 'someOtherSegue'].each do |id|
        ids.map {|i| i[:id]}.should include(id)
      end
    end
    
    it "should find all storyboard IDs that match the given naming convention" do
      ids = @src.storyboard_ids
      ids.size.should == 4
      
      ["sb_navigationControllerStoryboard", "sb_masterControllerStoryboard", "sb_detailControllerStoryboard", "someOtherStoryboard"].each do |id|
        ids.map {|i| i[:id]}.should include(id)
      end
    end
    
    it "should find all reuse IDs that match the given naming convention" do
      ids = @src.reuse_ids
      ids.size.should == 1
      ids[0][:id].should == 'ruid_TableCell'
    end
  end
  
  describe "Custom Prefixes" do
    before :all do
      options = OpenStruct.new
      options.storyboard_prefix = "sb" # no underscore so it doesn't equal the default prefix
      options.segue_prefix = "seg" # no underscore so it doesn't equal the default prefix
      options.reuse_prefix = "ruid" # no underscore so it doesn't equal the default prefix
      matcher = StoryboardLint::Matcher.new(options)
      @src = StoryboardLint::SourceScanner.new(File.join(File.dirname(__FILE__), "fixtures", "StoryboardLintTest"), matcher)
    end
        
    it "should find all segue IDs that match the given naming convention" do
      ids = @src.segue_ids
      ids.size.should == 3
      
      ['seg_showDetailSegue', 'segIDoNotExist', 'seg_somethingNonExistent'].each do |id|
        ids.map {|i| i[:id]}.should include(id)
      end
    end
    
    it "should find all storyboard IDs that match the given naming convention" do
      ids = @src.storyboard_ids
      ids.size.should == 5
      
      ["sb_navigationControllerStoryboard", "sb_masterControllerStoryboard", "sb_detailControllerStoryboard", "sbIDoNotExist", "sb_thisDoesNotExist"].each do |id|
        ids.map {|i| i[:id]}.should include(id)
      end
    end
    
    it "should find all reuse IDs that match the given naming convention" do
      ids = @src.reuse_ids
      ids.size.should == 4
      
      ["ruid_somethingNonExistent", "ruid_TableCell", "ruidIDoNotExist", "ruid_cellFromXIB"].each do |id|
        ids.map {|i| i[:id]}.should include(id)
      end
    end
  end
  
    
end