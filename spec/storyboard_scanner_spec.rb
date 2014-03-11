require 'spec_helper'

describe StoryboardLint::StoryboardScanner do
  
  before :all do
    @sbs = StoryboardLint::StoryboardScanner.new(File.join(File.dirname(__FILE__), "fixtures", "StoryboardLintTest"))
  end
  
  it "should require an existing path when being initialized" do
    expect {StoryboardLint::StoryboardScanner.new("/some/path/that/does/not/exist")}.to raise_error
    expect {StoryboardLint::StoryboardScanner.new(File.dirname(__FILE__))}.to_not raise_error
  end
  
  it "should find the storyboard files in the directory" do
    sb_files = @sbs.storyboard_files
    sb_files.size.should == 2
    
    ["Main_iPad.storyboard", "Main_iPhone.storyboard"].each do |file|
      sb_files.map {|path| File.basename(path)}.should include(file)
    end
  end
  
  it "should return the segue IDs" do
    ids = @sbs.segue_ids
    ids.size.should == 1
    ids[0][:id].should == "seg_showDetailSegue"
  end
  
  it "should return the storyboard IDs" do
    ids = @sbs.storyboard_ids
    ids.size.should == 3
    
    ['sb_navigationControllerStoryboard', 'sb_masterControllerStoryboard', 'sb_detailControllerStoryboard'].each do |id|
      ids.map {|i| i[:id]}.should include(id)
    end
  end
  
  it "should return the reuse IDs" do
    ids = @sbs.reuse_ids
    ids.size.should == 3
    
    ['Cell', 'ruid_TableCell', 'ruid_cellFromXIB'].each do |id|
      ids.map {|i| i[:id]}.should include(id)
    end
  end
  
  it "should return the custom class names" do
    names = @sbs.custom_class_names
    names.size.should == 6
    name_strings = names.map {|item| item[:class_name]}
    name_strings.should include('SPWKMasterViewController')
    name_strings.should include('SPWKDetailViewController')
    name_strings.should include('NonexistentViewController')
    name_strings.should include('ClassFromCocoaPod')
  end
  
end